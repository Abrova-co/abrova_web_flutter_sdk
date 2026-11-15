import 'package:abrova_web/abrova_web.dart';
import 'package:flutter_test/flutter_test.dart';

const iPhoneSafari =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1';
const iPhoneSafari26 =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.0 Mobile/15E148 Safari/604.1';
const iPhoneInstagram =
    'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 Instagram 350.0.0.0';
const iPhoneWebView = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148';
const iPad = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15';
const androidChrome =
    'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Mobile Safari/537.36';
const androidWebView =
    'Mozilla/5.0 (Linux; Android 10; K; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/131.0.0.0 Mobile Safari/537.36';
const macChrome = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36';

AbrovaInstallNeed need(String ua, {bool installed = false, int touch = 0}) =>
    AbrovaWebContext.fromUserAgent(ua, installed: installed, maxTouchPoints: touch).installNeed;

void main() {
  test('iPhone Safari tab: Add to Home Screen; installed: nothing', () {
    expect(need(iPhoneSafari), AbrovaInstallNeed.iosAddToHomeScreen);
    expect(need(iPhoneSafari, installed: true), AbrovaInstallNeed.none);
  });

  test('iPad says Macintosh but has a touch screen; a Mac does not', () {
    expect(need(iPad, touch: 5), AbrovaInstallNeed.iosAddToHomeScreen);
    expect(need(iPad), AbrovaInstallNeed.none);
  });

  test('Safari version: 26 says OS 18_6 but Version/26; iPad is an iPad', () {
    expect(AbrovaWebContext.fromUserAgent(iPhoneSafari26, installed: false).safariVersion, 26);
    expect(AbrovaWebContext.fromUserAgent(iPhoneSafari, installed: false).safariVersion, 18);
    expect(AbrovaWebContext.fromUserAgent(iPad, installed: false, maxTouchPoints: 5).isIpad, isTrue);
    expect(AbrovaWebContext.fromUserAgent(iPhoneSafari, installed: false).isIpad, isFalse);
  });

  test('in-app browsers: open in the browser first', () {
    final instagram = AbrovaWebContext.fromUserAgent(iPhoneInstagram, installed: false);
    expect(instagram.installNeed, AbrovaInstallNeed.openInBrowser);
    expect(instagram.inAppBrowser, 'Instagram');
    expect(AbrovaWebContext.fromUserAgent(iPhoneWebView, installed: false).inAppBrowser, 'an app');
    expect(need(androidWebView), AbrovaInstallNeed.openInBrowser);
  });

  test('Android Chrome: install; computers and native builds: nothing', () {
    expect(need(androidChrome), AbrovaInstallNeed.androidInstall);
    expect(need(macChrome), AbrovaInstallNeed.none);
    expect(AbrovaWebContext.native.installNeed, AbrovaInstallNeed.none);
  });
}
