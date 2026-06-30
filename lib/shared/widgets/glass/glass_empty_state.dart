import 'package:flutter/material.dart';

import '../../../app/theme/app_dimensions.dart';
import '../empty_state_view.dart';
import 'glass_card.dart';

/// Empty state wrapped in a frosted glass card.
class GlassEmptyState extends StatelessWidget {
  const GlassEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.margin,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: margin ??
          const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXl,
        horizontal: AppDimensions.spacingLg,
      ),
      child: EmptyStateView(
        icon: icon,
        title: title,
        subtitle: subtitle,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    );
  }
}
