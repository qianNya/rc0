import 'package:flutter/material.dart';

import '../../../screenplay/domain/shoot_params.dart';
import '../../../screenplay/presentation/widgets/screenplay_shoot_params_chips.dart';
import '../utils/shoot_preset_navigation.dart';
import 'shoot_param_carousel_panel.dart';

typedef ShootParamsChanged = void Function(ShootParams params);

/// Selectable preset params via four-column visual carousel.
class ShootParamPresetCards extends StatelessWidget {
  const ShootParamPresetCards({
    super.key,
    required this.params,
    required this.onChanged,
    this.inheritedHint,
    this.compact = false,
    this.readOnly = false,
  });

  final ShootParams params;
  final ShootParamsChanged onChanged;
  final String? inheritedHint;
  final bool compact;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return ShootParamCarouselPanel(
      params: params,
      onChanged: onChanged,
      inheritedHint: inheritedHint,
      readOnly: readOnly,
    );
  }
}

/// Collapsible shoot-param override block for scene / frame editors.
class ShootParamOverrideSection extends StatelessWidget {
  const ShootParamOverrideSection({
    super.key,
    required this.effectiveParams,
    required this.paramOverride,
    required this.inheritLabel,
    required this.onOverrideChanged,
    this.scope = 'scene',
    this.actIndex,
    this.sceneIndex,
    this.frameIndex,
  });

  final ShootParams effectiveParams;
  final ShootParams? paramOverride;
  final String inheritLabel;
  final ValueChanged<ShootParams?> onOverrideChanged;
  final String scope;
  final int? actIndex;
  final int? sceneIndex;
  final int? frameIndex;

  bool get _hasOverride =>
      paramOverride != null && paramOverride!.hasAnyValue;

  Future<void> _openPicker(BuildContext context) async {
    final params = await openShootPresetPicker(
      context,
      scope: scope,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    );
    if (params == null) return;
    onOverrideChanged(params);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('参数', style: Theme.of(context).textTheme.labelLarge),
            const Spacer(),
            if (_hasOverride)
              TextButton(
                onPressed: () => onOverrideChanged(null),
                child: const Text('恢复默认'),
              ),
            TextButton(
              onPressed: () => _openPicker(context),
              child: Text(_hasOverride ? '更换' : '选择预设'),
            ),
          ],
        ),
        ScreenplayShootParamsChips(
          params: effectiveParams,
          inheritedHint: _hasOverride ? null : inheritLabel,
          compact: true,
          onTap: () => _openPicker(context),
        ),
      ],
    );
  }
}
