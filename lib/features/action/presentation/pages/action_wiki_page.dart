import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../runtime_3d/rc0_runtime.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../models/action_model_source.dart';
import '../models/model_import.dart';
import '../widgets/model_selection_panel.dart';

class ActionWikiPage extends StatefulWidget {
  const ActionWikiPage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  State<ActionWikiPage> createState() => _ActionWikiPageState();
}

class _ActionWikiPageState extends State<ActionWikiPage> {
  final RuntimeController _viewerController = RuntimeController();
  bool _autoRotate = true;
  bool _isLoadingModel = false;
  ActionModelSource? _model;
  List<String> _animationNames = const [];
  String? _selectedAnimationName;
  ModelPoseMode _poseMode = ModelPoseMode.standing;

  Future<void> _importModel() async {
    final source = await pickAndImportModel();
    if (source == null || !mounted) return;
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
      _model = bundledModelToSource(asset);
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

    final body = Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const WikiModeTagToolbarInset(),
          Text(
            'Anime Character Model Demo',
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            supportsRealtimePreview
                ? (_model?.statusLabel ??
                      '导入 GLTF/GLB/OBJ 模型，拖动旋转，双指/滚轮缩放。')
                : '当前平台暂不启用实时 3D 预览。',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          ModelSelectionToolbar(
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
            ModelSelectionInfoStrip(model: _model!)
          else
            ModelImportHintStrip(
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
                    child: RuntimeHost(
                      mode: RuntimeMode.characterPreview,
                      controller: _viewerController,
                      model: _model,
                      autoRotate: _autoRotate,
                      poseMode: _poseMode,
                      selectedAnimationName: _selectedAnimationName,
                      onAnimationsChanged: _handleAnimationsChanged,
                      backgroundColor: AppColors.surface,
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
          SizedBox(height: ShellInsets.scrollBottom(context)),
        ],
      ),
    );

    return WikiModeTagPageScaffold(
      appBar: const WikiModeTagAppBar(title: '动作'),
      body: body,
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
