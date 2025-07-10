import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class ProductDto extends Equatable {
  final String id;
  final String title;
  final String description;
  final String price;
  final String rawPrice;
  final String currencyCode;

  const ProductDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rawPrice,
    required this.currencyCode,
  });

  factory ProductDto.fromProductDetails(ProductDetails productDetails) {
    return ProductDto(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.price,
      rawPrice: productDetails.rawPrice.toString(),
      currencyCode: productDetails.currencyCode,
    );
  }

  @override
  List<Object> get props => [id, title, description, price, rawPrice, currencyCode];
}