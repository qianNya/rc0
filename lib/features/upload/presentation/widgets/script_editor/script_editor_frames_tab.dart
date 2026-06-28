import 'package:flutter/material.dart';

import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../shared/widgets/glass/glass.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import 'script_editor_actions.dart';
import 'script_editor_storyboard_tab.dart';
import 'script_editor_timeline_tab.dart';

/// Hub「分镜」Tab — 网格（故事板）与时间线内部分段切换。
class ScriptEditorFramesTab extends StatefulWidget {
  const ScriptEditorFramesTab({
    super.key,
    required this.draft,
    required this.actions,
    this.embeddedInHub = false,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions actions;
  final bool embeddedInHub;

  @override
  State<ScriptEditorFramesTab> createState() => _ScriptEditorFramesTabState();
}

class _ScriptEditorFramesTabState extends State<ScriptEditorFramesTab> {
  int _viewIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassSegmentedControl(
          segments: const ['故事版', '时间线'],
          selectedIndex: _viewIndex,
          onChanged: (index) => setState(() => _viewIndex = index),
          margin: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            6,
            AppDimensions.spacingMd,
            0,
          ),
        ),
        Expanded(
          child: IndexedStack(
            index: _viewIndex,
            children: [
              ScriptEditorStoryboardTab(
                draft: widget.draft,
                actions: widget.actions,
                embeddedInHub: widget.embeddedInHub,
              ),
              ScriptEditorTimelineTab(
                draft: widget.draft,
                actions: widget.actions,
                embeddedInHub: widget.embeddedInHub,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
