import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../data/scene_repository.dart';
import 'scene_map_pick.dart';
import 'scene_map_view.dart';

Future<void> showSceneMapSheet(
  BuildContext context, {
  required SceneRepository repo,
  required bool isLoggedIn,
  SceneMapCreateCallback? onCreateSceneAt,
}) {
  return showGlassScrollSheet<void>(
    context,
    maxHeightFraction: 0.72,
    padding: EdgeInsets.zero,
    builder: (context, maxHeight) {
      return SizedBox(
        height: maxHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingLg,
                0,
                AppDimensions.spacingLg,
                AppDimensions.spacingXs,
              ),
              child: Text(
                '场景地图',
                style: AppTextStyles.title.copyWith(fontSize: 17),
              ),
            ),
            Expanded(
              child: SceneMapView(
                repo: repo,
                isLoggedIn: isLoggedIn,
                onCreateSceneAt: onCreateSceneAt,
              ),
            ),
          ],
        ),
      );
    },
  );
}
