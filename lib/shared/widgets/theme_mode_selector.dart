import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/theme/theme_mode_notifier.dart';

class _ThemeModeOption {
  const _ThemeModeOption({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
  });

  final ThemeMode mode;
  final String label;
  final String description;
  final IconData icon;
}

const _kThemeModeOptions = [
  _ThemeModeOption(
    mode: ThemeMode.light,
    label: '浅色',
    description: '始终使用浅色外观',
    icon: Icons.light_mode_outlined,
  ),
  _ThemeModeOption(
    mode: ThemeMode.dark,
    label: '深色',
    description: '始终使用深色外观',
    icon: Icons.dark_mode_outlined,
  ),
  _ThemeModeOption(
    mode: ThemeMode.system,
    label: '跟随系统',
    description: '与设备外观设置保持一致',
    icon: Icons.settings_brightness_outlined,
  ),
];

/// Theme picker for profile sheets and compact inline toggles.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _CompactThemeModeSelector();
    }
    return _SheetThemeModeSelector();
  }
}

class _CompactThemeModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeModeNotifier.instance,
      builder: (context, _) {
        final notifier = ThemeModeNotifier.instance;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text('深色模式', style: theme.textTheme.bodyMedium),
            const SizedBox(width: 8),
            Switch.adaptive(
              value: notifier.themeMode == ThemeMode.dark,
              activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.45),
              activeThumbColor: theme.colorScheme.primary,
              onChanged: (enabled) {
                notifier.setThemeMode(
                  enabled ? ThemeMode.dark : ThemeMode.light,
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SheetThemeModeSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeModeNotifier.instance,
      builder: (context, _) {
        final selected = ThemeModeNotifier.instance.themeMode;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _kThemeModeOptions.length; i++) ...[
              if (i > 0) const SizedBox(height: AppDimensions.spacingSm),
              _ThemeModeOptionTile(
                option: _kThemeModeOptions[i],
                selected: selected == _kThemeModeOptions[i].mode,
                onTap: () => ThemeModeNotifier.instance.setThemeMode(
                  _kThemeModeOptions[i].mode,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ThemeModeOptionTile extends StatelessWidget {
  const _ThemeModeOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _ThemeModeOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.surfaceDark : AppColors.surface;
    final border = isDark ? AppColors.borderDark : AppColors.border;
    final iconColor =
        selected ? AppColors.accent : AppColors.textSecondary;
    final titleColor = selected
        ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return Material(
      color: surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: selected ? AppColors.accent.withValues(alpha: 0.45) : border,
              width: selected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingMd - 2,
          ),
          child: Row(
            children: [
              Icon(option.icon, size: 22, color: iconColor),
              const SizedBox(width: AppDimensions.spacingMd - 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.label,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      option.description,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey(true),
                        size: 22,
                        color: AppColors.accent,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey(false),
                        size: 22,
                        color: AppColors.textTertiary,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
