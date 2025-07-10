import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../../domain/use_cases/check_purchase_history_use_case.dart';
import '../../domain/use_cases/get_donation_products_use_case.dart';
import '../../domain/use_cases/make_donation_use_case.dart';
import 'donation_event.dart';
import 'donation_state.dart';
import '../../domain/models/purchase_result.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final GetDonationProductsUseCase getDonationProductsUseCase;
  final MakeDonationUseCase makeDonationUseCase;
  final CheckPurchaseHistoryUseCase checkPurchaseHistoryUseCase;

  DonationBloc({
    required this.getDonationProductsUseCase,
    required this.makeDonationUseCase,
    required this.checkPurchaseHistoryUseCase,
  }) : super(const DonationInitial()) {
    on<LoadDonationProducts>(_onLoadDonationProducts);
    on<MakeDonation>(_onMakeDonation);
    on<CheckPurchaseHistory>(_onCheckPurchaseHistory);
  }

  Future<void> _onLoadDonationProducts(
    LoadDonationProducts event,
    Emitter<DonationState> emit,
  ) async {
    emit(const DonationLoading());

    final productsResult = await getDonationProductsUseCase(NoParams());
    
    await productsResult.fold(
      (failure) async => emit(DonationError(message: failure.message)),
      (products) async {
        final purchaseHistoryResult = await checkPurchaseHistoryUseCase(NoParams());
        
        purchaseHistoryResult.fold(
          (failure) => emit(DonationProductsLoaded(
            products: products,
            hasPreviousPurchases: false,
          )),
          (hasPurchases) => emit(DonationProductsLoaded(
            products: products,
            hasPreviousPurchases: hasPurchases,
          )),
        );
      },
    );
  }

  Future<void> _onMakeDonation(
    MakeDonation event,
    Emitter<DonationState> emit,
  ) async {
    emit(DonationPurchasing(productId: event.productId));

    final result = await makeDonationUseCase(MakeDonationParams(productId: event.productId));
    
    result.fold(
      (failure) => emit(DonationError(message: failure.message)),
      (purchaseResult) {
        switch (purchaseResult.status) {
          case PurchaseStatus.success:
            emit(DonationPurchaseSuccess(purchaseResult: purchaseResult));
            break;
          case PurchaseStatus.canceled:
            emit(const DonationError(message: 'Purchase was canceled'));
            break;
          case PurchaseStatus.error:
            emit(DonationError(
              message: purchaseResult.errorMessage ?? 'Purchase failed'));
            break;
          case PurchaseStatus.pending:
            emit(const DonationError(message: 'Purchase is pending'));
            break;
          case PurchaseStatus.restored:
            emit(DonationPurchaseSuccess(purchaseResult: purchaseResult));
            break;
        }
      },
    );
  }

  Future<void> _onCheckPurchaseHistory(
    CheckPurchaseHistory event,
    Emitter<DonationState> emit,
  ) async {
    final result = await checkPurchaseHistoryUseCase(NoParams());
    
    result.fold(
      (failure) => emit(DonationError(message: failure.message)),
      (hasPurchases) {
        if (state is DonationProductsLoaded) {
          final currentState = state as DonationProductsLoaded;
          emit(DonationProductsLoaded(
            products: currentState.products,
            hasPreviousPurchases: hasPurchases,
          ));
        }
      },
    );
  }
}