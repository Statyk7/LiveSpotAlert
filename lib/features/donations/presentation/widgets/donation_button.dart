import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/widgets/app_buttons.dart';
import '../../../../i18n/translations.g.dart';

class DonationButton extends StatelessWidget {
  final VoidCallback onPressed;

  const DonationButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: PrimaryButton(
        text: t.donations.button,
        onPressed: onPressed,
        icon: Icons.favorite,
        isFullWidth: true,
      ),
    );
  }
}