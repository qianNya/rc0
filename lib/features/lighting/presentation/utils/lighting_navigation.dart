import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../domain/lighting_scheme.dart';

Future<LightingScheme?> openLightingHub(
  BuildContext context, {
  String? schemeId,
  int? characterId,
  String? sceneId,
  String scope = 'browse',
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  return context.push<LightingScheme>(
    AppRoutes.lightingWithContext(
      schemeId: schemeId,
      characterId: characterId,
      sceneId: sceneId,
      scope: scope,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
      frameIndex: frameIndex,
    ),
  );
}
