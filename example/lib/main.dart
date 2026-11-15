import 'package:abrova_web/abrova_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// The install guide in each situation, side by side (?lang=fa for Persian). In your app, use
/// `const AbrovaInstallGuide(appName: 'Your app')`: it picks the situation itself.
void main() => runApp(const Example());

const _iphone =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1';
const _iphone26 =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1';
const _instagram =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 350.0.0.0';
const _android = 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';

const _brand = Color(0xFF1C72C8);
final _icon = Image.network('icons/Icon-192.png', fit: BoxFit.cover);

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    final fa = Uri.base.queryParameters['lang'] == 'fa';
    final name = fa ? 'لینو' : 'Lino';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale(fa ? 'fa' : 'en'),
      supportedLocales: const [Locale('en'), Locale('fa')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF1C72C8)),
      darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF1C72C8), brightness: Brightness.dark),
      themeMode: Uri.base.queryParameters['dark'] == '1' ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(title: const Text('abrova_web')),
        body: ListView(
          children: [
            const _Label('iPhone, Safari tab'),
            AbrovaInstallGuide(appName: name, icon: _icon, accentColor: _brand, context: AbrovaWebContext.fromUserAgent(_iphone, installed: false)),
            const _Label('iPhone, Safari 26 (Share under ⋯)'),
            AbrovaInstallGuide(
              appName: name,
              icon: _icon,
              accentColor: _brand,
              context: AbrovaWebContext.fromUserAgent(_iphone26, installed: false),
            ),
            const _Label('Android, the browser offers Install'),
            AbrovaInstallGuide(
              appName: name,
              icon: _icon,
              accentColor: _brand,
              context: AbrovaWebContext.fromUserAgent(_android, installed: false, canPromptInstall: true),
            ),
            const _Label('Inside Instagram'),
            AbrovaInstallGuide(appName: name, icon: _icon, accentColor: _brand, context: AbrovaWebContext.fromUserAgent(_instagram, installed: false)),
            const _Label('This browser (nothing when installed or on a computer)'),
            AbrovaInstallGuide(appName: name),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Text(text, style: Theme.of(context).textTheme.labelLarge),
      );
}
