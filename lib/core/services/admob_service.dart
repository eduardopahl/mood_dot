import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import '../services/premium_service.dart';
import '../../config/admob_config.dart';

class AdMobService {
  static AdMobService? _instance;
  static AdMobService get instance => _instance ??= AdMobService._();

  AdMobService._();

  /// IDs dos anúncios - usa configuração externa
  static String get _bannerAdUnitId =>
      kDebugMode ? AdMobConfig.testBannerAdUnitId : AdMobConfig.bannerAdUnitId;

  static String get _interstitialAdUnitId =>
      kDebugMode
          ? AdMobConfig.testInterstitialAdUnitId
          : AdMobConfig.interstitialAdUnitId;

  // Controle de frequência dos intersticiais
  static DateTime? _lastInterstitialShown;
  static const Duration _interstitialCooldown = Duration(minutes: 3);

  /// Inicializa o AdMob
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await MobileAds.instance.initialize();
    }
  }

  /// Verifica se deve mostrar anúncios
  bool get shouldShowAds {
    // Verifica em tempo real o status premium
    final isPremium = PremiumService.instance.isPremium;
    final shouldShow = Platform.isAndroid && !isPremium;

    if (!shouldShow && isPremium) {
      debugPrint('🏆 Anúncios desativados - Usuário Premium');
    }

    return shouldShow;
  }

  /// Cria um banner ad
  BannerAd? createBannerAd({
    AdSize size = AdSize.banner,
    required Function(Ad ad) onAdLoaded,
    required Function(Ad ad, LoadAdError error) onAdFailedToLoad,
  }) {
    if (!shouldShowAds) return null;

    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
        onAdOpened: (ad) => debugPrint('Banner ad opened'),
        onAdClosed: (ad) => debugPrint('Banner ad closed'),
      ),
    );
  }

  /// Carrega um anúncio intersticial
  Future<InterstitialAd?> loadInterstitialAd() async {
    if (!shouldShowAds) return null;

    InterstitialAd? interstitialAd;

    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          debugPrint('✅ Intersticial carregado com sucesso');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Erro ao carregar intersticial: $error');
        },
      ),
    );

    return interstitialAd;
  }

  /// Mostra intersticial se disponível e dentro do cooldown
  Future<void> showInterstitialAd() async {
    if (!shouldShowAds) return;

    // Verifica cooldown
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(
        _lastInterstitialShown!,
      );
      if (timeSinceLastAd < _interstitialCooldown) {
        debugPrint(
          '⏰ Intersticial em cooldown. Faltam ${_interstitialCooldown - timeSinceLastAd}',
        );
        return;
      }
    }

    try {
      final InterstitialAd? interstitialAd = await loadInterstitialAd();
      if (interstitialAd != null) {
        // Configura callbacks
        interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
          onAdShowedFullScreenContent: (ad) {
            debugPrint('🎬 Intersticial exibido');
            _lastInterstitialShown = DateTime.now();
          },
          onAdDismissedFullScreenContent: (ad) {
            debugPrint('❌ Intersticial fechado');
            ad.dispose();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            debugPrint('💥 Erro ao exibir intersticial: $error');
            ad.dispose();
          },
        );

        // Mostra o anúncio
        await interstitialAd.show();
      }
    } catch (e) {
      debugPrint('💥 Erro geral no intersticial: $e');
    }
  }

  /// Verifica se pode mostrar intersticial (respeitando cooldown)
  bool canShowInterstitial() {
    if (!shouldShowAds) return false;

    if (_lastInterstitialShown == null) return true;

    final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
    return timeSinceLastAd >= _interstitialCooldown;
  }
}
