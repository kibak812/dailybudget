import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:daily_pace/core/services/ad_service.dart';

/// 배너 광고 위젯
/// 화면 하단에 고정되는 배너 광고를 표시
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  int _retryCount = 0;
  static const int _maxRetries = 2;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadAd();
  }

  /// SDK 초기화 완료 후 광고 로드 (race condition 방지)
  Future<void> _initializeAndLoadAd() async {
    await AdService().ensureInitialized();
    if (mounted) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = AdService().createBannerAd(
      onAdLoaded: (ad) {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
            _retryCount = 0;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: ${error.message}');
        ad.dispose();
        _bannerAd = null;
        _retryWithBackoff();
      },
    );
    _bannerAd?.load();
  }

  /// 지수 백오프로 재시도 (최대 2회)
  void _retryWithBackoff() {
    if (_retryCount >= _maxRetries || !mounted) return;

    _retryCount++;
    final delay = Duration(seconds: _retryCount * 2); // 2초, 4초
    debugPrint('Retrying ad load in ${delay.inSeconds}s (attempt $_retryCount/$_maxRetries)');

    Future.delayed(delay, () {
      if (mounted) {
        _loadAd();
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      // 광고 로딩 중이거나 실패 시 완전히 숨김
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
