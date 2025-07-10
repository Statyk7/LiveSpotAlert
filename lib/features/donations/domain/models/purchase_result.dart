import 'package:equatable/equatable.dart';

enum PurchaseStatus {
  success,
  pending,
  error,
  canceled,
  restored,
}

class PurchaseResult extends Equatable {
  final String productId;
  final PurchaseStatus status;
  final String? transactionId;
  final DateTime? purchaseDate;
  final String? errorMessage;

  const PurchaseResult({
    required this.productId,
    required this.status,
    this.transactionId,
    this.purchaseDate,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        productId,
        status,
        transactionId,
        purchaseDate,
        errorMessage,
      ];
}