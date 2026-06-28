import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../../shared/widgets/profile_widgets.dart';

/// In-page content modes for the script editor hub (mobile + desktop tab 0).
enum EditorHubMode {
  outline,
  script,
  frames,
}

class EditorQuickAction {
  const EditorQuickAction({
    required this.label,
    required this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;
}

class EditorQuickActionRow extends StatelessWidget {
  const EditorQuickActionRow({
    super.key,
    required this.actions,
    this.scrollable = false,
    this.compact = false,
  });

  final List<EditorQuickAction> actions;
  final bool scrollable;
  final bool compact;

  double get _itemWidth => compact ? 52 : 72;
  double get _circleSize => compact ? 40 : 56;
  double get _iconSize => compact ? 18 : 26;
  double get _labelFontSize => compact ? 9 : 11;

  @override
  Widget build(BuildContext context) {
    Widget buildAction(EditorQuickAction action) {
      return QuickActionCircle(
        label: action.label,
        icon: action.icon,
        onTap: action.onTap,
        backgroundColor: action.selected ? AppColors.accent : null,
        iconColor: action.selected ? Colors.white : null,
        size: _circleSize,
        iconSize: _iconSize,
        labelFontSize: _labelFontSize,
        showLabel: !compact,
      );
    }

    final children = [
      for (final action in actions)
        scrollable
            ? SizedBox(width: _itemWidth, child: buildAction(action))
            : Expanded(child: buildAction(action)),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? 8 : AppDimensions.spacingMd,
      ),
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 8),
              child: Row(children: children),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: children,
            ),
    );
  }
}

/// Hub mode switcher: AI拆解 / 大纲 / 剧本 / 故事板 / 时间线 / 更多
class EditorHubModeBar extends StatelessWidget {
  const EditorHubModeBar({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
    required this.onAiDecompose,
    required this.onMore,
  });

  final EditorHubMode selectedMode;
  final ValueChanged<EditorHubMode> onModeSelected;
  final VoidCallback onAiDecompose;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return EditorQuickActionRow(
      scrollable: true,
      compact: true,
      actions: [
        EditorQuickAction(
          label: 'AI 探索',
          icon: Icons.auto_awesome_outlined,
          onTap: onAiDecompose,
        ),
        EditorQuickAction(
          label: '大纲模式',
          icon: Icons.account_tree_outlined,
          selected: selectedMode == EditorHubMode.outline,
          onTap: () => onModeSelected(EditorHubMode.outline),
        ),
        EditorQuickAction(
          label: '剧本模式',
          icon: Icons.edit_note_outlined,
          selected: selectedMode == EditorHubMode.script,
          onTap: () => onModeSelected(EditorHubMode.script),
        ),
        EditorQuickAction(
          label: '分镜',
          icon: Icons.view_comfy_outlined,
          selected: selectedMode == EditorHubMode.frames,
          onTap: () => onModeSelected(EditorHubMode.frames),
        ),
        EditorQuickAction(
          label: '更多',
          icon: Icons.more_horiz,
          onTap: onMore,
        ),
      ],
    );
  }
}

void _popSheetThen(BuildContext context, VoidCallback action) {
  final navigator = Navigator.of(context, rootNavigator: true);
  navigator.pop();
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}

void showEditorMoreActionsSheet(
  BuildContext context, {
  required VoidCallback onBatchEdit,
  VoidCallback? onOpenShotList,
  VoidCallback? onOpenProjectSettings,
}) {
  showGlassSheet<void>(
    context,
    useRootNavigator: true,
    padding: kGlassSheetMenuPadding,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onOpenProjectSettings != null)
          ListTile(
            leading: const Icon(Icons.tune_outlined),
            title: const Text('项目设置'),
            onTap: () => _popSheetThen(context, onOpenProjectSettings),
          ),
        if (onOpenShotList != null)
          ListTile(
            leading: const Icon(Icons.movie_outlined),
            title: const Text('分镜列表'),
            onTap: () => _popSheetThen(context, onOpenShotList),
          ),
        ListTile(
          leading: const Icon(Icons.checklist_outlined),
          title: const Text('批量编辑'),
          onTap: () => _popSheetThen(context, onBatchEdit),
        ),
      ],
    ),
  );
}
