import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../domain/models/donation_product.dart';

class DonationOptionCard extends StatelessWidget {
  final DonationProduct product;
  final VoidCallback onTap;
  final bool isLoading;

  const DonationOptionCard({
    super.key,
    required this.product,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: AppColors.surface,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _buildEmojiIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getDisplayTitle(),
                      style: AppTextStyles.h4,
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    product.price,
                    style: AppTextStyles.button,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmojiIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Text(
          _getEmoji(),
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  String _getEmoji() {
    switch (product.id) {
      case 'small_tip':
        return '🙂';
      case 'medium_tip':
        return '😊';
      case 'large_tip':
        return '😍';
      case 'giant_tip':
        return '🤩';
      default:
        return '💝';
    }
  }

  String _getDisplayTitle() {
    switch (product.id) {
      case 'small_tip':
        return 'Small Tip';
      case 'medium_tip':
        return 'Medium Tip';
      case 'large_tip':
        return 'Large Tip';
      case 'giant_tip':
        return 'Giant Tip';
      default:
        return product.title;
    }
  }
}