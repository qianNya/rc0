import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../screenplay/data/screenplay_draft.dart';

class CrossListDragHandle<T extends Object> extends StatelessWidget {
  const CrossListDragHandle({
    super.key,
    required this.data,
    required this.child,
    this.feedback,
  });

  final T data;
  final Widget child;
  final Widget? feedback;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<T>(
      data: data,
      delay: const Duration(milliseconds: 120),
      feedback: Material(
        color: Colors.transparent,
        child: feedback ?? child,
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: child,
      ),
      child: child,
    );
  }
}

class StructureInsertDropTarget<T extends Object> extends StatelessWidget {
  const StructureInsertDropTarget({
    super.key,
    required this.onAccept,
    this.canAccept,
  });

  final ValueChanged<T> onAccept;
  final bool Function(T data)? canAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) =>
          canAccept?.call(details.data) ?? true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: active ? 20 : 6,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: active
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.5))
                : null,
          ),
        );
      },
    );
  }
}

Widget sceneDragFeedback(SceneDraft scene, int sceneIndex) {
  final title = scene.title.trim();
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      border: Border.all(color: AppColors.accent),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Text(
      '第${sceneIndex + 1}场 ${title.isEmpty ? '场' : title}',
      style: const TextStyle(fontSize: 13),
    ),
  );
}

Widget frameDragFeedback(FrameDraft frame) {
  return Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      border: Border.all(color: AppColors.accent),
      boxShadow: const [
        BoxShadow(
          color: Color(0x22000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
  );
}
