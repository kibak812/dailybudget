import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스
/// 배너 광고 로드 및 관리
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  Future<void>? _initializeFuture;

  /// 초기화 완료 여부
  bool get isInitialized => _isInitialized;

  /// AdMob SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;
    debugPrint('AdMob SDK initialized');
  }

  /// 초기화 완료 보장 (여러 곳에서 호출해도 한 번만 실행)
  Future<void> ensureInitialized() {
    _initializeFuture ??= initialize();
    return _initializeFuture!;
  }

  /// 배너 광고 단위 ID
  /// 디버그 모드에서는 테스트 ID 사용
  /// 릴리스 모드에서는 프로덕션 ID 사용
  String get bannerAdUnitId {
    if (kDebugMode) {
      // 테스트 광고 ID (개발용)
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    // 프로덕션 광고 ID
    return 'ca-app-pub-1068771440265964/1240692725';
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
