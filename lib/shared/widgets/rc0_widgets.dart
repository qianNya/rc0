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
    final theme = Theme.of(context);
    final placeholder = theme.brightness == Brightness.dark
        ? AppColors.placeholderDark
        : AppColors.placeholder;
    final tertiary = theme.brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: placeholder,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Icon(
          Icons.image_outlined,
          size: iconSize,
          color: tertiary,
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
    this.onSubmitted,
    this.controller,
    this.expanded = true,
  });

  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      readOnly: onTap != null,
      onTap: onTap,
      onSubmitted: onSubmitted,
      textInputAction: TextInputAction.search,
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
    final theme = Theme.of(context);
    final secondary = theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onTap == null ? null : (_) => onTap!(),
      showCheckmark: false,
      labelStyle: TextStyle(
        fontSize: 13,
        color: selected ? Colors.white : secondary,
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
    this.showChevron = false,
    this.padding = EdgeInsets.zero,
    this.titleStyle,
    this.actionStyle,
  });

  final String title;
  final String? action;
  final VoidCallback? onActionTap;
  final bool showChevron;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? actionStyle;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        Text(title, style: titleStyle ?? Theme.of(context).textTheme.titleMedium),
        const Spacer(),
        if (action != null && onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action!,
                  style: actionStyle ??
                      const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                if (showChevron)
                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
              ],
            ),
          ),
      ],
    );

    if (padding == EdgeInsets.zero) return content;
    return Padding(
      padding: padding,
      child: content,
    );
  }
}
