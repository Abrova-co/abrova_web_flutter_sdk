import 'dart:convert';

import 'package:abrova_web/abrova_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late List<(String, Map<String, dynamic>)> sent;
  setUp(() {
    AbrovaWebAnalytics.reset();
    sent = [];
    AbrovaWebAnalytics.send = (url, body) => sent.add((url, jsonDecode(body) as Map<String, dynamic>));
  });

  test('off until started', () {
    AbrovaWebAnalytics.track('open');
    expect(sent, isEmpty);
  });

  test('an event goes to the store API with the app and no personal data', () {
    AbrovaWebAnalytics.startForTest(app: 'team', api: Uri.parse('https://apps.abrova.ir/api/'));
    AbrovaWebAnalytics.track('open', standalone: true);
    expect(sent.single.$1, 'https://apps.abrova.ir/api/v1/events');
    final e = (sent.single.$2['events'] as List).single as Map<String, dynamic>;
    expect(e['app'], 'team');
    expect(e['name'], 'open');
    expect(e['standalone'], true);
    expect(e.keys, isNot(contains('email')));
  });

  test('once: the install guide counts one showing per page', () {
    AbrovaWebAnalytics.startForTest(app: 'team', api: Uri.parse('http://127.0.0.1:8091'));
    AbrovaWebAnalytics.track('guide_shown', once: true);
    AbrovaWebAnalytics.track('guide_shown', once: true);
    expect(sent, hasLength(1));
    expect(sent.single.$1, 'http://127.0.0.1:8091/v1/events');
  });

  testWidgets('opened from Abrova Store: step 1 done, step 2 of 3, the store pill', (tester) async {
    const iphone = AbrovaWebContext(isWeb: true, isIos: true, isAndroid: false, installed: false, safariVersion: 18);
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: const Scaffold(body: SingleChildScrollView(child: AbrovaInstallGuide(appName: 'Team', context: iphone, fromStore: true))),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Step 2 of 3'), findsOneWidget);
    expect(find.text('From Abrova Store'), findsOneWidget);
    expect(find.text('Continue to Team'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(find.text('Open Team from its new icon'), findsNothing);
  });
}
