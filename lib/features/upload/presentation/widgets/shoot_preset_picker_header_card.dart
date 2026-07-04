import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/status_bar_spacer.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';
import '../../../studio/presentation/widgets/script_studio_theme.dart';

/// Header card for shoot preset picker (replaces floating app bar).
class ShootPresetPickerHeaderCard extends StatelessWidget {
  const ShootPresetPickerHeaderCard({
    super.key,
    required this.title,
    required this.onBack,
    this.subtitle = '设备与画幅模板',
    this.scopeLabel,
    this.myPresetCount,
    this.officialCount,
    this.onCreateTap,
    this.onLightingTap,
    this.onEquipmentTap,
    this.isManage = false,
  });

  final String title;
  final VoidCallback onBack;
  final String subtitle;
  final String? scopeLabel;
  final int? myPresetCount;
  final int? officialCount;
  final VoidCallback? onCreateTap;
  final VoidCallback? onLightingTap;
  final VoidCallback? onEquipmentTap;
  final bool isManage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const StatusBarSpacer(),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
          ),
          child: StudioGlassCard(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    StudioGlassIconButton(
                      icon: Icons.arrow_back,
                      onPressed: onBack,
                      tooltip: '返回',
                      size: 36,
                      iconSize: 20,
                    ),
                    const Spacer(),
                    if (onCreateTap != null)
                      StudioGlassIconButton(
                        icon: Icons.add_rounded,
                        onPressed: onCreateTap,
                        tooltip: isManage ? '新建预设' : '创建预设',
                        size: 36,
                        iconSize: 20,
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _PresetIconBadge(),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ScriptStudioColors.cardTitle.copyWith(
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: ScriptStudioColors.cardSubtitle,
                          ),
                          if (scopeLabel != null &&
                              scopeLabel!.trim().isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _ScopePill(label: '应用于 · $scopeLabel'),
                          ],
                          if (myPresetCount != null || officialCount != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                _statsLine,
                                style: AppTextStyles.bodySecondary.copyWith(
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          if (onLightingTap != null || onEquipmentTap != null) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              runSpacing: 4,
                              children: [
                                if (onEquipmentTap != null)
                                  _RelatedHubLink(
                                    label: '机身镜头请前往设备库 →',
                                    onTap: onEquipmentTap!,
                                  ),
                                if (onLightingTap != null)
                                  _RelatedHubLink(
                                    label: '打光方案请前往灯光库 →',
                                    onTap: onLightingTap!,
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String get _statsLine {
    final parts = <String>[];
    if (myPresetCount != null) parts.add('我的 $myPresetCount');
    if (officialCount != null) parts.add('官方 $officialCount');
    return parts.join(' · ');
  }
}

class _PresetIconBadge extends StatelessWidget {
  const _PresetIconBadge();

  static const _size = 72.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ScriptStudioColors.iconSurface,
              ScriptStudioColors.accentGlow.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(
            color: ScriptStudioColors.glassBorder,
          ),
        ),
        child: const Icon(
          Icons.camera_outlined,
          size: 32,
          color: ScriptStudioColors.iconForeground,
        ),
      ),
    );
  }
}

class _RelatedHubLink extends StatelessWidget {
  const _RelatedHubLink({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          fontSize: 12,
          color: ScriptStudioColors.accentGlow,
        ),
      ),
    );
  }
}

class _ScopePill extends StatelessWidget {
  const _ScopePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: ScriptStudioColors.iconSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.label.copyWith(
          fontSize: 10,
          color: ScriptStudioColors.iconForeground,
        ),
      ),
    );
  }
}
