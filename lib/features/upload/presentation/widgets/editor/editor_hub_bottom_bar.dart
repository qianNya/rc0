import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_motion.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/bottom_bar_glass_chrome.dart';
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
        final tabWidths = [
          for (final label in _labels) _hubTabWidth(context, label),
        ];
        final barWidth = AppDimensions.bottomNavBarWidth(tabWidths).clamp(
          0.0,
          AppDimensions.floatingBottomNavEditorMaxWidth,
        );

        return BottomBarGlassChrome(
          width: barWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.bottomNavBarInsetH,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                LiquidTabIndicator(
                  selectedIndex: selectedIndex,
                  itemCount: _modes.length,
                  itemWidths: tabWidths,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < _modes.length; i++)
                      SizedBox(
                        width: tabWidths[i],
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
          ),
        );
      },
    );
  }

  static double _hubTabWidth(BuildContext context, String label) {
    final style = AppTextStyles.caption.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w600,
    );
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: Directionality.of(context),
      maxLines: 1,
    )..layout();
    final contentWidth = painter.width > 22 ? painter.width : 22;
    return contentWidth + AppDimensions.bottomNavLabeledTabPaddingH * 2;
  }
}

class _HubNavSlot extends StatefulWidget {
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
  State<_HubNavSlot> createState() => _HubNavSlotState();
}

class _HubNavSlotState extends State<_HubNavSlot> {
  bool _pressed = false;

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
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.selected ? 1.0 : 0.0),
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        builder: (context, t, _) {
          final color = Color.lerp(unselectedColor, selectedColor, t)!;
          final y = -1.2 * t + (_pressed ? 1.4 : 0);
          final pressScale = _pressed ? 0.93 : 1.0;

          return AnimatedScale(
            duration: AppMotion.fast,
            curve: AppMotion.standard,
            scale: pressScale,
            child: Transform.translate(
              offset: Offset(0, y),
              child: SizedBox(
                height: AppDimensions.bottomNavFloatingHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      duration: AppMotion.fast,
                      curve: AppMotion.standard,
                      scale: 0.94 + t * 0.1,
                      child: Icon(widget.icon, size: 22, color: color),
                    ),
                    const SizedBox(height: 2),
                    AnimatedDefaultTextStyle(
                      duration: AppMotion.fast,
                      curve: AppMotion.standard,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        fontWeight:
                            widget.selected ? FontWeight.w600 : FontWeight.w400,
                        color: color,
                      ),
                      child: Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
