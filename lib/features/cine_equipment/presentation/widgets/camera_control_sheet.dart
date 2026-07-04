import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/carousel_column_visuals.dart';
import '../../../../shared/widgets/glass/glass_column_carousel_picker.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/equipment_catalog.dart';
import '../../data/equipment_repository.dart';
import '../../data/equipment_setup_mapper.dart';
import '../../domain/cine_camera_setup.dart';

/// Floating camera control sheet — four-column visual carousel.
class CameraControlSheet extends StatefulWidget {
  const CameraControlSheet({
    super.key,
    this.initialSetup,
    this.onSave,
  });

  final CineCameraSetup? initialSetup;
  final ValueChanged<CineCameraSetup>? onSave;

  static Future<CineCameraSetup?> show(
    BuildContext context, {
    CineCameraSetup? initialSetup,
    ValueChanged<CineCameraSetup>? onSave,
  }) {
    return showGlassSheet<CineCameraSetup>(
      context,
      child: CameraControlSheet(
        initialSetup: initialSetup,
        onSave: onSave,
      ),
    );
  }

  @override
  State<CameraControlSheet> createState() => _CameraControlSheetState();
}

class _CameraControlSheetState extends State<CameraControlSheet> {
  final _repo = EquipmentRepository.instance;
  bool _loading = true;

  late int _bodyIndex;
  late int _lensIndex;
  late int _focalIndex;
  late int _apertureIndex;

  @override
  void initState() {
    super.initState();
    _initIndices();
    _load();
  }

  void _initIndices() {
    final setup = widget.initialSetup;
    final bodies = _repo.allBodies;
    final lenses = _repo.allLenses;
    final focals = EquipmentCatalog.focalLengthPresetsMm;
    final apertures = EquipmentCatalog.aperturePresetsF;

    _bodyIndex = setup != null && setup.bodyId.isNotEmpty
        ? _indexOrZero(bodies.indexWhere((b) => b.id == setup.bodyId))
        : 0;
    _lensIndex = setup != null && setup.lensId.isNotEmpty
        ? _indexOrZero(lenses.indexWhere((l) => l.id == setup.lensId))
        : 0;
    _focalIndex = setup != null && setup.focalLengthMm > 0
        ? _indexOrZero(focals.indexWhere((f) => f == setup.focalLengthMm))
        : 0;
    _apertureIndex = setup != null && setup.apertureF > 0
        ? _indexOrZero(apertures.indexWhere((a) => a == setup.apertureF))
        : 3;
  }

  int _indexOrZero(int index) => index >= 0 ? index : 0;

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  CineCameraSetup get _currentSetup {
    final bodies = _repo.allBodies;
    final lenses = _repo.allLenses;
    final body = bodies[_bodyIndex.clamp(0, bodies.length - 1)];
    final lens = lenses[_lensIndex.clamp(0, lenses.length - 1)];
    final focal = EquipmentCatalog.focalLengthPresetsMm[
        _focalIndex.clamp(0, EquipmentCatalog.focalLengthPresetsMm.length - 1)];
    final aperture = EquipmentCatalog.aperturePresetsF[
        _apertureIndex.clamp(0, EquipmentCatalog.aperturePresetsF.length - 1)];

    return CineCameraSetup(
      id: widget.initialSetup?.id ?? '',
      title: widget.initialSetup?.title ?? '',
      bodyId: body.id,
      lensId: lens.id,
      focalLengthMm: focal,
      apertureF: aperture,
    );
  }

  String _formatAperture(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }

  Future<void> _saveAndPop({bool persist = false}) async {
    final setup = _currentSetup;
    if (persist) {
      final id = _repo.nextUserSetupId();
      final title = EquipmentSetupMapper.displaySummary(setup);
      final saved = setup.copyWith(id: id, title: title);
      await _repo.saveUserSetup(saved);
      widget.onSave?.call(saved);
      if (mounted) Navigator.of(context).pop(saved);
      return;
    }
    widget.onSave?.call(setup);
    if (mounted) Navigator.of(context).pop(setup);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final bodies = _repo.allBodies;
    final lenses = _repo.allLenses;
    final focals = EquipmentCatalog.focalLengthPresetsMm;
    final apertures = EquipmentCatalog.aperturePresetsF;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Text('摄影机控制', style: AppTextStyles.title),
            const Spacer(),
            TextButton(
              onPressed: () => _saveAndPop(persist: true),
              child: Text(
                '保存',
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        GlassFourColumnCarouselPicker(
          embedded: true,
          columns: [
            CarouselColumnSpec(
              kind: CarouselColumnKind.cameraBody,
              values: bodies.map((b) => b.displayName).toList(),
              bodyCategories: bodies.map((b) => b.category).toList(),
              selectedIndex: _bodyIndex,
              onSelected: (i) => setState(() => _bodyIndex = i),
            ),
            CarouselColumnSpec(
              kind: CarouselColumnKind.lens,
              values: lenses.map((l) => l.displayName).toList(),
              selectedIndex: _lensIndex,
              onSelected: (i) => setState(() => _lensIndex = i),
            ),
            CarouselColumnSpec(
              kind: CarouselColumnKind.focalLength,
              values: focals.map((f) => '${f.toStringAsFixed(0)}mm').toList(),
              selectedIndex: _focalIndex,
              onSelected: (i) => setState(() => _focalIndex = i),
            ),
            CarouselColumnSpec(
              kind: CarouselColumnKind.aperture,
              values: apertures
                  .map((a) => 'f/${_formatAperture(a)}')
                  .toList(),
              selectedIndex: _apertureIndex,
              onSelected: (i) => setState(() => _apertureIndex = i),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        FilledButton(
          onPressed: () => _saveAndPop(),
          child: const Text('应用'),
        ),
      ],
    );
  }
}
