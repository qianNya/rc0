import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../runtime_3d/rc0_runtime.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../action/presentation/models/action_model_source.dart';
import '../../../action/presentation/models/model_import.dart';
import '../../../action/presentation/widgets/model_selection_panel.dart';
import '../../data/lighting_repository.dart';
import '../lighting_editor_controller.dart';
import '../widgets/lighting_floating_controls.dart';
import '../widgets/lighting_light_list_panel.dart';
import '../widgets/lighting_param_inspector.dart';
import '../widgets/lighting_preset_section.dart';

class LightingWikiPage extends StatefulWidget {
  const LightingWikiPage({
    super.key,
    this.initialSchemeId,
    this.previewCharacterId,
    this.previewSceneId,
    this.applyScope = LightingApplyScope.browse,
    this.actIndex,
    this.sceneIndex,
    this.frameIndex,
  });

  final String? initialSchemeId;
  final int? previewCharacterId;
  final String? previewSceneId;
  final LightingApplyScope applyScope;
  final int? actIndex;
  final int? sceneIndex;
  final int? frameIndex;

  @override
  State<LightingWikiPage> createState() => _LightingWikiPageState();
}

class _LightingWikiPageState extends State<LightingWikiPage> {
  late final LightingEditorController _controller;
  final RuntimeController _runtimeController = RuntimeController();
  bool _loading = true;
  bool _isLoadingModel = false;
  bool _autoRotate = false;
  ActionModelSource? _model = bundledModelAssets.first.toSource();

