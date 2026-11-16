// Publishes the app to Abrova Store: builds the web app, uploads build/web, and shows the store's preparation steps.
//
//   ABROVA_STORE_KEY=abs_… dart run abrova_web:publish --app team [--live] [--test] [--required]
//       [--notes-fa "…"] [--notes-en "…"] [--no-build] [--api https://apps.abrova.ir/api] [-- <flutter build args>]
//
// The key is a publish key from the Abrova Store console ("Publish keys" at the bottom of the side menu,
// https://apps.abrova.ir/console/en/keys). Everything after `--` goes to
// `flutter build web` (for example --dart-define-from-file=config/app.json).
import 'dart:async';
import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> argv) async {
  final split = argv.indexOf('--');
  final args = split < 0 ? argv : argv.sublist(0, split);
  final buildArgs = split < 0 ? <String>[] : argv.sublist(split + 1);
  String? opt(String name) {
    final i = args.indexOf(name);
    return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
  }

  final app = opt('--app');
  if (app == null || !RegExp(r'^[a-z0-9][a-z0-9-]{1,28}[a-z0-9]$').hasMatch(app)) {
    _fail('Which app? --app <address>, the part before .abrova.ir (for example --app team)');
  }
  final key = opt('--key') ?? Platform.environment['ABROVA_STORE_KEY'];
  if (key == null || !key.startsWith('abs_')) {
    _fail('No publish key: set ABROVA_STORE_KEY (make one at https://apps.abrova.ir/console/en/keys, "Publish keys" at the bottom of the console\'s side menu)');
  }
  final api = (opt('--api') ?? Platform.environment['ABROVA_STORE_API'] ?? 'https://apps.abrova.ir/api').replaceAll(RegExp(r'/+$'), '');

  if (!args.contains('--no-build')) {
    stdout.writeln('▸ flutter build web --release --no-web-resources-cdn ${buildArgs.join(' ')}');
    final build = await Process.start('flutter', ['build', 'web', '--release', '--no-web-resources-cdn', ...buildArgs], mode: ProcessStartMode.inheritStdio, runInShell: Platform.isWindows);
    if (await build.exitCode != 0) _fail('flutter build web failed');
  }
  if (!File('build/web/index.html').existsSync()) _fail('No build/web/index.html: run this in the Flutter app’s folder');

  // Zip build/web (the store also takes a zip of the folder itself).
  final tmp = Directory.systemTemp.createTempSync('abrova-publish-');
  final zip = File('${tmp.path}/$app-web.zip');
  final zipped = Platform.isWindows
      ? await Process.run('powershell', ['-NoProfile', '-Command', 'Compress-Archive -Path build/web -DestinationPath "${zip.path}"'])
      : await Process.run('zip', ['-qr', zip.path, 'web'], workingDirectory: 'build');
  if (zipped.exitCode != 0 || !zip.existsSync()) _fail('Could not zip build/web: ${zipped.stderr}');

  final client = HttpClient();
  try {
    final job = await _upload(client, '$api/v1/console/apps/$app/builds', key, zip, {
      if (opt('--notes-fa') != null) 'notesFa': opt('--notes-fa')!,
      if (opt('--notes-en') != null) 'notesEn': opt('--notes-en')!,
      'required': '${args.contains('--required')}',
      'live': '${args.contains('--live')}',
      'test': '${args.contains('--test')}',
    });
    await _follow(client, '$api/v1/console/apps/$app/uploads/${job['id']}', key);
  } finally {
    client.close(force: true);
    tmp.deleteSync(recursive: true);
  }
}

Future<Map<String, dynamic>> _upload(HttpClient client, String url, String key, File zip, Map<String, String> fields) async {
  final boundary = 'abrova${DateTime.now().microsecondsSinceEpoch}';
  final head = StringBuffer();
  fields.forEach((k, v) => head.write('--$boundary\r\nContent-Disposition: form-data; name="$k"\r\n\r\n$v\r\n'));
  head.write('--$boundary\r\nContent-Disposition: form-data; name="build"; filename="build.zip"\r\nContent-Type: application/zip\r\n\r\n');
  final headBytes = utf8.encode(head.toString());
  final tail = utf8.encode('\r\n--$boundary--\r\n');
  final total = zip.lengthSync();

  final request = await client.postUrl(Uri.parse(url));
  request.headers
    ..set('Authorization', 'Bearer $key')
    ..set('Content-Type', 'multipart/form-data; boundary=$boundary');
  request.contentLength = headBytes.length + total + tail.length;
  request.add(headBytes);
  var sent = 0, shown = -1;
  await for (final chunk in zip.openRead()) {
    request.add(chunk);
    sent += chunk.length;
    final pct = sent * 100 ~/ total;
    if (pct != shown && pct % 5 == 0) {
      shown = pct;
      stdout.write('\r▸ Uploading ${(total / 1048576).toStringAsFixed(1)} MB … $pct%');
    }
  }
  request.add(tail);
  final response = await request.close();
  final body = await response.transform(utf8.decoder).join();
  stdout.writeln();
  final json = (jsonDecode(body.isEmpty ? '{}' : body) as Map).cast<String, dynamic>();
  if (response.statusCode != 202) _fail('The store refused the upload (${response.statusCode}): ${json['message'] ?? body}');
  return json;
}

const _titles = {
  'check': 'Checking the build',
  'fast': 'Preparing fast loading',
  'launch': 'Launch screen and iPhone splash screens',
  'guide': 'Install guide, update prompt, offline page',
  'push': 'Notifications',
  'live': 'Going live',
};
const _marks = {'done': '✓', 'warning': '!', 'failed': '✗', 'skipped': '–', 'running': '…', 'pending': ' '};

Future<void> _follow(HttpClient client, String url, String key) async {
  final printed = <String, String>{};
  while (true) {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.set('Authorization', 'Bearer $key');
    final response = await request.close();
    final job = (jsonDecode(await response.transform(utf8.decoder).join()) as Map).cast<String, dynamic>();
    for (final step in (job['steps'] as List).cast<Map>()) {
      final name = step['name'] as String, state = step['state'] as String;
      if (state == 'pending' || state == 'running' || printed[name] == state) continue;
      printed[name] = state;
      final detail = (step['detail'] as String?)?.isNotEmpty == true ? '  ${step['detail']}' : '';
      stdout.writeln('  ${_marks[state]} ${_titles[name] ?? name}$detail');
    }
    if (job['state'] == 'done') {
      final build = (job['build'] as Map?)?.cast<String, dynamic>();
      stdout.writeln('✓ ${build?['label'] ?? 'Build'} is ready${build?['status'] == 'live' ? ' and live' : ''}.');
      return;
    }
    if (job['state'] == 'failed') _fail('✗ ${(job['error'] as Map?)?['message'] ?? 'Preparing the build failed'}');
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}

Never _fail(String message) {
  stderr.writeln(message);
  exit(1);
}
