import 'dart:developer';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/material.dart'; // Import the correct package for VoidCallback
import 'package:get/get.dart';
import 'package:lexibrowser/controllers/nativeadcontroller.dart';
import 'package:lexibrowser/helpers/messages.dart';
import 'package:lexibrowser/helpers/remoteconfig.dart';
class AdHelper {
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }
  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;
  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;
  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');
    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request:const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          //ad listener
          ad.fullScreenContentCallback =
              FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
                _resetInterstitialAd();
                precacheInterstitialAd();
              });
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  static void showInterstitialAd({required VoidCallback onComplete}) {
    if (Config.hideAds)
    {
      onComplete;
      return;
    }
    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }
    MyMessages.progress();
    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
              _resetInterstitialAd();
              precacheInterstitialAd();
            },
          );
          Get.back();
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          onComplete;
        },
      ),
    );
  }
  static void precacheNativeAd() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');
    if(Config.hideAds)
    {
      return;
    }

    _nativeAd = NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            _nativeAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            _resetNativeAd();
            log('$NativeAd failed to load: $error');
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle:
        NativeTemplateStyle(templateType: TemplateType.small))
      ..load();
  }

  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  static NativeAd? loadNativeAd(NativeAdController adController) {
    if (Config.hideAds)
    {
      return null;
    }
    if (_nativeAdLoaded && _nativeAd != null) {
      adController.adLoaded.value = true;
      return _nativeAd;
    }
    return NativeAd(
        adUnitId: Config.nativeAd,
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            log('$NativeAd loaded.');
            adController.adLoaded.value=true;
            _resetNativeAd();
            precacheNativeAd();
          },
          onAdFailedToLoad: (ad, error) {
            // Dispose the ad here to free resources.
            log('$NativeAd failed to load: $error');
            _resetNativeAd();
          },
        ),
        request: const AdRequest(),
        // Styling
        nativeTemplateStyle: NativeTemplateStyle(
          templateType: TemplateType.small,))
      ..load();
  }
  static AppOpenAd? loadAppOpen() {
    if(Config.hideAds) return null;
    AppOpenAd? appOpenAd;
    AppOpenAd.load(
      adUnitId: Config.openAppAd,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
          appOpenAd = ad;
        },
        onAdFailedToLoad: (error) {
          Get.back();
        },
      ),
    );
    return appOpenAd;
  }
}