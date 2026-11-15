import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'platform/platform.dart' as platform;
import 'updates.dart';
import 'web_context.dart';

/// Install analytics for Abrova Store: anonymous events (a random id per device, no personal data) about how people
/// open and install the app. Off until [start]; does nothing outside the web.
///
/// ```dart
/// AbrovaWebAnalytics.start(); // app = the first part of the address (team.abrova.ir → team)
/// ```
abstract final class AbrovaWebAnalytics {
  static const _defaultApi = String.fromEnvironment('ABROVA_STORE_API', defaultValue: 'https://apps.abrova.ir/api');
  static const _deviceKey = 'abrova_web_device';
  static const _storeDeviceKey = 'abrova_web_store_device';
  static const _installedKey = 'abrova_web_installed';

  static String? _app;
  static Uri? _api;
  static final _sent = <String>{};

  /// For tests: what was sent.
  @visibleForTesting
  static void Function(String url, String body) send = platform.postJson;

  static bool get started => _app != null;

  /// Starts reporting: `open` now, `installed` on the first start from the home screen, then the install guide's and
  /// the update prompt's events. [app] defaults to the first part of the address (`team-test` → `team`).
  static void start({String? app, Uri? api}) {
    if (!kIsWeb || _app != null) return;
    final url = Uri.tryParse(platform.currentUrl());
    _app = app ?? url?.host.split('.').first.replaceFirst(RegExp(r'-test$'), '');
    _api = api ?? Uri.parse(_defaultApi);
    if (_app == null || _app!.isEmpty) return;
    final sd = url?.queryParameters['sd'];
    if (sd != null && RegExp(r'^[A-Za-z0-9_-]{8,64}$').hasMatch(sd)) platform.storageSet(_storeDeviceKey, sd);
    final installed = AbrovaWeb.context.installed;
    track('open', standalone: installed);
    if (installed && platform.storageGet(_installedKey) == null) {
      platform.storageSet(_installedKey, DateTime.now().toIso8601String());
      track('installed', standalone: true);
    }
  }

  /// Sends one event. [once]: at most once per page load (the install guide shown).
  static void track(String name, {bool? standalone, String? value, bool once = false}) {
    if (_app == null || _api == null) return;
    if (once && !_sent.add(name)) return;
    final ctx = AbrovaWeb.context;
    final ua = ctx.userAgent;
    final ios = RegExp(r'OS (\d+)_(\d+)').firstMatch(ua);
    final build = int.tryParse((AbrovaWebUpdates.runningVersion ?? '').split('+').last);
    final event = <String, Object?>{
      'app': _app,
      'name': name,
      'device': _device(),
      'sd': platform.storageGet(_storeDeviceKey),
      'standalone': standalone ?? ctx.installed,
      'platform': ctx.isIos ? 'ios' : ctx.isAndroid ? 'android' : 'desktop',
      if (ctx.isIos && ios != null) 'os': '${ios.group(1)}.${ios.group(2)}',
      'source': _source(),
      if (build != null) 'build': build,
      if (value != null) 'value': value,
    }..removeWhere((_, v) => v == null);
    send('${_api.toString().replaceAll(RegExp(r'/+$'), '')}/v1/events', jsonEncode({'events': [event]}));
  }

  /// "Notifications allowed/denied/not asked", for the console (call it after asking, e.g. with Abrova Push's status).
  static void reportPushStatus(String status) => track('push_status', value: status);

  static String _device() {
    final known = platform.storageGet(_deviceKey);
    if (known != null) return known;
    final r = Random.secure();
    final id = List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    platform.storageSet(_deviceKey, id);
    return id;
  }

  static String _source() {
    final url = Uri.tryParse(platform.currentUrl());
    if (url?.queryParameters['from'] == 'store') return 'store';
    final ref = platform.referrer().toLowerCase();
    if (ref.contains('t.me') || ref.contains('telegram')) return 'telegram';
    if (ref.contains('instagram')) return 'instagram';
    if (ref.contains('whatsapp')) return 'whatsapp';
    return ref.isEmpty ? 'direct' : 'other';
  }

  /// For tests: reporting on, without a browser.
  @visibleForTesting
  static void startForTest({required String app, required Uri api}) {
    _app = app;
    _api = api;
  }

  @visibleForTesting
  static void reset() {
    _app = null;
    _api = null;
    _sent.clear();
    send = platform.postJson;
  }
}
