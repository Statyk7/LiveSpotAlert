import 'package:equatable/equatable.dart';

abstract class DonationEvent extends Equatable {
  const DonationEvent();

  @override
  List<Object> get props => [];
}

class LoadDonationProducts extends DonationEvent {
  const LoadDonationProducts();
}

class MakeDonation extends DonationEvent {
  final String productId;

  const MakeDonation({required this.productId});

  @override
  List<Object> get props => [productId];
}

class CheckPurchaseHistory extends DonationEvent {
  const CheckPurchaseHistory();
}