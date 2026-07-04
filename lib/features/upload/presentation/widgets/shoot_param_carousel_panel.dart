import 'package:flutter/material.dart';

import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/data/preset_catalog.dart';
import '../../../../shared/widgets/glass/glass_column_carousel_picker.dart';
import '../../../../shared/widgets/glass/carousel_column_visuals.dart';
import '../../../screenplay/domain/shoot_params.dart';

/// Four-column visual carousel: 设备 · 画幅 · 焦段 · 打光.
class ShootParamCarouselPanel extends StatelessWidget {
  const ShootParamCarouselPanel({
    super.key,
    required this.params,
    required this.onChanged,
    this.readOnly = false,
    this.inheritedHint,
    this.embedded = false,
  });

  final ShootParams params;
  final ValueChanged<ShootParams> onChanged;
  final bool readOnly;
  final String? inheritedHint;

  /// When true, carousel skips its own glass shell (inside sheet or card).
  final bool embedded;

  static final _lensOptions = AppCatalog.lensMmPresets;

  int get _deviceIndex =>
      indexForString(PresetCatalog.devicePresets, params.device);

  int get _aspectIndex =>
      indexForString(PresetCatalog.aspectRatioPresets, params.aspectRatio);

  int get _lensIndex => indexForString(_lensOptions, params.lensMm, fallback: 2);

  int get _lightingIndex =>
      indexForString(PresetCatalog.lightingPresets, params.lighting);

  @override
  Widget build(BuildContext context) {
    final columns = <CarouselColumnSpec>[
      CarouselColumnSpec(
        kind: CarouselColumnKind.shootDevice,
        values: PresetCatalog.devicePresets,
        selectedIndex: _deviceIndex,
        onSelected: readOnly
            ? (_) {}
            : (i) => onChanged(
                  params.copyWith(device: PresetCatalog.devicePresets[i]),
                ),
      ),
      CarouselColumnSpec(
        kind: CarouselColumnKind.aspectRatio,
        values: PresetCatalog.aspectRatioPresets,
        selectedIndex: _aspectIndex,
        onSelected: readOnly
            ? (_) {}
            : (i) => onChanged(
                  params.copyWith(
                    aspectRatio: PresetCatalog.aspectRatioPresets[i],
                  ),
                ),
      ),
      CarouselColumnSpec(
        kind: CarouselColumnKind.focalLength,
        values: _lensOptions,
        selectedIndex: _lensIndex,
        onSelected: readOnly
            ? (_) {}
            : (i) => onChanged(params.copyWith(lensMm: _lensOptions[i])),
      ),
      CarouselColumnSpec(
        kind: CarouselColumnKind.lighting,
        values: PresetCatalog.lightingPresets,
        selectedIndex: _lightingIndex,
        onSelected: readOnly
            ? (_) {}
            : (i) => onChanged(
                  params.copyWith(
                    lighting: PresetCatalog.lightingPresets[i],
                  ),
                ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (inheritedHint != null) ...[
          Text(
            inheritedHint!,
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 8),
        ],
        IgnorePointer(
          ignoring: readOnly,
          child: GlassFourColumnCarouselPicker(
            columns: columns,
            embedded: embedded,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _summaryLine,
          textAlign: TextAlign.center,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  String get _summaryLine {
    final parts = <String>[
      if (params.device?.isNotEmpty == true) params.device!,
      if (params.aspectRatio?.isNotEmpty == true) params.aspectRatio!,
      if (params.lensMm?.isNotEmpty == true) params.lensMm!,
      if (params.lighting?.isNotEmpty == true) params.lighting!,
    ];
    return parts.isEmpty ? '未设置' : parts.join(' · ');
  }
}
