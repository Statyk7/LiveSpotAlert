import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/donation_product.dart';
import '../services/donation_service.dart';

class GetDonationProductsUseCase implements UseCase<List<DonationProduct>, NoParams> {
  final DonationService donationService;

  GetDonationProductsUseCase(this.donationService);

  @override
  Future<Either<Failure, List<DonationProduct>>> call(NoParams params) async {
    return await donationService.getAvailableProducts();
  }
}