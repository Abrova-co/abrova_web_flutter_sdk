# abrova_web

For Flutter web apps that people install on their phone (PWA): where the app runs, and a ready-made
"Add to Home Screen" guide in Persian and English.

## Install

```yaml
dependencies:
  abrova_web:
    hosted: https://center.abrova.ir/api/packages/abrova/pub
    version: ^0.5.4
```

## Install guide

```dart
AbrovaInstallGuide(appName: 'Lino', icon: Image.asset('assets/icon.png'))
```

It shows what is needed where the app runs, and nothing elsewhere:

- iPhone and iPad Safari: Share › Add to Home Screen › open from the icon.
- Android: an Install button (the browser's install prompt), or the menu steps.
- Inside Instagram, Facebook and other apps: open in the browser, with Copy link.
- Installed, on a computer, or in a native build: nothing.

Persian for a `fa` locale, English otherwise; pass `strings:` for your own texts. "Not now" hides it for 7 days.

## Where the app runs

```dart
final where = AbrovaWeb.context;
where.installed;      // opened from the Home Screen
where.installNeed;    // none, iosAddToHomeScreen, androidInstall, openInBrowser
where.inAppBrowser;   // 'Instagram', … or null
```

## New versions

```dart
void main() {
  AbrovaWebUpdates.start(); // version.json now, when the app comes back, and every 10 minutes
  runApp(MaterialApp(
    builder: (context, child) => AbrovaUpdateGate(child: child!), // required updates
    home: …,
  ));
}

AbrovaUpdatePrompt(icon: Image.asset('assets/icon.png')) // "New version available" · Reload · Later
```

Build every deploy with its own build number, so open pages see it (the prompt shows "Version 0.5.1 (build 13)"
when only the build changed):

```bash
flutter build web --release --build-number=13
```

Optional `web/update.json`: `{"minimum": "0.6.0", "notes": {"en": "…", "fa": "…"}}` — below `minimum` the update is
required.

## Launch screen, splash images and offline page

```bash
dart run abrova_push:web_push_setup --root
dart run abrova_web:setup --accent "#1C72C8"
```

From `web/manifest.json` (name, `background_color`, icons) and `--accent`:

- the launch screen in `web/index.html` (icon, name, loading bar, Persian and English), until Flutter's first frame;
- the iPhone and iPad splash images in `web/splash/` with their tags in `web/index.html` (needs Google Chrome;
  `--no-splash` skips them);
- `web/offline.html`, added to the root service worker `web/abrova-push-sw.js`: opening the app with no network
  shows it, and it reloads when the connection is back.

Run both again after upgrading `abrova_push`, and when the manifest or icons change.

## Abrova Store

Publish (a publish key from the Abrova Store console: **Publish keys** at the bottom of the side menu,
https://apps.abrova.ir/console/en/keys):

```bash
ABROVA_STORE_KEY=abs_… dart run abrova_web:publish --app team --live -- --dart-define-from-file=config/app.json
```

It builds the web app, uploads `build/web` and shows the store's preparation steps. `--test` puts the build on the
test address, `--required` makes it a required update, `--notes-fa` / `--notes-en` are its notes, `--no-build` uploads
the build that is there.

Install analytics (anonymous: a random id per device):

```dart
AbrovaWebAnalytics.start(); // the app is the first part of the address: team.abrova.ir → team
AbrovaWebAnalytics.reportPushStatus('allowed'); // after asking for notifications: allowed, denied
```

Opened from Abrova Store (`?from=store`), `AbrovaInstallGuide` continues the store's steps (step 2 of 3), and on the
first start from the Home Screen it shows "It's on your home screen" once.

Docs: https://abrova.ir/docs/push/install-guide
