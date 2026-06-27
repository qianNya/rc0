import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';

enum OutlineStructureMenuScope { empty, act, scene }

RelativeRect _menuPosition(BuildContext context, Offset globalPosition) {
  final overlay = Overlay.of(context).context.findRenderObject()! as RenderBox;
  return RelativeRect.fromRect(
    Rect.fromLTWH(globalPosition.dx, globalPosition.dy, 0, 0),
    Offset.zero & overlay.size,
  );
}

Future<void> showOutlineStructureContextMenu(
  BuildContext context, {
  required Offset globalPosition,
  required OutlineStructureMenuScope scope,
  required int actIndex,
  int? sceneIndex,
  required VoidCallback onAddAct,
  required VoidCallback onAddScene,
  required Future<void> Function(int actIndex) onRemoveAct,
  required Future<void> Function(int actIndex, int sceneIndex) onRemoveScene,
  required bool canRemoveAct,
  required bool Function(int actIndex, int sceneIndex) canRemoveScene,
}) {
  final actLabel = actIndex + 1;
  final sceneLabel = sceneIndex != null ? sceneIndex + 1 : null;
  final items = <PopupMenuEntry<void>>[];

  if (scope == OutlineStructureMenuScope.empty) {
    items.add(
      PopupMenuItem<void>(
        onTap: onAddAct,
        child: const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.add_box_outlined),
          title: Text('新建幕'),
        ),
      ),
    );
  }

  if (scope == OutlineStructureMenuScope.act) {
    items.addAll([
      PopupMenuItem<void>(
        onTap: onAddScene,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.add_location_alt_outlined),
          title: Text('在第 $actLabel 幕添加场'),
        ),
      ),
      PopupMenuItem<void>(
        onTap: onAddAct,
        child: const ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.add_box_outlined),
          title: Text('新建幕'),
        ),
      ),
    ]);
    if (canRemoveAct) {
      items.add(
        PopupMenuItem<void>(
          onTap: () => onRemoveAct(actIndex),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('删除幕', style: TextStyle(color: AppColors.error)),
          ),
        ),
      );
    }
  }

  if (scope == OutlineStructureMenuScope.scene && sceneLabel != null) {
    items.add(
      PopupMenuItem<void>(
        onTap: onAddScene,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.add_location_alt_outlined),
          title: Text('在第 $actLabel 幕添加场'),
        ),
      ),
    );
    if (canRemoveScene(actIndex, sceneIndex!)) {
      items.add(
        PopupMenuItem<void>(
          onTap: () => onRemoveScene(actIndex, sceneIndex),
          child: const ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('删除场', style: TextStyle(color: AppColors.error)),
          ),
        ),
      );
    }
  }

  return showMenu<void>(
    context: context,
    position: _menuPosition(context, globalPosition),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
    ),
    items: items,
  );
}
