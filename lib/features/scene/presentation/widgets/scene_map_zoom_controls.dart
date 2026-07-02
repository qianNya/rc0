import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../studio/presentation/widgets/script_studio_glass_widgets.dart';

class SceneMapZoomControls extends StatelessWidget {
  const SceneMapZoomControls({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    this.canZoomIn = true,
    this.canZoomOut = true,
  });

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final bool canZoomIn;
  final bool canZoomOut;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.floatingBarRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StudioGlassIconButton(
            tooltip: '放大',
            icon: Icons.add,
            iconSize: 20,
            onPressed: canZoomIn ? onZoomIn : null,
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          StudioGlassIconButton(
            tooltip: '缩小',
            icon: Icons.remove,
            iconSize: 20,
            onPressed: canZoomOut ? onZoomOut : null,
          ),
        ],
      ),
    );
  }
}
