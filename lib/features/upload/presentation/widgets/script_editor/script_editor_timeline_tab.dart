import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/screenplay_draft.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import 'script_editor_actions.dart';
import 'script_editor_navigation.dart';
import 'storyboard_playback_bar.dart';

class ScriptEditorTimelineTab extends StatefulWidget {
  const ScriptEditorTimelineTab({
    super.key,
    required this.draft,
    this.actions,
    this.filterActIndex,
    this.filterSceneIndex,
  });

  final ScreenplayDraft draft;
  final ScriptEditorActions? actions;
  final int? filterActIndex;
  final int? filterSceneIndex;

  @override
  State<ScriptEditorTimelineTab> createState() =>
      _ScriptEditorTimelineTabState();
}

class _ScriptEditorTimelineTabState extends State<ScriptEditorTimelineTab> {
  int? _filterActIndex;
  int? _filterSceneIndex;

  @override
  void initState() {
    super.initState();
    _filterActIndex = widget.filterActIndex;
    _filterSceneIndex = widget.filterSceneIndex;
  }

  List<DraftFrameRef> get _refs => draftAllFrameRefs(
        widget.draft,
        filterActIndex: _filterActIndex,
        filterSceneIndex: _filterSceneIndex,
      );

  String get _sceneLabel {
    if (_filterActIndex != null && _filterSceneIndex != null) {
      final scene =
          widget.draft.acts[_filterActIndex!].scenes[_filterSceneIndex!];
      final title = scene.title.trim().isEmpty
          ? '第${_filterSceneIndex! + 1}场'
          : scene.title.trim();
      return '$title（${scene.frames.length}画）';
    }
    return '全部场次（${_refs.length}画）';
  }

  @override
  Widget build(BuildContext context) {
    final refs = _refs;
    if (refs.isEmpty) {
      return const EmptyStateView(
        icon: Icons.timeline_outlined,
        title: '暂无时间线',
        subtitle: '添加分镜画面后，可在此预览时长顺序',
      );
    }

    final totalSec = refs.fold(
      0,
      (sum, ref) => sum + ref.frame.cineParams.durationSec,
    );

    return Column(
      children: [
        if (widget.filterActIndex == null && widget.filterSceneIndex == null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                draftHierarchySummary(widget.draft),
                style: AppTextStyles.bodySecondary,
              ),
            ),
          ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: refs.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (context, index) {
                    final ref = refs[index];
                    final width =
                        (ref.frame.cineParams.durationSec * 24.0).clamp(48.0, 160.0);
                    return GestureDetector(
                      onTap: widget.actions == null
                          ? null
                          : () => openFrameEditorDetail(
                                context,
                                actions: widget.actions!,
                                actIndex: ref.actIndex,
                                sceneIndex: ref.sceneIndex,
                                frameIndex: ref.frameIndex,
                              ),
                      child: Container(
                        width: width,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.accent),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ref.shotLabel,
                              style: AppTextStyles.label.copyWith(fontSize: 12),
                            ),
                            Text(
                              '${ref.frame.cineParams.durationSec}秒',
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        StoryboardPlaybackBar(
          sceneLabel: _sceneLabel,
          frameCount: refs.length,
          totalDurationSec: totalSec,
          onPlay: () => showPlaybackComingSoon(context),
        ),
      ],
    );
  }
}
