import 'package:flutter/material.dart';
import '../colors.dart';
import '../text_styles.dart';
import '../spacing.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: AppTextStyles.inputLabel,
          ),
          AppSpacing.verticalSpaceSmall,
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          enabled: enabled,
          readOnly: readOnly,
          maxLines: maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
          autofocus: autofocus,
          textCapitalization: textCapitalization,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            
            // Use theme-defined input decoration
            // Additional customization if needed
            contentPadding: AppSpacing.inputContentPadding,
          ),
        ),
      ],
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(
        Icons.search,
        color: AppColors.textSecondary,
      ),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
              icon: const Icon(
                Icons.clear,
                color: AppColors.textSecondary,
              ),
            )
          : null,
    );
  }
}

class AppLocationField extends StatelessWidget {
  const AppLocationField({
    super.key,
    this.controller,
    this.labelText = 'Location Name',
    this.hintText = 'Enter location name',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      labelText: labelText,
      hintText: hintText,
      onChanged: onChanged,
      onTap: onTap,
      readOnly: readOnly,
      prefixIcon: const Icon(
        Icons.location_on_outlined,
        color: AppColors.textSecondary,
      ),
      textCapitalization: TextCapitalization.words,
    );
  }
}

class AppRadiusSlider extends StatelessWidget {
  const AppRadiusSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 100,
    this.max = 1000,
    this.divisions = 90,
    this.label,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int divisions;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Radius (${min.toInt()}m - ${max.toInt() ~/ 1000}km)',
              style: AppTextStyles.inputLabel,
            ),
            Text(
              '${value.toInt()}m',
              style: AppTextStyles.label.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        AppSpacing.verticalSpaceSmall,
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 12,
            ),
            overlayShape: const RoundSliderOverlayShape(
              overlayRadius: 20,
            ),
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primaryLight.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: label ?? '${value.toInt()}m',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}