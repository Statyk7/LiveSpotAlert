import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import '../../../../shared/base_domain/failures/failure.dart';
import '../../domain/models/donation_product.dart';
import '../../domain/models/purchase_result.dart';
import '../../domain/services/donation_service.dart';
import '../data_sources/local/donation_local_data_source.dart';
import '../data_sources/remote/in_app_purchase_data_source.dart';
import '../mappers/product_mapper.dart';

class DonationServiceImpl implements DonationService {
  static const Set<String> _productIds = {
    'small_tip',
    'medium_tip', 
    'large_tip',
    'giant_tip',
  };

  final InAppPurchaseDataSource inAppPurchaseDataSource;
  final DonationLocalDataSource localDataSource;
  late StreamSubscription<List<iap.PurchaseDetails>> _purchaseSubscription;

  DonationServiceImpl({
    required this.inAppPurchaseDataSource,
    required this.localDataSource,
  }) {
    _initializePurchaseListener();
  }

  void _initializePurchaseListener() {
    _purchaseSubscription = inAppPurchaseDataSource.purchaseStream.listen(
      (List<iap.PurchaseDetails> purchaseDetailsList) {
        _handlePurchaseUpdate(purchaseDetailsList);
      },
    );
  }

  Future<void> _handlePurchaseUpdate(List<iap.PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == iap.PurchaseStatus.purchased) {
        await localDataSource.savePurchase(
          purchaseDetails.productID,
          purchaseDetails.purchaseID ?? '',
          purchaseDetails.transactionDate != null
              ? DateTime.tryParse(purchaseDetails.transactionDate!) ?? DateTime.now()
              : DateTime.now(),
        );
      }
      
      if (purchaseDetails.pendingCompletePurchase) {
        await inAppPurchaseDataSource.completePurchase(purchaseDetails);
      }
    }
  }

  @override
  Future<Either<Failure, List<DonationProduct>>> getAvailableProducts() async {
    try {
      final isAvailable = await inAppPurchaseDataSource.isAvailable();
      if (!isAvailable) {
        return Left(GeneralFailure('In-app purchases are not available'));
      }

      final response = await inAppPurchaseDataSource.queryProductDetails(_productIds);
      
      if (response.notFoundIDs.isNotEmpty) {
        return Left(GeneralFailure(
          'Some products not found: ${response.notFoundIDs.join(', ')}'));
      }

      final products = ProductMapper.fromProductDetailsList(response.productDetails);
      
      // Sort products by price (ascending)
      products.sort((a, b) => double.parse(a.rawPrice).compareTo(double.parse(b.rawPrice)));
      
      return Right(products);
    } catch (e) {
      return Left(GeneralFailure('Failed to load products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PurchaseResult>> makeDonation(String productId) async {
    try {
      final isAvailable = await inAppPurchaseDataSource.isAvailable();
      if (!isAvailable) {
        return Left(GeneralFailure('In-app purchases are not available'));
      }

      final response = await inAppPurchaseDataSource.queryProductDetails({productId});
      
      if (response.productDetails.isEmpty) {
        return Left(GeneralFailure('Product not found: $productId'));
      }

      final productDetails = response.productDetails.first;
      final purchaseCompleter = Completer<PurchaseResult>();

      final purchaseSubscription = inAppPurchaseDataSource.purchaseStream.listen(
        (List<iap.PurchaseDetails> purchaseDetailsList) {
          for (final purchaseDetails in purchaseDetailsList) {
            if (purchaseDetails.productID == productId) {
              final result = ProductMapper.fromPurchaseDetails(purchaseDetails);
              if (!purchaseCompleter.isCompleted) {
                purchaseCompleter.complete(result);
              }
            }
          }
        },
      );

      final purchaseResult = await inAppPurchaseDataSource.buyNonConsumable(productDetails);
      
      if (!purchaseResult) {
        purchaseSubscription.cancel();
        return Left(GeneralFailure('Failed to initiate purchase'));
      }

      // Wait for purchase completion or timeout
      final result = await purchaseCompleter.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () => const PurchaseResult(
          productId: '',
          status: PurchaseStatus.error,
          errorMessage: 'Purchase timeout',
        ),
      );

      purchaseSubscription.cancel();
      return Right(result);
    } catch (e) {
      return Left(GeneralFailure('Purchase failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getPurchaseHistory() async {
    try {
      final history = await localDataSource.getPurchaseHistory();
      return Right(history);
    } catch (e) {
      return Left(GeneralFailure('Failed to get purchase history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> hasMadePurchase() async {
    try {
      final hasPurchase = await localDataSource.hasMadePurchase();
      return Right(hasPurchase);
    } catch (e) {
      return Left(GeneralFailure('Failed to check purchase history: ${e.toString()}'));
    }
  }

  @override
  void dispose() {
    _purchaseSubscription.cancel();
    inAppPurchaseDataSource.dispose();
  }
}