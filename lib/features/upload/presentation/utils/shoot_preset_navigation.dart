import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../screenplay/domain/shoot_params.dart';

Future<ShootParams?> openShootPresetPicker(
  BuildContext context, {
  String mode = 'select',
  String scope = 'screenplay',
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  return context.push<ShootParams>(
    AppRoutes.shootPresetPicker(
      mode: mode,
      scope: scope,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    ),
  );
}
