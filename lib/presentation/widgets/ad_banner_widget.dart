import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../core/services/admob_service.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize size;
  final EdgeInsets margin;

  const AdBannerWidget({
    Key? key,
    this.size = AdSize.banner,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
  }) : super(key: key);

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdMobService.instance.createBannerAd(
      size: widget.size,
      onAdLoaded: (ad) {
        setState(() {
          _isLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('Banner ad failed to load: $error');
        ad.dispose();
        setState(() {
          _bannerAd = null;
        });
      },
    );

    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    // Se não deve mostrar anúncios ou não carregou, não mostra nada
    if (_bannerAd == null || !_isLoaded) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: widget.margin,
      alignment: Alignment.center,
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.2),
        ),
        color: Theme.of(context).cardColor,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
