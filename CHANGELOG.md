# Changelog

## [0.5.4] - 2026-11-16

### Added
- Install analytics know the store device also when the app was opened or installed without Abrova Store: the store
  leaves its random device id in a cookie on the parent domain (`abrova_sd` on abrova.ir), and the app reports to it
  when the address has no `sd`. Abrova Store can then show Open or Update for this app on that browser.

## [0.5.3] - 2026-11-16

### Fixed
- `abrova_web:publish` and the README point to the right place for publish keys: "Publish keys" at the bottom of
  the Abrova Store console's side menu (https://apps.abrova.ir/console/en/keys).

## [0.5.2] - 2026-11-16

### Fixed
- Persian: the install guide's store label is «از فروشگاه ابرووا» (the brand's spelling).

## [0.5.1] - 2026-11-16

### Fixed
- Store analytics: `open`, `installed` and the install guide's events carry the running build. They wait for
  `version.json` (at most 3 seconds) instead of going out before it is read, so Abrova Store knows which build each
  device runs and no longer offers an update the device already has.

## [0.5.0] - 2026-11-16

### Added
- `dart run abrova_web:publish --app <address>`: builds, uploads `build/web` to Abrova Store and shows its preparation
  steps (`--live`, `--test`, `--required`, `--notes-fa`, `--notes-en`, `--no-build`, `-- <flutter build args>`).
- `AbrovaWebAnalytics`: install analytics for Abrova Store (open, installed, install guide shown and dismissed, reload,
  notification status), anonymous.
- `AbrovaInstallGuide` opened from Abrova Store (`?from=store`): step 1 done, "Step 2 of 3", "From Abrova Store";
  "It's on your home screen" on the first start from the Home Screen. `fromStore` to set it yourself.
- `AbrovaWeb.fromStore`, `AbrovaWeb.firstHomeScreenStart`, `AbrovaWebContext.userAgent`.

### Changed
- `AbrovaInstallStrings` has new texts (`fromStore`, `stepOf`, `continueTo`, `onHomeScreen`, `getStarted`, with English
  defaults) and is no longer a `const` constructor.

## [0.4.0] - 2026-11-15

### Added
- `dart run abrova_web:setup` also writes the launch screen into `web/index.html` (the app's icon with a glow, its
  name, a loading bar, Persian and English, fades out on Flutter's first frame) and the iPhone and iPad splash images
  (`web/splash/`, the same screen, rendered with Google Chrome) with their `apple-touch-startup-image` tags.
  `--no-splash` skips the images.
- The launch screen, splash images and offline page share one look: the background colour with a glow of the accent.

## [0.3.0] - 2026-11-15

### Added
- `dart run abrova_web:setup`: a branded offline page (`web/offline.html`, Persian and English, Try again, reloads
  when the connection is back) from `web/manifest.json`, served by the root service worker `web/abrova-push-sw.js`
  when the app is opened with no network.

## [0.2.1] - 2026-11-15

### Changed
- `AbrovaUpdatePrompt` and `AbrovaUpdateGate` show the build ("Version 0.5.1 (build 13)") when the new deploy has the
  same version as the running one.
- `AbrovaUpdateStrings.versionBuild` (optional): the text for that case; English and Persian built in.

## [0.2.0] - 2026-11-15

### Added
- New versions: `AbrovaWebUpdates.start()` reads `version.json` when the app starts (the version running) and again
  when it comes back to the front and every 10 minutes. `AbrovaUpdatePrompt` shows "New version available" with
  Reload and Later; `AbrovaUpdateGate` covers the app with a required update when an optional `update.json` says
  `minimum` is newer than the running version, with "What's new" notes in Persian or English.
- `AbrovaWebUpdates.runningVersion`: the version running in this page (`package_info_plus` on the web reads the
  server's version.json, already the new one after a deploy).

## [0.1.1] - 2026-11-15

### Changed
- iPhone and iPad steps follow Safari's layout: Safari 26 on iPhone (Share under ⋯ at the bottom), Safari up to 18 on
  iPhone (Share at the bottom), iPad (Share at the top). "In Safari's Share menu:" above the picture of the "Add to Home
  Screen" row, which is a picture, not a button; "scroll down if you don't see it, then tap Add".
- `AbrovaWebContext.isIpad` and `safariVersion` (Safari 26 still reports iOS 18.6 in its user agent).

## [0.1.0] - 2026-11-15

### Added
- `AbrovaInstallGuide`: shows how to install the web app where that is needed — iPhone and iPad Safari (Share › Add
  to Home Screen), Android (the browser's Install prompt, or its menu), an app's in-app browser (open in the browser,
  Copy link) — and nothing when installed, on a computer or in a native build. Persian and English, "Not now" for 7
  days, the app's icon and brand colour.
- `AbrovaWeb.context`: where the app runs (installed, iOS, Android, in-app browser) and what installing needs.
- `AbrovaWeb.promptInstall()`: the browser's install prompt on Android.
