import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../domain/cine_camera_setup.dart';

Future<CineCameraSetup?> openEquipmentHub(
  BuildContext context, {
  String? setupId,
  String scope = 'browse',
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  return context.push<CineCameraSetup>(
    AppRoutes.equipmentWithContext(
      setupId: setupId,
      scope: scope,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    ),
  );
}
