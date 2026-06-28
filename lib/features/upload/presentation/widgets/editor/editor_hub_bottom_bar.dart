import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_motion.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../../shared/widgets/liquid_tab_indicator.dart';
import '../../../../studio/presentation/studio_editor_shell_bridge.dart';
import 'editor_quick_action_row.dart';

/// Shell bottom bar for script editor hub modes — mirrors [AppBottomNavBar] chrome.
class EditorHubBottomBar extends StatelessWidget {
  const EditorHubBottomBar({super.key});

  static const _modes = <EditorHubMode>[
    EditorHubMode.outline,
    EditorHubMode.script,
    EditorHubMode.frames,
  ];

  static const _labels = ['大纲', '剧本', '分镜'];

  static const _icons = <IconData>[
    Icons.account_tree_outlined,
    Icons.edit_note_outlined,
    Icons.view_comfy_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final bridge = StudioEditorShellBridge.instance;

    return ListenableBuilder(
      listenable: bridge,
      builder: (context, _) {
        final selectedIndex = _modes.indexOf(bridge.hubMode).clamp(0, _modes.length - 1);

        return LiquidGlassSurface(
          style: LiquidGlassStyle.navigation,
          height: AppDimensions.bottomNavFloatingHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              LiquidTabIndicator(
                selectedIndex: selectedIndex,
                itemCount: _modes.length,
              ),
              Row(
                children: [
                  for (var i = 0; i < _modes.length; i++)
                    Expanded(
                      child: _HubNavSlot(
                        label: _labels[i],
                        icon: _icons[i],
                        selected: selectedIndex == i,
                        onTap: () => bridge.setHubMode(_modes[i]),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HubNavSlot extends StatelessWidget {
  const _HubNavSlot({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final unselectedColor =
        isDark ? AppColors.glassNavIconDark : AppColors.glassNavIconLight;
    final selectedColor = isDark
        ? AppColors.glassNavIconSelectedDark
        : AppColors.glassNavIconSelectedLight;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1.0 : 0.0),
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        builder: (context, t, _) {
          final color = Color.lerp(unselectedColor, selectedColor, t)!;

          return SizedBox(
            height: AppDimensions.bottomNavFloatingHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
