import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

abstract class DonationLocalDataSource {
  Future<void> savePurchase(String productId, String transactionId, DateTime purchaseDate);
  Future<List<String>> getPurchaseHistory();
  Future<bool> hasMadePurchase();
  Future<void> clearPurchaseHistory();
}

class DonationLocalDataSourceImpl implements DonationLocalDataSource {
  static const String _purchaseHistoryKey = 'donation_purchase_history';
  
  final SharedPreferences sharedPreferences;

  DonationLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<void> savePurchase(String productId, String transactionId, DateTime purchaseDate) async {
    final purchases = await getPurchaseHistory();
    final purchaseData = {
      'productId': productId,
      'transactionId': transactionId,
      'purchaseDate': purchaseDate.toIso8601String(),
    };
    
    purchases.add(jsonEncode(purchaseData));
    await sharedPreferences.setStringList(_purchaseHistoryKey, purchases);
  }

  @override
  Future<List<String>> getPurchaseHistory() async {
    return sharedPreferences.getStringList(_purchaseHistoryKey) ?? [];
  }

  @override
  Future<bool> hasMadePurchase() async {
    final purchases = await getPurchaseHistory();
    return purchases.isNotEmpty;
  }

  @override
  Future<void> clearPurchaseHistory() async {
    await sharedPreferences.remove(_purchaseHistoryKey);
  }
}