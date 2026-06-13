import 'package:flutter/material.dart';

import '../../app/theme/app_dimensions.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isExpanded = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );

    if (!isExpanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: button,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
      ),
      child: Text(label),
    );

    if (!isExpanded) {
      return button;
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: button,
    );
  }
}
