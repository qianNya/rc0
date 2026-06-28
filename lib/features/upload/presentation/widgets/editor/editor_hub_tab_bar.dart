import 'package:flutter/material.dart';

import '../../../../../shared/widgets/feed_tab_bar.dart';
import 'editor_quick_action_row.dart';

/// Hub content tabs: 大纲 / 剧本 / 分镜.
class EditorHubTabBar extends StatelessWidget {
  const EditorHubTabBar({
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

  static const _hubModes = <EditorHubMode>[
    EditorHubMode.outline,
    EditorHubMode.script,
    EditorHubMode.frames,
  ];

  static const _tabs = ['大纲', '剧本', '分镜'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FeedTabBar(
            tabs: _tabs,
            selectedIndex: _hubModes.indexOf(selectedMode).clamp(0, _tabs.length - 1),
            onChanged: (index) => onModeSelected(_hubModes[index]),
            underlineStyle: true,
          ),
        ),
        IconButton(
          tooltip: 'AI 探索',
          onPressed: onAiDecompose,
          icon: const Icon(Icons.auto_awesome_outlined, size: 22),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          tooltip: '更多',
          onPressed: onMore,
          icon: const Icon(Icons.more_horiz, size: 22),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
