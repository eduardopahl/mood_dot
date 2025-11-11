import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter/foundation.dart';

class PremiumService {
  static const String _premiumKey = 'is_premium_user';
  static const String _productId =
      'premium_upgrade'; // Será configurado no Google Play Console
  static const String premiumPrice = '\$0.99'; // Preço do premium em dólares

  static PremiumService? _instance;
  static PremiumService get instance => _instance ??= PremiumService._();

  PremiumService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Verifica se o usuário é premium
  bool get isPremium {
    return _prefs?.getBool(_premiumKey) ?? false;
  }

  /// Define o status premium do usuário
  Future<void> setPremium(bool isPremium) async {
    await _prefs?.setBool(_premiumKey, isPremium);
  }

  /// Inicia o processo de compra do premium
  Future<bool> purchasePremium() async {
    if (kDebugMode) {
      // Em debug, simula compra bem-sucedida
      await setPremium(true);
      return true;
    }

    try {
      final bool available = await InAppPurchase.instance.isAvailable();
      if (!available) {
        return false;
      }

      const Set<String> productIds = <String>{_productId};
      final ProductDetailsResponse response = await InAppPurchase.instance
          .queryProductDetails(productIds);

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Produto premium não encontrado: ${response.notFoundIDs}');
        return false;
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      final bool purchaseResult = await InAppPurchase.instance.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (purchaseResult) {
        await setPremium(true);
      }

      return purchaseResult;
    } catch (e) {
      debugPrint('Erro na compra premium: $e');
      return false;
    }
  }

  /// Restaura compras anteriores
  Future<bool> restorePurchases() async {
    try {
      await InAppPurchase.instance.restorePurchases();
      // Verificar se alguma compra foi restaurada
      // Por simplicidade, vamos verificar manualmente
      return isPremium;
    } catch (e) {
      debugPrint('Erro ao restaurar compras: $e');
      return false;
    }
  }

  /// Remove o status premium (para testes)
  Future<void> removePremium() async {
    if (kDebugMode) {
      await setPremium(false);
    }
  }
}
