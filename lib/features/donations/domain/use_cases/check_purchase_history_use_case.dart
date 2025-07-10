import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/donation_service.dart';

class CheckPurchaseHistoryUseCase implements UseCase<bool, NoParams> {
  final DonationService donationService;

  CheckPurchaseHistoryUseCase(this.donationService);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await donationService.hasMadePurchase();
  }
}