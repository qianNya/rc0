import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    this.aspectRatio = 1,
    this.borderRadius = AppDimensions.radiusMd,
    this.iconSize = 32,
  });

  final double aspectRatio;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.placeholder,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }
}

class Rc0Logo extends StatelessWidget {
  const Rc0Logo({super.key, this.fontSize = 22});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      'rc0',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: AppColors.accent,
        letterSpacing: -0.5,
      ),
    );
  }
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.onTap,
    this.expanded = true,
  });

  final String hint;
  final VoidCallback? onTap;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      readOnly: onTap != null,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search, size: 20),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
      ),
    );

    if (!expanded) return field;
    return SizedBox(height: 44, child: field);
  }
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 13,
        color: selected ? Colors.white : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onActionTap,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (action != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              action!,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
