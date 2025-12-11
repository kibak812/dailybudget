import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스
/// 배너 광고 로드 및 관리
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  /// AdMob SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('AdMob SDK initialized');
  }

  /// 배너 광고 단위 ID
  /// 디버그 모드에서는 테스트 ID 사용
  /// 프로덕션 ID는 --dart-define=ADMOB_BANNER_ID=xxx 로 주입
  String get bannerAdUnitId {
    if (kDebugMode) {
      // 테스트 광고 ID (개발용)
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    // 프로덕션 광고 ID (빌드 타임에 주입)
    const prodBannerId = String.fromEnvironment('ADMOB_BANNER_ID');
    if (prodBannerId.isEmpty) {
      // 프로덕션 빌드에 광고 ID가 없으면 테스트 ID 사용 (광고 수익 없음)
      debugPrint('Warning: ADMOB_BANNER_ID not set, using test ad');
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    return prodBannerId;
  }

  /// 배너 광고 생성
  BannerAd createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    );
  }
}
