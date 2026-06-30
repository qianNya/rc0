import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import 'script_studio_glass_widgets.dart';
import 'script_studio_theme.dart';

/// Reusable frosted title chip used by Script Studio headers.
class ScriptStudioHeaderTitleChip extends StatelessWidget {
  const ScriptStudioHeaderTitleChip({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppDimensions.glassNavBlurSigma,
          sigmaY: AppDimensions.glassNavBlurSigma,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: ScriptStudioColors.glassFill,
            border: Border.all(
              color: ScriptStudioColors.glassBorder,
              width: 0.8,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Text(text, style: ScriptStudioColors.title),
          ),
        ),
      ),
    );
  }
}

/// Reusable action group for Script Studio headers.
class ScriptStudioHeaderActionButtons extends StatelessWidget {
  const ScriptStudioHeaderActionButtons({
    super.key,
    this.trailingSpacing = 0,
  });

  final double trailingSpacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        StudioGlassIconButton(
          icon: Icons.search,
          tooltip: '搜索',
          onPressed: () => context.push(AppRoutes.search),
        ),
        const SizedBox(width: 4),
        StudioGlassIconButton(
          icon: Icons.notifications_outlined,
          tooltip: '消息',
          onPressed: () => context.push(AppRoutes.messages),
        ),
        if (trailingSpacing > 0) SizedBox(width: trailingSpacing),
      ],
    );
  }
}
