import 'package:flutter/material.dart';
import '../colors.dart';
import '../text_styles.dart';
import '../spacing.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outlined,
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.disabled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    
    Widget child = _buildChild();
    
    if (isFullWidth) {
      child = SizedBox(
        width: double.infinity,
        child: child,
      );
    }
    
    return child;
  }

  Widget _buildChild() {
    switch (variant) {
      case AppButtonVariant.primary:
        return _buildElevatedButton();
      case AppButtonVariant.secondary:
        return _buildSecondaryButton();
      case AppButtonVariant.outlined:
        return _buildOutlinedButton();
      case AppButtonVariant.text:
        return _buildTextButton();
    }
  }

  Widget _buildElevatedButton() {
    return ElevatedButton.icon(
      onPressed: (disabled || isLoading) ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.textHint,
        disabledForegroundColor: Colors.white70,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return ElevatedButton.icon(
      onPressed: (disabled || isLoading) ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.surfaceVariant,
        disabledForegroundColor: AppColors.textHint,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: (disabled || isLoading) ? AppColors.textHint : AppColors.primary,
          ),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton.icon(
      onPressed: (disabled || isLoading) ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textHint,
        side: BorderSide(
          color: (disabled || isLoading) ? AppColors.textHint : AppColors.primary,
        ),
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildTextButton() {
    return TextButton.icon(
      onPressed: (disabled || isLoading) ? null : onPressed,
      icon: _buildIcon(),
      label: _buildLabel(),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.textHint,
        padding: _getPadding(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.primary ? Colors.white : AppColors.error,
          ),
        ),
      );
    }
    
    if (icon == null) {
      return const SizedBox.shrink();
    }
    
    return Icon(icon, size: _getIconSize());
  }

  Widget _buildLabel() {
    return Text(
      text,
      style: _getTextStyle(),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return AppSpacing.buttonPaddingSmall;
      case AppButtonSize.medium:
        return AppSpacing.buttonPadding;
      case AppButtonSize.large:
        return AppSpacing.buttonPaddingLarge;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppButtonSize.small:
        return 16;
      case AppButtonSize.medium:
        return 18;
      case AppButtonSize.large:
        return 20;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600);
    }
  }
}