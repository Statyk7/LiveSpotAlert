import 'package:equatable/equatable.dart';

class DonationProduct extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String rawPrice;
  final String currencyCode;

  const DonationProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  @override
  List<Object> get props => [id, title, description, price, rawPrice, currencyCode];
}