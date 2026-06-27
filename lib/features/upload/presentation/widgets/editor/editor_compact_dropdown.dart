import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';

/// Compact filled dropdown for script editor toolbars.
class EditorCompactDropdown<T> extends StatelessWidget {
  const EditorCompactDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hintText,
  });

  final T? value;
  final List<DropdownMenuEntry<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
    final borderColor = isDark ? AppColors.borderDark : AppColors.border;
    final textStyle = AppTextStyles.body.copyWith(fontSize: 13);

    return DropdownMenu<T>(
      initialSelection: value,
      hintText: hintText,
      width: double.infinity,
      textStyle: textStyle,
      menuStyle: MenuStyle(
        maximumSize: const WidgetStatePropertyAll(Size(double.infinity, 260)),
        visualDensity: VisualDensity.compact,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: BorderSide(color: borderColor),
          ),
        ),
        backgroundColor: WidgetStatePropertyAll(
          isDark ? AppColors.surfaceDark : AppColors.surface,
        ),
        elevation: const WidgetStatePropertyAll(4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: fill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingSm + 4,
          vertical: 6,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
      ),
      trailingIcon: Icon(
        Icons.expand_more,
        size: 18,
        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
      ),
      selectedTrailingIcon: const Icon(
        Icons.expand_less,
        size: 18,
        color: AppColors.accent,
      ),
      dropdownMenuEntries: items,
      onSelected: onChanged,
    );
  }
}
