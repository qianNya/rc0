import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../domain/cine_camera_setup.dart';
import '../widgets/equipment_picker_sheet.dart';

export '../../domain/cine_camera_setup.dart' show CineCameraSetup;

/// Open the gear cabinet (replaces legacy wiki equipment hub).
Future<void> openGearCabinet(BuildContext context) {
  return context.push(AppRoutes.library);
}

/// Pick a saved camera setup from the sheet (studio apply flow).
Future<CineCameraSetup?> pickCameraSetup(BuildContext context) {
  return EquipmentPickerSheet.show(context);
}
