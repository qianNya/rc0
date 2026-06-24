import 'package:flutter/material.dart';

import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import 'project_settings_form.dart';

/// Full preview + settings form for create-mode upload flow.
class UploadScreenplayPreviewSection extends StatelessWidget {
  const UploadScreenplayPreviewSection({
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

  @override
  Widget build(BuildContext context) {
    return ProjectSettingsForm(
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
    );
  }
}
