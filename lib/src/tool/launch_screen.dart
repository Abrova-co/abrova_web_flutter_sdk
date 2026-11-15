// Used by `dart run abrova_web:setup` (bin/setup.dart). Plain Dart: no Flutter here.
import 'dart:convert';

import 'offline_page.dart';

/// The app's surface: [OfflineApp.background] with a glow of [OfflineApp.accent] around the icon.
String surfaceGradient(OfflineApp app) =>
    'radial-gradient(120% 80% at 50% 38%, ${mix(app.background, app.accent, 0.3)} 0%, '
    '${mix(app.background, app.accent, 0.12)} 45%, ${app.background} 100%)';

/// Portrait CSS size and pixel ratio of every current iPhone and iPad screen.
const splashDevices = <(int, int, int)>[
  (440, 956, 3), (430, 932, 3), (428, 926, 3), (420, 912, 3), (414, 896, 3), (414, 896, 2), (414, 736, 3),
  (402, 874, 3), (393, 852, 3), (390, 844, 3), (375, 812, 3), (375, 667, 2), (320, 568, 2),
  (1032, 1376, 2), (1024, 1366, 2), (834, 1210, 2), (834, 1194, 2), (834, 1112, 2), (820, 1180, 2),
  (810, 1080, 2), (768, 1024, 2), (744, 1133, 2),
];

String splashFile((int, int, int) d) => 'splash/launch-${d.$1 * d.$3}x${d.$2 * d.$3}.png';

String _attr(String text) =>
    text.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');

const launchBegin = '<!-- abrova_web:launch:begin (dart run abrova_web:setup) -->';
const launchEnd = '<!-- abrova_web:launch:end -->';
const splashBegin = '<!-- abrova_web:splash:begin (dart run abrova_web:setup) -->';
const splashEnd = '<!-- abrova_web:splash:end -->';

String _css(OfflineApp app) => '''
    html, body { margin: 0; height: 100%; background: ${app.background}; }
    #abrova-launch {
      position: fixed; inset: 0; z-index: 10;
      display: flex; flex-direction: column; align-items: center; justify-content: center;
      background: ${surfaceGradient(app)};
      color: #FFFFFF;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Tahoma, sans-serif;
      transition: opacity 280ms ease;
      padding: env(safe-area-inset-top) 24px env(safe-area-inset-bottom);
      box-sizing: border-box;
    }
    #abrova-launch.done { opacity: 0; pointer-events: none; }
    #abrova-launch .logo {
      width: 88px; height: 88px; border-radius: 24px;
      box-shadow: 0 0 0 1px rgba(255, 255, 255, 0.08), 0 12px 40px ${rgba(app.accent, 0.45)};
      animation: abrova-launch-float 2.6s ease-in-out infinite;
    }
    #abrova-launch h1 { margin: 22px 0 6px; font-size: 22px; font-weight: 650; letter-spacing: 0.2px; }
    #abrova-launch p { margin: 0; font-size: 14px; color: rgba(255, 255, 255, 0.62); }
    #abrova-launch .bar {
      position: relative; overflow: hidden; margin-top: 28px;
      width: 168px; height: 4px; border-radius: 4px; background: rgba(255, 255, 255, 0.12);
    }
    #abrova-launch .bar::after {
      content: ""; position: absolute; top: 0; bottom: 0; width: 40%; border-radius: 4px;
      background: linear-gradient(90deg, ${rgba(lighten(app.accent, 0.35), 0)}, ${lighten(app.accent, 0.35)}, ${app.accent});
      animation: abrova-launch-sweep 1.3s ease-in-out infinite;
    }
    @keyframes abrova-launch-float { 50% { transform: translateY(-4px); } }
    @keyframes abrova-launch-sweep { from { left: -40%; } to { left: 100%; } }
    #abrova-launch[dir="rtl"] .bar::after { animation-direction: reverse; }
    @media (prefers-reduced-motion: reduce) {
      #abrova-launch .logo, #abrova-launch .bar::after { animation: none; }
      #abrova-launch .bar::after { left: 30%; }
    }''';

/// The launch screen for web/index.html's body: shown until Flutter draws its first frame, then fades out. Inline only.
/// [iconPath] is the icon next to index.html (it loads with the page).
String launchBlock(OfflineApp app, String iconPath) => '''
  $launchBegin
  <style>${_css(app)}
  </style>
  <div id="abrova-launch" role="status" aria-live="polite">
    <img class="logo" src="${_attr(iconPath)}" alt="">
    <h1>${const HtmlEscape().convert(app.name)}</h1>
    <p id="abrova-launch-text">Getting ready…</p>
    <div class="bar"></div>
  </div>
  <script>
    (function () {
      if (/^fa\\b/i.test(navigator.language || '')) {
        var el = document.getElementById('abrova-launch');
        el.setAttribute('dir', 'rtl');
        el.setAttribute('lang', 'fa');
        document.getElementById('abrova-launch-text').textContent = 'در حال آماده‌سازی…';
      }
      window.addEventListener('flutter-first-frame', function () {
        var launch = document.getElementById('abrova-launch');
        if (!launch) return;
        launch.classList.add('done');
        setTimeout(function () { launch.remove(); }, 320);
      });
    })();
  </script>
  $launchEnd''';

/// The page Chrome renders into each splash image: the launch screen without the moving parts (an image can't move;
/// a frozen bar looks stuck). [iconDataUri] inlines the icon.
String splashPage(OfflineApp app, String iconDataUri) => '''<!doctype html><html><head><meta charset="utf-8"><style>
${_css(app)}
    #abrova-launch .logo { animation: none; }
</style></head><body><div id="abrova-launch"><img class="logo" src="$iconDataUri" alt="">
<h1>${const HtmlEscape().convert(app.name)}</h1></div></body></html>''';

/// The `<link rel="apple-touch-startup-image">` tags for web/index.html's head.
String splashLinks() => [
      '  $splashBegin',
      for (final d in splashDevices)
        '  <link rel="apple-touch-startup-image" href="${splashFile(d)}" media="(device-width: ${d.$1}px) and '
            '(device-height: ${d.$2}px) and (-webkit-device-pixel-ratio: ${d.$3}) and (orientation: portrait)">',
      '  $splashEnd',
    ].join('\n');

String _replaceBetween(String html, String begin, String end, String block, String insertBefore) {
  final start = html.indexOf(begin);
  final stop = html.indexOf(end);
  if (start >= 0 && stop > start) {
    // From the start of the line, so the block's own indent is kept.
    final lineStart = html.lastIndexOf('\n', start) + 1;
    return html.substring(0, lineStart) + block.replaceFirst(RegExp(r'^\n'), '') + html.substring(stop + end.length);
  }
  final at = html.indexOf(insertBefore);
  if (at < 0) throw FormatException('web/index.html has no $insertBefore');
  final lineStart = html.lastIndexOf('\n', at) + 1;
  return '${html.substring(0, lineStart)}${block.replaceFirst(RegExp(r'^\n'), '')}\n${html.substring(lineStart)}';
}

/// [html] with the launch screen (before Flutter's bootstrap script) and, when [withSplash], the splash links (end of
/// head). Run again: the blocks are replaced.
String withLaunchScreen(String html, OfflineApp app, String iconPath, {required bool withSplash}) {
  var out = _replaceBetween(html, launchBegin, launchEnd, launchBlock(app, iconPath), '<script src="flutter_bootstrap.js"');
  if (withSplash) out = _replaceBetween(out, splashBegin, splashEnd, splashLinks(), '</head>');
  return out;
}
