/// Abrova Web: helpers for Flutter web apps that people install on their phone (PWA) — where the app runs, a
/// ready-made "Add to Home Screen" guide, and new versions (update prompt, required updates).
library;

export 'src/install_guide.dart' show AbrovaInstallGuide;
export 'src/install_strings.dart' show AbrovaInstallStrings;
export 'src/update_prompt.dart' show AbrovaUpdateGate, AbrovaUpdatePrompt;
export 'src/update_strings.dart' show AbrovaUpdateStrings;
export 'src/updates.dart' show AbrovaUpdateInfo, AbrovaWebUpdates, compareVersions;
export 'src/web_context.dart' show AbrovaInstallNeed, AbrovaWeb, AbrovaWebContext;
