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
    this.axis = Axis.vertical,
    this.inactiveExtent = 6,
    this.activeExtent = 20,
    this.activeExtentForData,
    this.crossExtent,
  });

  final ValueChanged<T> onAccept;
  final bool Function(T data)? canAccept;
  final Axis axis;
  final double inactiveExtent;
  final double activeExtent;
  final double Function(T data)? activeExtentForData;
  /// Fixed size on the axis perpendicular to [axis] (e.g. track height).
  final double? crossExtent;

  @override
  Widget build(BuildContext context) {
    return DragTarget<T>(
      onWillAcceptWithDetails: (details) =>
          canAccept?.call(details.data) ?? true,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        final dragged = candidate.isNotEmpty ? candidate.first : null;
        final mainExtent = active
            ? (dragged != null && activeExtentForData != null
                ? activeExtentForData!(dragged)
                : activeExtent)
            : inactiveExtent;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          width: axis == Axis.horizontal ? mainExtent : crossExtent,
          height: axis == Axis.vertical ? mainExtent : crossExtent,
          margin: axis == Axis.horizontal
              ? const EdgeInsets.symmetric(horizontal: 1)
              : const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accent.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: active
                ? Border.all(color: AppColors.accent.withValues(alpha: 0.45))
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
          color: AppColors.shadowDrag,
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

/// Drag feedback matching the outline scene card chrome.
Widget sceneOutlineCardDragFeedback(SceneDraft scene, int sceneIndex) {
  final title = scene.title.trim();
  return Material(
    color: AppColors.surfaceSecondary,
    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    child: Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.accent),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowDrag,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_handle, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '第${sceneIndex + 1}场 · ${title.isEmpty ? '场' : title}',
              style: const TextStyle(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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
          color: AppColors.shadowDrag,
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Icon(Icons.image_outlined, color: AppColors.textSecondary),
  );
}
