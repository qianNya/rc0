import 'package:flutter/widgets.dart';
import 'package:rc0_core/rc0_core.dart';

import '../../features/cine_equipment/data/equipment_draft_binding.dart';
import '../../features/cine_equipment/data/equipment_setup_mapper.dart';
import '../../features/cine_equipment/domain/cine_camera_setup.dart';
import '../../features/cine_equipment/presentation/utils/equipment_navigation.dart';
import '../../features/cine_equipment/presentation/widgets/camera_control_sheet.dart';
import '../../features/cine_equipment/presentation/widgets/equipment_picker_sheet.dart';
import '../../features/screenplay/data/screenplay_draft.dart';

final class AppCameraBindingPort implements CameraBindingPort {
  const AppCameraBindingPort();

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
    final setup = cineSetupFromDraftFrame(frame);
    if (setup != null && !setup.isEmpty) {
      return EquipmentSetupMapper.displaySummary(setup);
    }
    return '未设置';
  }

  Future<void> _apply(CineCameraSetup setup, FrameBindingTarget target) async {
    applyCineSetupToDraft(
      _draft(target),
      setup,
      actIndex: target.actIndex,
      sceneIndex: target.sceneIndex,
      frameIndex: target.frameIndex,
    );
  }

  @override
  Future<bool> pickQuick(BuildContext context, FrameBindingTarget target) async {
    final setup = await EquipmentPickerSheet.show(context);
    if (setup == null || !context.mounted) return false;
    await _apply(setup, target);
    return true;
  }

  @override
  Future<bool> pickControlSheet(
    BuildContext context,
    FrameBindingTarget target,
  ) async {
    final setup = await CameraControlSheet.show(
      context,
      initialSetup: cineSetupFromDraftFrame(_frame(target)),
      onSave: (_) {},
    );
    if (setup == null || !context.mounted) return false;
    await _apply(setup, target);
    return true;
  }

  @override
  Future<bool> pickFromHub(
    BuildContext context,
    FrameBindingTarget target, {
    String? setupId,
  }) async {
    await openGearCabinet(context);
    return false;
  }
}
