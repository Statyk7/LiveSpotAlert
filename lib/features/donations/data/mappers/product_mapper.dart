import 'package:in_app_purchase/in_app_purchase.dart' as iap;
import '../../domain/models/donation_product.dart';
import '../../domain/models/purchase_result.dart';
import '../dto/product_dto.dart';

class ProductMapper {
  static DonationProduct fromDto(ProductDto dto) {
    return DonationProduct(
      id: dto.id,
      title: dto.title,
      description: dto.description,
      price: dto.price,
      rawPrice: dto.rawPrice,
      currencyCode: dto.currencyCode,
    );
  }

  static ProductDto toDto(DonationProduct product) {
    return ProductDto(
      id: product.id,
      title: product.title,
      description: product.description,
      price: product.price,
      rawPrice: product.rawPrice,
      currencyCode: product.currencyCode,
    );
  }

  static List<DonationProduct> fromDtoList(List<ProductDto> dtos) {
    return dtos.map((dto) => fromDto(dto)).toList();
  }

  static DonationProduct fromProductDetails(iap.ProductDetails productDetails) {
    return DonationProduct(
      id: productDetails.id,
      title: productDetails.title,
      description: productDetails.description,
      price: productDetails.price,
      rawPrice: productDetails.rawPrice.toString(),
      currencyCode: productDetails.currencyCode,
    );
  }

  static List<DonationProduct> fromProductDetailsList(List<iap.ProductDetails> productDetailsList) {
    return productDetailsList.map((details) => fromProductDetails(details)).toList();
  }

  static PurchaseResult fromPurchaseDetails(iap.PurchaseDetails purchaseDetails) {
    PurchaseStatus status;
    switch (purchaseDetails.status) {
      case iap.PurchaseStatus.pending:
        status = PurchaseStatus.pending;
        break;
      case iap.PurchaseStatus.purchased:
        status = PurchaseStatus.success;
        break;
      case iap.PurchaseStatus.error:
        status = PurchaseStatus.error;
        break;
      case iap.PurchaseStatus.restored:
        status = PurchaseStatus.restored;
        break;
      case iap.PurchaseStatus.canceled:
        status = PurchaseStatus.canceled;
        break;
    }

    return PurchaseResult(
      productId: purchaseDetails.productID,
      status: status,
      transactionId: purchaseDetails.purchaseID,
      purchaseDate: purchaseDetails.transactionDate != null 
          ? DateTime.tryParse(purchaseDetails.transactionDate!) ?? DateTime.now()
          : null,
      errorMessage: purchaseDetails.error?.message,
    );
  }
}