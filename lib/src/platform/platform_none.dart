import '../web_context.dart';

AbrovaWebContext readContext() => AbrovaWebContext.native;

Future<bool> promptInstall() async => false;

DateTime? dismissedUntil() => null;

void setDismissedUntil(DateTime until) {}
