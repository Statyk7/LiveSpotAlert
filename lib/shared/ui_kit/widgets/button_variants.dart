import 'package:flutter/material.dart';
import 'app_button.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.primary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      size: size,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.secondary,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      size: size,
    );
  }
}

class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outlined,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      size: size,
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonSize size;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.text,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: icon,
      size: size,
    );
  }
}

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      text: 'Save',
      onPressed: onPressed,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
      icon: isLoading ? null : Icons.save,
    );
  }
}

class CancelButton extends StatelessWidget {
  const CancelButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
  });

  final VoidCallback? onPressed;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    return AppTextButton(
      text: 'Cancel',
      onPressed: onPressed,
      isFullWidth: isFullWidth,
      icon: Icons.close,
    );
  }
}

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.onPressed,
    this.isFullWidth = false,
    this.text = 'Delete',
  });

  final VoidCallback? onPressed;
  final bool isFullWidth;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      variant: AppButtonVariant.outlined,
      isFullWidth: isFullWidth,
      icon: Icons.delete_outline,
    );
  }
}