import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../models/action_model_source.dart';
import '../widgets/real_model_viewer.dart';

class ActionWikiPage extends StatefulWidget {
  const ActionWikiPage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  State<ActionWikiPage> createState() => _ActionWikiPageState();
}

class _ActionWikiPageState extends State<ActionWikiPage> {
  final RealModelViewerController _viewerController =
      RealModelViewerController();
  bool _autoRotate = true;
  bool _isLoadingModel = false;
  ActionModelSource? _model;
  List<String> _animationNames = const [];
  String? _selectedAnimationName;
  ModelPoseMode _poseMode = ModelPoseMode.standing;

  Future<void> _importModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['obj', 'glb', 'gltf', 'vrm', 'pmx'],
      allowMultiple: false,
      withData: false,
    );
    final file = result?.files.single;
    if (file == null || !mounted) return;
    final source = await actionModelSourceFromFile(file);
    setState(() {
      _model = source;
      _animationNames = const [];
      _selectedAnimationName = null;
      _poseMode = ModelPoseMode.standing;
    });
  }

  Future<void> _importBundledModel(BundledModelAsset asset) async {
    setState(() {
      _isLoadingModel = true;
      _model = asset.toSource();
      _animationNames = const [];
      _selectedAnimationName = null;
      _poseMode = ModelPoseMode.standing;
    });
    if (!mounted) return;
    setState(() => _isLoadingModel = false);
  }

  void _resetCamera() => _viewerController.resetCamera();

  void _handleAnimationsChanged(List<String> animationNames) {
    if (_animationNames.length == animationNames.length &&
        _animationNames.indexed.every(
          (entry) => entry.$2 == animationNames[entry.$1],
        )) {
      return;
    }

    setState(() {
      _animationNames = animationNames;
      _selectedAnimationName = animationNames.contains(_selectedAnimationName)
          ? _selectedAnimationName
          : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final supportsRealtimePreview = isRealModelViewerRealtimeSupported;

    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Anime Character Model Demo',
                style: AppTextStyles.title.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                supportsRealtimePreview
                    ? (_model?.statusLabel ??
                          '导入 GLTF/GLB/OBJ 模型，拖动旋转，双指/滚轮缩放。')
                    : '当前平台暂不启用实时 3D 预览，已关闭模型导入以避免原生崩溃。',
                style: AppTextStyles.bodySecondary,
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              _ModelToolbar(
                autoRotate: _autoRotate,
                hasModel: _model != null,
                isLoading: _isLoadingModel,
                supportsRealtimePreview: supportsRealtimePreview,
                onImport: _importModel,
                onImportBundled: _importBundledModel,
                onReset: _resetCamera,
                onClear: () {
                  setState(() {
                    _model = null;
                    _animationNames = const [];
                    _selectedAnimationName = null;
                    _poseMode = ModelPoseMode.standing;
                  });
                },
                onAutoRotateChanged: (value) {
                  setState(() => _autoRotate = value);
                  _viewerController.setAutoRotate(value);
                },
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              if (_model != null && supportsRealtimePreview)
                _ModelInfoStrip(model: _model!)
              else
                _ImportHintStrip(
                  supportsRealtimePreview: supportsRealtimePreview,
                ),
              const SizedBox(height: AppDimensions.spacingMd),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusXl,
                        ),
                        child: RealModelViewer(
                          controller: _viewerController,
                          source: _model,
                          autoRotate: _autoRotate,
                          poseMode: _poseMode,
                          selectedAnimationName: _selectedAnimationName,
                          onAnimationsChanged: _handleAnimationsChanged,
                        ),
                      ),
                    ),
                    Positioned(
                      left: AppDimensions.spacingMd,
                      right: AppDimensions.spacingMd,
                      bottom: AppDimensions.spacingMd,
                      child: _ActionModeBar(
                        animationNames: _animationNames,
                        selectedAnimationName: _selectedAnimationName,
                        poseMode: _poseMode,
                        enabled: _model?.canRender == true,
                        onPoseChanged: (poseMode) {
                          setState(() {
                            _poseMode = poseMode;
                            _selectedAnimationName = null;
                          });
                        },
                        onSelected: (name) {
                          setState(() => _selectedAnimationName = name);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionModeBar extends StatelessWidget {
  const _ActionModeBar({
    required this.animationNames,
    required this.selectedAnimationName,
    required this.poseMode,
    required this.enabled,
    required this.onPoseChanged,
    required this.onSelected,
  });

  final List<String> animationNames;
  final String? selectedAnimationName;
  final ModelPoseMode poseMode;
  final bool enabled;
  final ValueChanged<ModelPoseMode> onPoseChanged;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = <({String label, String? value})>[
      (label: '静态姿态', value: null),
      for (final name in animationNames) (label: name, value: name),
    ];
    final caption = !enabled
        ? '导入模型后选择动作'
        : animationNames.isEmpty
        ? '当前模型没有内置动作'
        : '基础动作 / 模型动画';

    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(
        AppDimensions.bottomNavFloatingRadius,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Icon(
            Icons.directions_run_outlined,
            size: 18,
            color: enabled ? AppColors.accent : AppColors.textSecondary,
          ),
          const SizedBox(width: AppDimensions.spacingSm),
          Text(caption, style: AppTextStyles.caption),
          const SizedBox(width: AppDimensions.spacingMd),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final mode in ModelPoseMode.values) ...[
                    _ActionModeChip(
                      label: mode.label,
                      selected: poseMode == mode,
                      enabled: enabled,
                      onTap: () => onPoseChanged(mode),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                  ],
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.border.withValues(alpha: 0.72),
                  ),
                  const SizedBox(width: AppDimensions.spacingSm),
                  for (final chip in chips) ...[
                    _ActionModeChip(
                      label: chip.label,
                      selected: selectedAnimationName == chip.value,
                      enabled: enabled,
                      onTap: () => onSelected(chip.value),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionModeChip extends StatelessWidget {
  const _ActionModeChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.accent
        : AppColors.surface.withValues(alpha: 0.72);
    final textColor = selected
        ? Colors.white
        : enabled
        ? AppColors.textPrimary
        : AppColors.textSecondary;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: AppMotion.normal,
        curve: AppMotion.smooth,
        constraints: const BoxConstraints(maxWidth: 140),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : AppColors.border.withValues(alpha: 0.72),
          ),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.caption.copyWith(
            color: textColor,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ModelToolbar extends StatelessWidget {
  const _ModelToolbar({
    required this.autoRotate,
    required this.hasModel,
    required this.isLoading,
    required this.supportsRealtimePreview,
    required this.onImport,
    required this.onImportBundled,
    required this.onReset,
    required this.onClear,
    required this.onAutoRotateChanged,
  });

  final bool autoRotate;
  final bool hasModel;
  final bool isLoading;
  final bool supportsRealtimePreview;
  final VoidCallback onImport;
  final ValueChanged<BundledModelAsset> onImportBundled;
  final VoidCallback onReset;
  final VoidCallback onClear;
  final ValueChanged<bool> onAutoRotateChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton.icon(
          onPressed: isLoading || !supportsRealtimePreview ? null : onImport,
          icon: const Icon(Icons.upload_file_outlined),
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
                const Icon(Icons.folder_special_outlined, size: 18),
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

class _ModelInfoStrip extends StatelessWidget {
  const _ModelInfoStrip({required this.model});

  final ActionModelSource model;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppDimensions.spacingSm,
      runSpacing: AppDimensions.spacingSm,
      children: [
        _InfoPill(label: model.extension.toUpperCase()),
        _InfoPill(label: model.sizeLabel),
        _InfoPill(label: model.renderModeLabel),
      ],
    );
  }
}

class _ImportHintStrip extends StatelessWidget {
  const _ImportHintStrip({required this.supportsRealtimePreview});

  final bool supportsRealtimePreview;

  @override
  Widget build(BuildContext context) {
    return Text(
      supportsRealtimePreview
          ? '支持 GLTF/GLB/OBJ 实色材质渲染；PMX/VRM 会保留导入状态。可使用「内置模型」快速预览。'
          : 'iOS 当前不加载 flutter_gl 实时纹理，避免触发三角绘制相关原生崩溃。',
      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.label});

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
