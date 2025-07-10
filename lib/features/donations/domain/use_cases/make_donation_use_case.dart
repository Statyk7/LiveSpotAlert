import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/purchase_result.dart';
import '../services/donation_service.dart';

class MakeDonationUseCase implements UseCase<PurchaseResult, MakeDonationParams> {
  final DonationService donationService;

  MakeDonationUseCase(this.donationService);

  @override
  Future<Either<Failure, PurchaseResult>> call(MakeDonationParams params) async {
    return await donationService.makeDonation(params.productId);
  }
}

class MakeDonationParams extends Equatable {
  final String productId;

  const MakeDonationParams({required this.productId});

  @override
  List<Object> get props => [productId];
}