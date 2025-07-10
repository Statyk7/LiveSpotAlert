import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../models/donation_product.dart';
import '../models/purchase_result.dart';

abstract class DonationService {
  Future<Either<Failure, List<DonationProduct>>> getAvailableProducts();
  
  Future<Either<Failure, PurchaseResult>> makeDonation(String productId);
  
  Future<Either<Failure, List<String>>> getPurchaseHistory();
  
  Future<Either<Failure, bool>> hasMadePurchase();
  
  void dispose();
}