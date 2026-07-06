import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../screenplay/data/shoot_preset_repository.dart';
import '../../../screenplay/domain/shoot_preset.dart';
import '../../../upload/presentation/widgets/preset_cover.dart';

class PresetDetailPage extends StatefulWidget {
  const PresetDetailPage({super.key, required this.presetId});

  final String presetId;

  @override
  State<PresetDetailPage> createState() => _PresetDetailPageState();
}

class _PresetDetailPageState extends State<PresetDetailPage> {
  final _repo = ShootPresetRepository.instance;
  ShootPreset? _preset;

  @override
  void initState() {
    super.initState();
    _repo.load().then((_) {
      if (mounted) setState(() => _preset = _repo.findById(widget.presetId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final preset = _preset;
    if (preset == null) {
      return DesktopStackScaffold(
        title: const Text('预设详情'),
        onBack: () => context.pop(),
        body: const Center(
          child: GlassEmptyState(
            icon: Icons.tune_outlined,
            title: '未找到预设',
            subtitle: '该预设可能已删除',
          ),
        ),
      );
    }

    return DesktopStackScaffold(
      title: Text(preset.label),
      onBack: () => context.pop(),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          GlassCard(
            child: Row(
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: PresetCover(
                    preset: preset,
                    height: 72,
                    borderRadius: AppDimensions.radiusMd,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(preset.label, style: AppTextStyles.title),
                      if (preset.subtitle != null)
                        Text(preset.subtitle!, style: AppTextStyles.bodySecondary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('拍摄参数', style: AppTextStyles.label),
                const SizedBox(height: AppDimensions.spacingSm),
                Text(_formatParams(preset), style: AppTextStyles.body),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('相关资源', style: AppTextStyles.label),
                const SizedBox(height: AppDimensions.spacingSm),
                Wrap(
                  spacing: AppDimensions.spacingSm,
                  runSpacing: AppDimensions.spacingSm,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.videocam_outlined, size: 18),
                      label: const Text('设备库'),
                      onPressed: () => context.push(AppRoutes.library),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.wb_incandescent_outlined, size: 18),
                      label: const Text('灯光库'),
                      onPressed: () => context.push(AppRoutes.lighting),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.tune_outlined, size: 18),
                      label: const Text('管理预设'),
                      onPressed: () => context.push(
                        AppRoutes.shootPresetPicker(mode: 'manage'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingLg),
          GlassButton(
            label: '使用此预设',
            filled: true,
            onPressed: () => context.pop(preset),
          ),
        ],
      ),
    );
  }

  String _formatParams(ShootPreset preset) {
    final params = preset.params;
    final parts = <String>[
      if (params.device != null && params.device!.isNotEmpty) params.device!,
      if (params.aspectRatio != null && params.aspectRatio!.isNotEmpty)
        params.aspectRatio!,
      if (params.lighting != null && params.lighting!.isNotEmpty)
        params.lighting!,
    ];
    return parts.isEmpty ? '默认参数' : parts.join(' · ');
  }
}
