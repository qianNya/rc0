import 'package:flutter/material.dart';

import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../widgets/editor/editor_footer_actions.dart';
import '../widgets/project_settings_form.dart';

class ProjectSettingsPage extends StatelessWidget {
  const ProjectSettingsPage({
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
    this.onSyncTitle,
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
  final VoidCallback? onSyncTitle;

  void _save(BuildContext context) {
    onSyncTitle?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('项目设置')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProjectSettingsForm(
                  draft: draft,
                  titleController: titleController,
                  synopsisController: synopsisController,
                  onShootParamsChanged: onShootParamsChanged,
                  poolTags: poolTags,
                  onToggleScreenplayTag: onToggleScreenplayTag,
                  onAddScreenplayTag: onAddScreenplayTag,
                  tagsLoading: tagsLoading,
                  tagsError: tagsError,
                  onRetryTags: onRetryTags,
                  onPickCover: onPickCover,
                  onResetCover: onResetCover,
                ),
              ],
            ),
          ),
          EditorFooterActions(
            saveLabel: '保存设置',
            onSave: () => _save(context),
          ),
        ],
      ),
    );
  }
}
