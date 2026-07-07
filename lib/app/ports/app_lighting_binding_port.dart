import 'package:flutter/widgets.dart';
import 'package:rc0_core/rc0_core.dart';

import '../../features/lighting/data/lighting_draft_binding.dart';
import '../../features/lighting/domain/lighting_scheme.dart';
import '../../features/lighting/presentation/utils/lighting_navigation.dart';
import '../../features/lighting/presentation/widgets/lighting_picker_sheet.dart';
import '../../features/screenplay/data/screenplay_draft.dart';
import '../../features/screenplay/data/shoot_params_draft.dart';

final class AppLightingBindingPort implements LightingBindingPort {
  const AppLightingBindingPort();

  ScreenplayDraft _draft(FrameBindingTarget target) =>
      target.draft as ScreenplayDraft;

  FrameDraft _frame(FrameBindingTarget target) {
    final draft = _draft(target);
    return draft.acts[target.actIndex].scenes[target.sceneIndex]
        .frames[target.frameIndex!];
  }

  @override
  String displayLabel(FrameBindingTarget target) {
    final frame = _frame(target);
    final rig = lightingSchemeFromDraftFrame(frame);
    if (rig != null) return rig.displaySummary;
    final params = effectiveParamsForFrame(
      _draft(target),
      target.actIndex,
      target.sceneIndex,
      target.frameIndex!,
    );
    return params.lighting?.trim().isNotEmpty == true
        ? params.lighting!
        : '未设置';
  }

  Future<void> _apply(LightingScheme scheme, FrameBindingTarget target) async {
    applyLightingSchemeToDraft(
      _draft(target),
      scheme,
      actIndex: target.actIndex,
      sceneIndex: target.sceneIndex,
      frameIndex: target.frameIndex,
    );
  }

  @override
  Future<bool> pickQuick(BuildContext context, FrameBindingTarget target) async {
    final scheme = await LightingPickerSheet.show(context);
    if (scheme == null || !context.mounted) return false;
    await _apply(scheme, target);
    return true;
  }

  @override
  Future<bool> pickFromHub(
    BuildContext context,
    FrameBindingTarget target, {
    int? characterId,
    String? schemeId,
  }) async {
    final frame = _frame(target);
    final scheme = await openLightingHub(
      context,
      schemeId: schemeId ?? frame.lightingSchemeId,
      characterId: characterId ?? frame.characterId,
      scope: 'apply',
      actIndex: target.actIndex,
      sceneIndex: target.sceneIndex,
      frameIndex: target.frameIndex,
    );
    if (scheme == null || !context.mounted) return false;
    await _apply(scheme, target);
    return true;
  }
}