  @override
  void initState() {
    super.initState();
    _controller = LightingEditorController(
      previewCharacterId: widget.previewCharacterId,
      previewSceneId: widget.previewSceneId,
      applyScope: widget.applyScope,
    );
    _controller.addListener(_onChanged);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _controller.ensureLoaded();
    if (widget.initialSchemeId != null) {
      final scheme =
          LightingRepository.instance.findById(widget.initialSchemeId!);
      if (scheme != null) _controller.loadScheme(scheme);
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  void _applyAndPop() {
    context.pop(_controller.scheme);
  }

  void _onLightingEvent(LightingRuntimeEvent event) {
    if (event is! LightingLightMovedEvent) return;
    final light = _controller.scheme.lights
        .where((l) => l.id == event.lightId)
        .firstOrNull;
    if (light == null) return;
    _controller.updateLightById(
      event.lightId,
      light.copyWith(
        azimuthDeg: event.azimuthDeg,
        elevationDeg: event.elevationDeg,
      ),
    );
  }

  Future<void> _importModel() async {
    final source = await pickAndImportModel();
    if (source == null || !mounted) return;
    setState(() => _model = source);
  }

  Future<void> _importBundledModel(BundledModelAsset asset) async {
    setState(() => _isLoadingModel = true);
    final source = bundledModelToSource(asset);
    if (!mounted) return;
    setState(() {
      _model = source;
      _isLoadingModel = false;
    });
  }

  void _resetCamera() => _runtimeController.resetCamera();

  Future<void> _openModelSheet() async {
    final supportsRealtimePreview = isRealModelViewerRealtimeSupported;
    await showGlassScrollSheet<void>(
      context,
      maxHeightFraction: 0.42,
      builder: (context, maxHeight) {
        return SizedBox(
          height: maxHeight,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              0,
              AppDimensions.spacingMd,
              AppDimensions.spacingLg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '预览主体',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                ModelImportHintStrip(
                  supportsRealtimePreview: supportsRealtimePreview,
                  lightingMode: true,
                ),
                const SizedBox(height: AppDimensions.spacingMd),
                ModelSelectionToolbar(
                  compact: true,
                  autoRotate: _autoRotate,
                  hasModel: _model != null,
                  isLoading: _isLoadingModel,
                  supportsRealtimePreview: supportsRealtimePreview,
                  onImport: () async {
                    await _importModel();
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  onImportBundled: (asset) async {
                    await _importBundledModel(asset);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  onReset: _resetCamera,
                  onClear: () {
                    setState(() => _model = bundledModelAssets.first.toSource());
                    Navigator.of(context).pop();
                  },
                  onAutoRotateChanged: (value) {
                    setState(() => _autoRotate = value);
                    _runtimeController.setAutoRotate(value);
                  },
                ),
                if (_model != null && supportsRealtimePreview) ...[
                  const SizedBox(height: AppDimensions.spacingMd),
                  ModelSelectionInfoStrip(model: _model!),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSchemeSheet() async {
    await showGlassScrollSheet<void>(
      context,
      maxHeightFraction: 0.72,
      builder: (context, maxHeight) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SizedBox(
              height: maxHeight,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.spacingMd,
                  0,
                  AppDimensions.spacingMd,
                  AppDimensions.spacingLg,
                ),
                child: LightingPresetSection(
                  category: _controller.category,
                  onCategoryChanged: _controller.setCategory,
                  schemes: _controller.presets,
                  selectedId: _controller.scheme.id,
                  onSchemeSelected: (scheme) {
                    _controller.loadScheme(scheme);
                    Navigator.of(context).pop();
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openLightsSheet() async {
    await showGlassScrollSheet<void>(
      context,
      maxHeightFraction: 0.5,
      builder: (context, maxHeight) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            return SizedBox(
              height: maxHeight,
              child: LightingLightListPanel(
                scheme: _controller.scheme,
                selectedIndex: _controller.selectedLightIndex,
                onSelected: _controller.selectLight,
                onToggleEnabled: _controller.toggleLightEnabled,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openInspectorSheet() async {
    final light = _controller.selectedLight;
    if (light == null) return;
    await showGlassScrollSheet<void>(
      context,
      maxHeightFraction: 0.55,
      builder: (context, maxHeight) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final current = _controller.selectedLight;
            if (current == null) {
              return SizedBox(height: maxHeight);
            }
            return SizedBox(
              height: maxHeight,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: LightingParamInspector(
                  light: current,
                  onChanged: _controller.updateSelectedLight,
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;

    return WikiModeTagPageScaffold(
      appBar: WikiModeTagAppBar(
        title: '灯光',
        leading: WikiModeTagIconButton(
          icon: Icons.arrow_back,
          onPressed: () => popOrGoDiscovery(context),
          tooltip: '返回',
        ),
        actions: [
          WikiModeTagIconButton(
            icon: Icons.school_outlined,
            onPressed: () => context.push(AppRoutes.labsFeature('lighting_academy')),
            tooltip: '灯光学院',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: LightingFloatingActionChip(
              label: widget.applyScope == LightingApplyScope.apply
                  ? '应用'
                  : '保存',
              filled: true,
              onPressed: widget.applyScope == LightingApplyScope.apply
                  ? _applyAndPop
                  : () => _controller.saveCurrentScheme(),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              fit: StackFit.expand,
              children: [
                ListenableBuilder(
                  listenable: _controller,
                  builder: (context, _) {
                    final scheme = _controller.scheme;
                    final selected = _controller.selectedLight;
                    return RuntimeHost(
                      mode: RuntimeMode.lightingEditor,
                      immersive: true,
                      controller: _runtimeController,
                      model: _model,
                      lightingScheme: scheme,
                      selectedLightId: selected?.id,
                      planView: _controller.planView,
                      autoRotate: _autoRotate,
                      onLightingEvent: _onLightingEvent,
                    );
                  },
                ),
                Positioned(
                  left: AppDimensions.spacingMd,
                  top: wikiModeTagBleedInsetHeight(context) + 8,
                  child: ModelSelectionFloatingChip(
                    model: _model,
                    onTap: _openModelSheet,
                  ),
                ),
                Positioned(
                  right: AppDimensions.spacingMd,
                  top: wikiModeTagBleedInsetHeight(context) + 8,
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => LightingFloatingControls(
                      controller: _controller,
                      onEditLight: _openInspectorSheet,
                      onOpenLights: _openLightsSheet,
                      onOpenSchemes: _openSchemeSheet,
                    ),
                  ),
                ),
                Positioned(
                  left: AppDimensions.spacingMd,
                  right: AppDimensions.spacingMd,
                  bottom: bottomSafe + AppDimensions.spacingMd,
                  child: ListenableBuilder(
                    listenable: _controller,
                    builder: (context, _) => LightingSchemeBottomBar(
                      scheme: _controller.scheme,
                      onTap: _openSchemeSheet,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
