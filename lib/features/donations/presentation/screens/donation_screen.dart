import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../controllers/donation_bloc.dart';
import '../controllers/donation_event.dart';
import '../controllers/donation_state.dart';
import '../widgets/donation_option_card.dart';
import '../widgets/thank_you_message.dart';

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ServiceLocator.createDonationBloc()
        ..add(const LoadDonationProducts()),
      child: const _DonationScreenContent(),
    );
  }
}

class _DonationScreenContent extends StatelessWidget {
  const _DonationScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Tip Jar',
          style: AppTextStyles.h2.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocListener<DonationBloc, DonationState>(
        listener: (context, state) {
          if (state is DonationPurchaseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thank you for your generous donation!'),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<DonationBloc>().add(const LoadDonationProducts());
          } else if (state is DonationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeaderSection(),
                  const SizedBox(height: 32),
                  _buildContentSection(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'If you are enjoying LiveSpotAlert and would like to support the app\'s future development, adding a tip would be greatly helpful.',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    return BlocBuilder<DonationBloc, DonationState>(
      builder: (context, state) {
        if (state is DonationLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is DonationProductsLoaded) {
          return Column(
            children: [
              if (state.hasPreviousPurchases) ...[
                const ThankYouMessage(),
                const SizedBox(height: 24),
              ],
              ...state.products.map((product) {
                final currentState = context.watch<DonationBloc>().state;
                final isLoading = currentState is DonationPurchasing && 
                    currentState.productId == product.id;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DonationOptionCard(
                    product: product,
                    onTap: () {
                      context.read<DonationBloc>().add(
                        MakeDonation(productId: product.id),
                      );
                    },
                    isLoading: isLoading,
                  ),
                );
              }),
            ],
          );
        }

        if (state is DonationPurchasing) {
          return Column(
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              Text(
                'Processing your donation...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        }

        if (state is DonationError) {
          return Center(
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Unable to load donation options',
                  style: AppTextStyles.h4,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.read<DonationBloc>().add(const LoadDonationProducts());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}