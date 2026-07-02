import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../models/action_model_source.dart';
import '../models/model_import.dart';

/// Shared model import / bundled picker used by action and lighting wikis.
class ModelSelectionToolbar extends StatelessWidget {
  const ModelSelectionToolbar({
    super.key,
    required this.autoRotate,
    required this.hasModel,
    required this.isLoading,
    required this.supportsRealtimePreview,
    required this.onImport,
    required this.onImportBundled,
    required this.onReset,
    required this.onClear,
    required this.onAutoRotateChanged,
    this.showAutoRotate = true,
    this.compact = false,
  });

  final bool autoRotate;
  final bool hasModel;
  final bool isLoading;
  final bool supportsRealtimePreview;
  final ValueChanged<BundledModelAsset> onImportBundled;
  final ValueChanged<bool> onAutoRotateChanged;
  final VoidCallback onImport;
  final VoidCallback onReset;
  final VoidCallback onClear;
  final bool showAutoRotate;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final spacing = compact ? AppDimensions.spacingXs : AppDimensions.spacingSm;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: isLoading || !supportsRealtimePreview ? null : onImport,
          icon: Icon(Icons.upload_file_outlined, size: compact ? 18 : 24),
          label: Text(hasModel ? '重新导入' : '导入模型'),
        ),
        DropdownButton<BundledModelAsset>(
          value: null,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(Icons.folder_special_outlined, size: compact ? 16 : 18),
              const SizedBox(width: 6),
              Text(isLoading ? '加载中…' : '内置模型'),
            ],
          ),
          items: [
            for (final asset in bundledModelAssets)
              DropdownMenuItem(value: asset, child: Text(asset.label)),
          ],
          onChanged: isLoading || !supportsRealtimePreview
              ? null
              : (asset) {
                  if (asset != null) onImportBundled(asset);
                },
        ),
        OutlinedButton.icon(
          onPressed: supportsRealtimePreview ? onReset : null,
          icon: const Icon(Icons.center_focus_strong_outlined),
          label: const Text('重置视角'),
        ),
        OutlinedButton.icon(
          onPressed: hasModel ? onClear : null,
          icon: const Icon(Icons.close),
          label: const Text('清除模型'),
        ),
        if (showAutoRotate)
          FilterChip(
            label: const Text('自动旋转'),
            selected: supportsRealtimePreview && autoRotate,
            showCheckmark: false,
            onSelected: supportsRealtimePreview ? onAutoRotateChanged : null,
          ),
      ],
    );
  }
}

class ModelSelectionInfoStrip extends StatelessWidget {
  const ModelSelectionInfoStrip({super.key, required this.model});

  final ActionModelSource model;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        ModelSelectionInfoPill(label: model.extension.toUpperCase()),
        ModelSelectionInfoPill(label: model.sizeLabel),
        ModelSelectionInfoPill(label: model.renderModeLabel),
      ],
    );
  }
}

class ModelImportHintStrip extends StatelessWidget {
  const ModelImportHintStrip({
    super.key,
    required this.supportsRealtimePreview,
    this.lightingMode = false,
  });

  final bool supportsRealtimePreview;
  final bool lightingMode;

  @override
  Widget build(BuildContext context) {
    final lightingHint =
        '选择预览主体后调整灯光方案；支持 GLTF/GLB/OBJ，PMX/VRM 仅保留导入状态。';
    final actionHint =
        '支持 GLTF/GLB/OBJ 实色材质渲染；PMX/VRM 会保留导入状态。可使用「内置模型」快速预览。';
    final disabledHint =
        '当前平台暂不启用实时 3D 预览，已关闭模型导入以避免原生崩溃。';

    return Text(
      supportsRealtimePreview
          ? (lightingMode ? lightingHint : actionHint)
          : disabledHint,
      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
    );
  }
}

class ModelSelectionInfoPill extends StatelessWidget {
  const ModelSelectionInfoPill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.accent),
        ),
      ),
    );
  }
}

/// Floating chip that opens model selection — used on immersive lighting page.
class ModelSelectionFloatingChip extends StatelessWidget {
  const ModelSelectionFloatingChip({
    super.key,
    required this.model,
    required this.onTap,
  });

  final ActionModelSource? model;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = model?.name ?? '选择预览模型';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.view_in_ar_outlined,
                  size: 18,
                  color: Colors.white70,
                ),
                const SizedBox(width: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// File / bundled import helpers shared by wiki pages.
Future<ActionModelSource?> pickAndImportModel() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: const ['obj', 'glb', 'gltf', 'vrm', 'pmx'],
    allowMultiple: false,
    withData: false,
  );
  final file = result?.files.single;
  if (file == null) return null;
  return actionModelSourceFromFile(file);
}

ActionModelSource bundledModelToSource(BundledModelAsset asset) =>
    asset.toSource();
