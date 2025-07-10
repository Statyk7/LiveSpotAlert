import 'package:equatable/equatable.dart';
import '../../domain/models/donation_product.dart';
import '../../domain/models/purchase_result.dart';

abstract class DonationState extends Equatable {
  const DonationState();

  @override
  List<Object?> get props => [];
}

class DonationInitial extends DonationState {
  const DonationInitial();
}

class DonationLoading extends DonationState {
  const DonationLoading();
}

class DonationProductsLoaded extends DonationState {
  final List<DonationProduct> products;
  final bool hasPreviousPurchases;

  const DonationProductsLoaded({
    required this.products,
    required this.hasPreviousPurchases,
  });

  @override
  List<Object> get props => [products, hasPreviousPurchases];
}

class DonationPurchasing extends DonationState {
  final String productId;

  const DonationPurchasing({required this.productId});

  @override
  List<Object> get props => [productId];
}

class DonationPurchaseSuccess extends DonationState {
  final PurchaseResult purchaseResult;

  const DonationPurchaseSuccess({required this.purchaseResult});

  @override
  List<Object> get props => [purchaseResult];
}

class DonationError extends DonationState {
  final String message;

  const DonationError({required this.message});

  @override
  List<Object> get props => [message];
}