import 'package:flutter/material.dart';

import '../../core/theme/theme_mode_notifier.dart';

class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final notifier = ThemeModeNotifier.instance;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(
            '深色模式',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: notifier.themeMode == ThemeMode.dark,
            activeColor: theme.colorScheme.primary,
            onChanged: (enabled) {
              notifier.setThemeMode(
                enabled ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        ],
      );
    }

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(
              Icons.palette_outlined,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('外观', style: theme.textTheme.titleMedium),
            ),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('深色'),
                  icon: Icon(Icons.dark_mode_outlined, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('浅色'),
                  icon: Icon(Icons.light_mode_outlined, size: 16),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('系统'),
                  icon: Icon(Icons.settings_brightness_outlined, size: 16),
                ),
              ],
              selected: {notifier.themeMode},
              onSelectionChanged: (selection) {
                notifier.setThemeMode(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
