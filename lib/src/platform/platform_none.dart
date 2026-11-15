import '../web_context.dart';

AbrovaWebContext readContext() => AbrovaWebContext.native;

Future<bool> promptInstall() async => false;

DateTime? dismissedUntil() => null;

void setDismissedUntil(DateTime until) {}

Future<String?> fetchText(String path) async => null;

void onVisible(void Function() callback) {}

void reloadPage() {}

String? storageGet(String key) => null;

void storageSet(String key, String value) {}

String currentUrl() => '';

String referrer() => '';

void postJson(String url, String body) {}
