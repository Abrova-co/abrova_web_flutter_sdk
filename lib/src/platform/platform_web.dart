import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import '../web_context.dart';

const _dismissKey = 'abrova_web_install_dismissed_until';

/// The browser's install prompt (Android Chrome and Edge), kept from its `beforeinstallprompt` event.
JSObject? _installEvent;
bool _listening = false;

void _listen() {
  if (_listening) return;
  _listening = true;
  // A page can keep the event before Flutter starts (see the README); take it from there too.
  final early = globalContext['abrovaInstallPrompt'];
  if (early != null && early.isA<JSObject>()) _installEvent = early as JSObject;
  web.window.addEventListener(
    'beforeinstallprompt',
    ((web.Event event) {
      event.preventDefault();
      _installEvent = event as JSObject;
    }).toJS,
  );
  web.window.addEventListener('appinstalled', ((web.Event _) => _installEvent = null).toJS);
}

AbrovaWebContext readContext() {
  _listen();
  final navigator = web.window.navigator;
  final installed = web.window.matchMedia('(display-mode: standalone)').matches ||
      (navigator as JSObject).getProperty<JSAny?>('standalone'.toJS).dartify() == true;
  return AbrovaWebContext.fromUserAgent(
    navigator.userAgent,
    installed: installed,
    maxTouchPoints: navigator.maxTouchPoints,
    canPromptInstall: _installEvent != null,
  );
}

Future<bool> promptInstall() async {
  _listen();
  final event = _installEvent;
  if (event == null) return false;
  _installEvent = null; // a prompt can be shown once
  event.callMethod<JSAny?>('prompt'.toJS);
  final choice = await (event['userChoice'] as JSPromise<JSObject>).toDart;
  return (choice['outcome'] as JSString?)?.toDart == 'accepted';
}

DateTime? dismissedUntil() {
  try {
    final value = web.window.localStorage.getItem(_dismissKey);
    final ms = value == null ? null : int.tryParse(value);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  } catch (_) {
    return null; // storage blocked
  }
}

void setDismissedUntil(DateTime until) {
  try {
    web.window.localStorage.setItem(_dismissKey, '${until.millisecondsSinceEpoch}');
  } catch (_) {
    // storage blocked: the guide comes back next time
  }
}

/// [path] next to the app (its `<base href>`), never from a cache. Null when it can't be read.
Future<String?> fetchText(String path) async {
  try {
    final url = Uri.parse(web.document.baseURI).resolve(path).replace(queryParameters: {
      't': '${DateTime.now().millisecondsSinceEpoch}',
    });
    final response = await web.window.fetch(url.toString().toJS, web.RequestInit(cache: 'no-store')).toDart;
    if (!response.ok) return null;
    return (await response.text().toDart).toDart;
  } catch (_) {
    return null;
  }
}

/// Calls [callback] each time the page comes back to the front.
void onVisible(void Function() callback) {
  web.document.addEventListener(
    'visibilitychange',
    ((web.Event _) {
      if (web.document.visibilityState == 'visible') callback();
    }).toJS,
  );
}

void reloadPage() => web.window.location.reload();

String? storageGet(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}

void storageSet(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {
    // storage blocked: nothing remembered
  }
}

String currentUrl() => web.window.location.href;

String referrer() => web.document.referrer;

/// Fire and forget, kept alive when the page goes away.
void postJson(String url, String body) {
  try {
    web.window.fetch(
      url.toJS,
      web.RequestInit(method: 'POST', body: body.toJS, keepalive: true, headers: {'Content-Type': 'application/json'}.jsify() as web.HeadersInit),
    );
  } catch (_) {
    // offline: the event is lost, nothing breaks
  }
}
