import 'package:in_app_purchase/in_app_purchase.dart';
import '../app_logger.dart';

class InAppPurchaseService {
  static final InAppPurchaseService instance = InAppPurchaseService._();
  InAppPurchaseService._();

  final InAppPurchase _iap = InAppPurchase.instance;
  static const String _premiumProductId = 'mooddot_premium_noads';

  Future<bool> buyPremium() async {
    final available = await _iap.isAvailable();
    if (!available) {
      AppLogger.e('In-app purchase não disponível');
      return false;
    }

    final products = await _iap.queryProductDetails({_premiumProductId});
    if (products.notFoundIDs.isNotEmpty) {
      AppLogger.e('Produto não encontrado: $_premiumProductId');
      return false;
    }

    final productDetails = products.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: productDetails);

    _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // O resultado real da compra deve ser tratado via listener de compras
    // Aqui retornamos true para indicar que o fluxo foi iniciado
    return true;
  }

  Future<bool> restorePurchases() async {
    final available = await _iap.isAvailable();
    if (!available) return false;
    await _iap.restorePurchases();
    // O resultado real da restauração deve ser tratado via listener de compras
    return true;
  }
}
