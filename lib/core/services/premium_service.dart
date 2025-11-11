import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class PremiumService {
  static const String _premiumKey = 'is_premium_user';
  static const String _productId =
      'premium_upgrade'; // Configurar no Google Play Console
  static const String premiumPrice = '\$0.99'; // Preço do premium em dólares

  static PremiumService? _instance;
  static PremiumService get instance => _instance ??= PremiumService._();

  PremiumService._();

  SharedPreferences? _prefs;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  // Callback para notificar mudanças de status
  void Function(bool)? _onStatusChanged;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    // Escutar mudanças nas compras
    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (error) => debugPrint('Erro no stream de compras: $error'),
    );

    // Verificar compras pendentes na inicialização
    await _checkPendingPurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }

  /// Verifica se o usuário é premium
  bool get isPremium {
    return _prefs?.getBool(_premiumKey) ?? false;
  }

  /// Define o status premium do usuário
  Future<void> setPremium(bool isPremium) async {
    await _prefs?.setBool(_premiumKey, isPremium);
    debugPrint('🏆 Status Premium atualizado: $isPremium');

    // Notifica mudança de status se callback estiver definido
    _onStatusChanged?.call(isPremium);
  }

  /// Define callback para mudanças de status
  void setStatusChangeCallback(void Function(bool) callback) {
    _onStatusChanged = callback;
  }

  /// Processa atualizações de compra
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchase in purchaseDetailsList) {
      await _handlePurchase(purchase);
    }
  }

  /// Trata cada compra individual
  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.productID == _productId) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Verificar e finalizar a compra
        if (await _verifyPurchase(purchase)) {
          await setPremium(true);
          debugPrint('✅ Premium ativado via compra/restauração');
        }

        // Completar a transação
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('❌ Erro na compra: ${purchase.error}');
      }
    }
  }

  /// Verifica se a compra é válida
  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // Em produção, você deveria verificar a compra com seu servidor
    // Para simplicidade, vamos aceitar todas as compras válidas
    return purchase.productID == _productId;
  }

  /// Verifica compras pendentes na inicialização
  Future<void> _checkPendingPurchases() async {
    await _inAppPurchase.restorePurchases();
    // O stream já vai processar as compras restauradas automaticamente
  }

  /// Inicia o processo de compra do premium
  Future<bool> purchasePremium() async {
    if (kDebugMode) {
      // Em debug, simula compra bem-sucedida
      await setPremium(true);
      return true;
    }

    try {
      // Verificar se o serviço está disponível
      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('❌ In-App Purchase não disponível');
        return false;
      }

      // Buscar detalhes do produto
      const Set<String> productIds = {_productId};
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('❌ Produto não encontrado: ${response.notFoundIDs}');
        return false;
      }

      if (response.productDetails.isEmpty) {
        debugPrint('❌ Nenhum produto disponível');
        return false;
      }

      // Iniciar compra
      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      debugPrint('🛒 Iniciando compra do produto: ${productDetails.title}');
      final success = await _inAppPurchase.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      return success;
    } catch (e) {
      debugPrint('❌ Erro na compra premium: $e');
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    try {
      debugPrint('🔄 Iniciando restauração de compras...');

      final bool available = await _inAppPurchase.isAvailable();
      if (!available) {
        debugPrint('❌ In-App Purchase não disponível para restauração');
        return false;
      }

      await _inAppPurchase.restorePurchases();

      // Dar um tempo para as compras serem processadas
      await Future.delayed(const Duration(seconds: 2));

      if (isPremium) {
        debugPrint('✅ Compras restauradas com sucesso!');
        return true;
      } else {
        debugPrint('ℹ️ Nenhuma compra encontrada para restaurar');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Erro ao restaurar compras: $e');
      return false;
    }
  }

  /// Obtém informações do produto premium
  Future<ProductDetails?> getProductDetails() async {
    try {
      const Set<String> productIds = {_productId};
      final ProductDetailsResponse response = await _inAppPurchase
          .queryProductDetails(productIds);

      if (response.productDetails.isNotEmpty) {
        return response.productDetails.first;
      }
    } catch (e) {
      debugPrint('❌ Erro ao buscar detalhes do produto: $e');
    }
    return null;
  }

  /// Remove o status premium (para testes)
  Future<void> removePremium() async {
    if (kDebugMode) {
      await setPremium(false);
      debugPrint('🧪 Premium removido (modo debug)');
    }
  }
}
