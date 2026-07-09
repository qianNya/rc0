import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/data/screenplay_draft_tags.dart';
import '../../../screenplay/domain/shoot_params.dart';
import 'collapsible_tag_picker.dart';
import 'editor/screenplay_characters_section.dart';
import 'editor/screenplay_scenes_section.dart';
import 'project_default_preset_section.dart';

const _coverAspectRatio = 16 / 9;
const _settingsTabs = ['基础设置', '参数设置'];

InputDecoration _settingsFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    border: const OutlineInputBorder(),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
      vertical: AppDimensions.spacingSm,
    ),
  );
}

/// Project settings with switchable basic / params tabs.
class ProjectSettingsForm extends StatefulWidget {
  const ProjectSettingsForm({
    super.key,
    required this.draft,
    required this.titleController,
    required this.synopsisController,
    required this.onShootParamsChanged,
    required this.poolTags,
    required this.onToggleScreenplayTag,
    required this.onAddScreenplayTag,
    this.tagsLoading = false,
    this.tagsError,
    this.onRetryTags,
    this.onPickCover,
    this.onResetCover,
    this.onCharactersChanged,
    this.remoteScreenplayId,
    this.useGlassFields = false,
    this.tabIndex,
    this.onTabChanged,
  });

  final ScreenplayDraft draft;
  final TextEditingController titleController;
  final TextEditingController synopsisController;
  final ValueChanged<ShootParams> onShootParamsChanged;
  final List<String> poolTags;
  final ValueChanged<String> onToggleScreenplayTag;
  final Future<void> Function(String) onAddScreenplayTag;
  final bool tagsLoading;
  final String? tagsError;
  final VoidCallback? onRetryTags;
  final VoidCallback? onPickCover;
  final VoidCallback? onResetCover;
  final VoidCallback? onCharactersChanged;
  final int? remoteScreenplayId;
  final bool useGlassFields;
  final int? tabIndex;
  final ValueChanged<int>? onTabChanged;

  @override
  State<ProjectSettingsForm> createState() => _ProjectSettingsFormState();
}

class _ProjectSettingsFormState extends State<ProjectSettingsForm> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.tabIndex ?? 0;
  }

  @override
  void didUpdateWidget(covariant ProjectSettingsForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tabIndex != null && widget.tabIndex != oldWidget.tabIndex) {
      _tabIndex = widget.tabIndex!;
    }
  }

  void _setTab(int index) {
    if (_tabIndex == index) return;
    setState(() => _tabIndex = index);
    widget.onTabChanged?.call(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FeedTabBar(
          tabs: _settingsTabs,
          selectedIndex: _tabIndex,
          onChanged: _setTab,
          underlineStyle: true,
          embedded: true,
        ),
        const SizedBox(height: AppDimensions.spacingSm),
        Expanded(
          child: FadeSlideIndexedStack(
            index: _tabIndex,
            children: [
              _SettingsTabScroll(child: _buildBasicTab()),
              _SettingsTabScroll(child: _buildParamsTab()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBasicTab() {
    final coverPath = draftCoverDisplayPath(widget.draft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: SizedBox(
                width: 108,
                child: AspectRatio(
                  aspectRatio: _coverAspectRatio,
                  child: coverPath != null
                      ? PoseCoverImage(
                          imagePath: coverPath,
                          expand: true,
                          borderRadius: AppDimensions.radiusMd,
                          enablePreview: false,
                        )
                      : const PlaceholderImage(
                          aspectRatio: _coverAspectRatio,
                          borderRadius: AppDimensions.radiusMd,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (widget.onPickCover != null)
              OutlinedButton(
                onPressed: widget.onPickCover,
                child: const Text('更换封面'),
              ),
            if (!widget.draft.usesDefaultCover && widget.onResetCover != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: widget.onResetCover,
                child: const Text('恢复默认'),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (widget.useGlassFields) ...[
          GlassTextField(
            controller: widget.titleController,
            hintText: '项目名称',
          ),
          const SizedBox(height: 10),
          GlassTextField(
            controller: widget.synopsisController,
            hintText: '项目简介',
            maxLines: 4,
            minLines: 2,
          ),
        ] else ...[
          TextField(
            controller: widget.titleController,
            style: AppTextStyles.title,
            decoration: _settingsFieldDecoration('项目名称'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: widget.synopsisController,
            style: AppTextStyles.body,
            maxLines: 4,
            decoration: _settingsFieldDecoration('项目简介'),
          ),
        ],
        const SizedBox(height: 14),
        ScreenplayCharactersSection(
          draft: widget.draft,
          onChanged: widget.onCharactersChanged ?? () {},
          remoteScreenplayId: widget.remoteScreenplayId,
        ),
        const SizedBox(height: 14),
        ScreenplayScenesSection(
          draft: widget.draft,
          onChanged: widget.onCharactersChanged ?? () {},
        ),
        const SizedBox(height: 14),
        CollapsibleTagPicker(
          title: '标签',
          poolTags: widget.poolTags,
          selectedTags: widget.draft.tags,
          badgeCount: widget.poolTags.length,
          collapsedSummaryTags: draftTagPoolSorted(widget.draft),
          onToggle: widget.onToggleScreenplayTag,
          onAdd: widget.onAddScreenplayTag,
          loading: widget.tagsLoading,
          error: widget.tagsError,
          onRetry: widget.onRetryTags,
        ),
      ],
    );
  }

  Widget _buildParamsTab() {
    return ProjectDefaultPresetSection(
      params: widget.draft.defaultParams,
      onChanged: widget.onShootParamsChanged,
      compact: true,
    );
  }
}

class _SettingsTabScroll extends StatelessWidget {
  const _SettingsTabScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 4, bottom: AppDimensions.spacingSm),
      child: child,
    );
  }
}
