import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import 'project_settings_form.dart';

/// Opens project settings in a liquid-glass bottom sheet for direct editing.
Future<void> showProjectSettingsSheet(
  BuildContext context, {
  required ScreenplayDraft draft,
  required TextEditingController titleController,
  required TextEditingController synopsisController,
  required ValueChanged<ShootParams> onShootParamsChanged,
  required List<String> poolTags,
  required ValueChanged<String> onToggleScreenplayTag,
  required Future<void> Function(String) onAddScreenplayTag,
  bool tagsLoading = false,
  String? tagsError,
  VoidCallback? onRetryTags,
  VoidCallback? onPickCover,
  VoidCallback? onResetCover,
  VoidCallback? onSyncTitle,
}) {
  return showGlassScrollSheet<void>(
    context,
    useRootNavigator: true,
    maxHeightFraction: 0.72,
    builder: (context, maxHeight) {
      return _ProjectSettingsSheetBody(
        maxHeight: maxHeight,
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
    },
  ).whenComplete(() => onSyncTitle?.call());
}

class _ProjectSettingsSheetBody extends StatefulWidget {
  const _ProjectSettingsSheetBody({
    required this.maxHeight,
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

  final double maxHeight;
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
  State<_ProjectSettingsSheetBody> createState() =>
      _ProjectSettingsSheetBodyState();
}

class _ProjectSettingsSheetBodyState extends State<_ProjectSettingsSheetBody> {
  void _refreshLocal() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingLg,
          0,
          AppDimensions.spacingLg,
          AppDimensions.spacingSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '项目设置',
              style: AppTextStyles.title.copyWith(fontSize: 17),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: ProjectSettingsForm(
                draft: widget.draft,
                titleController: widget.titleController,
                synopsisController: widget.synopsisController,
                onShootParamsChanged: widget.onShootParamsChanged,
                poolTags: widget.poolTags,
                onToggleScreenplayTag: widget.onToggleScreenplayTag,
                onAddScreenplayTag: widget.onAddScreenplayTag,
                tagsLoading: widget.tagsLoading,
                tagsError: widget.tagsError,
                onRetryTags: widget.onRetryTags,
                onPickCover: widget.onPickCover,
                onResetCover: widget.onResetCover,
                onCharactersChanged: _refreshLocal,
                useGlassFields: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
