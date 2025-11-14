import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mooddot/core/app_logger.dart';
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
  static const Duration _interstitialCooldown = Duration(minutes: 5);
  static bool _startupGraceOver = false;
  static const Duration _startupGracePeriod = Duration(seconds: 5);
  // Controle para evitar mostrar/abrir múltiplos intersticiais simultaneamente
  static bool _isShowingInterstitial = false;
  static bool _isLoadingInterstitial = false;
  static const String _prefsKeyLastInterstitial = 'last_interstitial_shown';

  /// Inicializa o AdMob
  static Future<void> initialize() async {
    if (Platform.isAndroid) {
      await MobileAds.instance.initialize();
    }
    // Inicia período de carência para evitar mostrar intersticiais imediatamente
    _startupGraceOver = false;
    Future.delayed(_startupGracePeriod, () {
      _startupGraceOver = true;
      AppLogger.d('⏱️ Startup grace period over — interstitials allowed');
    });

    // Load persisted last interstitial timestamp (to respect cooldown across restarts)
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getInt(_prefsKeyLastInterstitial);
      if (stored != null) {
        _lastInterstitialShown = DateTime.fromMillisecondsSinceEpoch(stored);
        AppLogger.d(
          '🔁 Loaded last interstitial timestamp: $_lastInterstitialShown',
        );
      }
    } catch (e) {
      AppLogger.w('⚠️ Failed to load last interstitial timestamp: $e');
    }
  }

  /// Verifica se deve mostrar anúncios
  bool get shouldShowAds {
    // Verifica em tempo real o status premium
    final isPremium = PremiumService.instance.isPremium;
    final shouldShow = Platform.isAndroid && !isPremium;

    if (!shouldShow && isPremium) {
      AppLogger.d('🏆 Anúncios desativados - Usuário Premium');
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
        onAdOpened: (ad) => AppLogger.d('Banner ad opened'),
        onAdClosed: (ad) => AppLogger.d('Banner ad closed'),
      ),
    );
  }

  /// Carrega um anúncio intersticial
  Future<InterstitialAd?> loadInterstitialAd() async {
    AppLogger.d(
      '🔎 loadInterstitialAd() called — shouldShowAds: ${shouldShowAds}, startupGraceOver: $_startupGraceOver, isLoading: $_isLoadingInterstitial, isShowing: $_isShowingInterstitial, lastShown: $_lastInterstitialShown',
    );

    if (!shouldShowAds) {
      AppLogger.d('🚫 shouldShowAds=false — skipping load');
      return null;
    }

    // Avoid starting another concurrent load
    if (_isLoadingInterstitial) {
      AppLogger.d('⏳ Intersticial já em carregamento — skipping new load');
      return null;
    }

    _isLoadingInterstitial = true;

    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          AppLogger.d('✅ Intersticial carregado com sucesso');
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          AppLogger.e('❌ Erro ao carregar intersticial: $error');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    try {
      // Aguarda o carregamento com timeout razoável
      final InterstitialAd? ad = await completer.future.timeout(
        const Duration(seconds: 8),
      );
      return ad;
    } catch (e) {
      AppLogger.w('⏳ Timeout carregando intersticial: $e');
      return null;
    } finally {
      _isLoadingInterstitial = false;
    }
  }

  /// Mostra intersticial se disponível e dentro do cooldown
  Future<void> showInterstitialAd() async {
    if (!shouldShowAds) return;
    AppLogger.d(
      '🔎 showInterstitialAd() called — shouldShowAds: ${shouldShowAds}, startupGraceOver: $_startupGraceOver, isLoading: $_isLoadingInterstitial, isShowing: $_isShowingInterstitial, lastShown: $_lastInterstitialShown',
    );

    // Don't show interstitials during the startup grace period (avoid showing on app open)
    if (!_startupGraceOver) {
      AppLogger.d(
        '⏳ Startup grace period active — skipping interstitial on app open',
      );
      return;
    }
    // If already showing or loading, skip
    if (_isShowingInterstitial || _isLoadingInterstitial) {
      AppLogger.d('⏳ Intersticial já sendo mostrado/carregado — skipping show');
      return;
    }

    // Verifica cooldown
    if (_lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(
        _lastInterstitialShown!,
      );
      if (timeSinceLastAd < _interstitialCooldown) {
        AppLogger.d(
          '⏰ Intersticial em cooldown. Faltam ${_interstitialCooldown - timeSinceLastAd}',
        );
        return;
      }
    }

    try {
      final InterstitialAd? interstitialAd = await loadInterstitialAd();

      if (interstitialAd == null) return;

      // Configura callbacks
      interstitialAd.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          AppLogger.d('🎬 Intersticial exibido');
          _lastInterstitialShown = DateTime.now();
          // Persist timestamp so cooldown survives app restarts
          try {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt(
                _prefsKeyLastInterstitial,
                _lastInterstitialShown!.millisecondsSinceEpoch,
              );
            });
          } catch (e) {
            AppLogger.w('⚠️ Failed to persist last interstitial timestamp: $e');
          }
          _isShowingInterstitial = true;
        },
        onAdDismissedFullScreenContent: (ad) {
          AppLogger.d('❌ Intersticial fechado');
          try {
            ad.dispose();
          } catch (_) {}
          _isShowingInterstitial = false;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          AppLogger.e('💥 Erro ao exibir intersticial: $error');
          try {
            ad.dispose();
          } catch (_) {}
          _isShowingInterstitial = false;
        },
      );

      // Mostra o anúncio
      await interstitialAd.show();
    } catch (e) {
      AppLogger.e('💥 Erro geral no intersticial: $e');
      _isShowingInterstitial = false;
      _isLoadingInterstitial = false;
    }
  }

  /// Verifica se pode mostrar intersticial (respeitando cooldown)
  bool canShowInterstitial() {
    if (!shouldShowAds) return false;

    // Respect startup grace period
    if (!_startupGraceOver) return false;

    if (_lastInterstitialShown == null) return true;

    final timeSinceLastAd = DateTime.now().difference(_lastInterstitialShown!);
    return timeSinceLastAd >= _interstitialCooldown;
  }
}
