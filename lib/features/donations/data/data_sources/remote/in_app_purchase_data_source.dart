import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;

abstract class InAppPurchaseDataSource {
  Future<bool> isAvailable();
  Future<iap.ProductDetailsResponse> queryProductDetails(Set<String> productIds);
  Future<bool> buyNonConsumable(iap.ProductDetails productDetails);
  Stream<List<iap.PurchaseDetails>> get purchaseStream;
  Future<void> completePurchase(iap.PurchaseDetails purchaseDetails);
  Future<void> restorePurchases();
  void dispose();
}

class InAppPurchaseDataSourceImpl implements InAppPurchaseDataSource {
  final iap.InAppPurchase _inAppPurchase;
  late StreamSubscription<List<iap.PurchaseDetails>> _subscription;
  final StreamController<List<iap.PurchaseDetails>> _purchaseController = 
      StreamController<List<iap.PurchaseDetails>>.broadcast();

  InAppPurchaseDataSourceImpl({
    iap.InAppPurchase? inAppPurchase,
  }) : _inAppPurchase = inAppPurchase ?? iap.InAppPurchase.instance {
    _initializePurchaseStream();
  }

  void _initializePurchaseStream() {
    _subscription = _inAppPurchase.purchaseStream.listen(
      (List<iap.PurchaseDetails> purchaseDetailsList) {
        _purchaseController.add(purchaseDetailsList);
      },
      onError: (error) {
        _purchaseController.addError(error);
      },
    );
  }

  @override
  Future<bool> isAvailable() async {
    return await _inAppPurchase.isAvailable();
  }

  @override
  Future<iap.ProductDetailsResponse> queryProductDetails(Set<String> productIds) async {
    return await _inAppPurchase.queryProductDetails(productIds);
  }

  @override
  Future<bool> buyNonConsumable(iap.ProductDetails productDetails) async {
    final iap.PurchaseParam purchaseParam = iap.PurchaseParam(
      productDetails: productDetails,
    );
    
    return await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  @override
  Stream<List<iap.PurchaseDetails>> get purchaseStream => _purchaseController.stream;

  @override
  Future<void> completePurchase(iap.PurchaseDetails purchaseDetails) async {
    await _inAppPurchase.completePurchase(purchaseDetails);
  }

  @override
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  @override
  void dispose() {
    _subscription.cancel();
    _purchaseController.close();
  }
}

