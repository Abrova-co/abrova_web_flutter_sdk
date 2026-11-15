/// The texts of [AbrovaInstallGuide]. English and Persian are built in; pass your own for other wording or languages.
class AbrovaInstallStrings {
  const AbrovaInstallStrings({
    required this.subtitle,
    required this.featureNotifications,
    required this.featureFast,
    required this.featureFullScreen,
    required this.menuAddToHome,
    required this.title,
    required this.benefit,
    required this.iosShare,
    required this.iosShareIpad,
    required this.iosShareMore,
    required this.menuCaption,
    required this.iosAdd,
    required this.openFromIcon,
    required this.androidMenu,
    required this.androidAdd,
    required this.install,
    required this.inAppTitle,
    required this.inAppBody,
    required this.copyLink,
    required this.linkCopied,
    required this.notNow,
  });

  /// Under the app name in the header: "Install the app".
  final String subtitle;
  final String featureNotifications;
  final String featureFast;
  final String featureFullScreen;

  /// The iPhone menu row the user looks for (iOS shows it in English on many Iranian phones).
  final String menuAddToHome;

  /// "Add {app} to your Home Screen".
  final String Function(String app) title;

  /// Why: notifications, faster opening.
  final String benefit;
  /// iPhone, Safari up to 18: the Share button at the bottom.
  final String iosShare;

  /// iPad: the Share button at the top.
  final String iosShareIpad;

  /// iPhone, Safari 26 and later: Share is under ⋯.
  final String iosShareMore;

  /// Above the picture of the menu row.
  final String menuCaption;
  final String iosAdd;

  /// "Open {app} from its new icon".
  final String Function(String app) openFromIcon;
  final String androidMenu;
  final String androidAdd;
  final String install;

  /// "This page is open inside {browser}".
  final String Function(String browser) inAppTitle;
  final String inAppBody;
  final String copyLink;
  final String linkCopied;
  final String notNow;

  static final en = AbrovaInstallStrings(
    subtitle: 'Install the app',
    featureNotifications: 'Notifications',
    featureFast: 'Opens instantly',
    featureFullScreen: 'Full screen',
    menuAddToHome: 'Add to Home Screen',
    title: (app) => 'Add $app to your Home Screen',
    benefit: 'Get notifications and open it faster, like an app.',
    iosShare: 'Tap the Share button at the bottom of Safari',
    iosShareIpad: 'Tap the Share button at the top of Safari',
    iosShareMore: 'Tap ⋯ at the bottom of Safari, then Share',
    menuCaption: 'In Safari’s Share menu:',
    iosAdd: 'Choose “Add to Home Screen” (scroll down if you don’t see it), then tap Add',
    openFromIcon: (app) => 'Open $app from its new icon',
    androidMenu: 'Tap the browser menu ⋮',
    androidAdd: 'Choose “Install app” or “Add to Home screen”',
    install: 'Install',
    inAppTitle: (browser) => 'This page is open inside $browser',
    inAppBody: 'To install it, open it in Safari or Chrome: tap the menu (⋯) and choose “Open in browser”, or copy the link and paste it there.',
    copyLink: 'Copy link',
    linkCopied: 'Link copied',
    notNow: 'Not now',
  );

  static final fa = AbrovaInstallStrings(
    subtitle: 'نصب اپ',
    featureNotifications: 'اعلان‌ها',
    featureFast: 'باز شدن فوری',
    featureFullScreen: 'تمام‌صفحه',
    menuAddToHome: 'Add to Home Screen',
    title: (app) => '$app را به صفحه‌ی اصلی اضافه کنید',
    benefit: 'اعلان‌ها را دریافت کنید و مثل یک اپ سریع‌تر بازش کنید.',
    iosShare: 'پایین Safari روی دکمه‌ی اشتراک‌گذاری (Share) بزنید',
    iosShareIpad: 'بالای Safari روی دکمه‌ی اشتراک‌گذاری (Share) بزنید',
    iosShareMore: 'پایین Safari روی ⋯ بزنید، سپس Share',
    menuCaption: 'در منوی Share سافاری:',
    iosAdd: '«Add to Home Screen» (افزودن به صفحه‌ی اصلی) را انتخاب کنید (اگر نمی‌بینید پایین بروید)، سپس Add را بزنید',
    openFromIcon: (app) => '$app را از آیکون تازه‌اش باز کنید',
    androidMenu: 'روی منوی مرورگر ⋮ بزنید',
    androidAdd: '«Install app» یا «Add to Home screen» را انتخاب کنید',
    install: 'نصب',
    inAppTitle: (browser) => browser == 'an app' ? 'این صفحه داخل یک اپ دیگر باز شده' : 'این صفحه داخل $browser باز شده',
    inAppBody: 'برای نصب، آن را در Safari یا Chrome باز کنید: روی منو (⋯) بزنید و «Open in browser» را انتخاب کنید، یا لینک را کپی کنید و آنجا باز کنید.',
    copyLink: 'کپی لینک',
    linkCopied: 'لینک کپی شد',
    notNow: 'بعداً',
  );

  /// Persian for a `fa` locale, else English.
  static AbrovaInstallStrings forLanguage(String languageCode) => languageCode == 'fa' ? fa : en;
}
