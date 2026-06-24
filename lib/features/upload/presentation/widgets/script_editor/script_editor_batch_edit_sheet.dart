import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../screenplay/data/cine_params_draft.dart';
import '../../../../screenplay/data/screenplay_draft.dart';

enum BatchEditScope { entireScript, act, scene }

class ScriptEditorBatchEditSheet extends StatefulWidget {
  const ScriptEditorBatchEditSheet({
    super.key,
    required this.draft,
    required this.scope,
    this.actIndex,
    this.sceneIndex,
    required this.onApply,
    this.frameRefs,
    this.tagsOnly = false,
  });

  final ScreenplayDraft draft;
  final BatchEditScope scope;
  final int? actIndex;
  final int? sceneIndex;
  final VoidCallback onApply;
  final List<DraftFrameRef>? frameRefs;
  final bool tagsOnly;

  static Future<void> show(
    BuildContext context, {
    required ScreenplayDraft draft,
    required BatchEditScope scope,
    int? actIndex,
    int? sceneIndex,
    required VoidCallback onApply,
    List<DraftFrameRef>? frameRefs,
    bool tagsOnly = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ScriptEditorBatchEditSheet(
          draft: draft,
          scope: scope,
          actIndex: actIndex,
          sceneIndex: sceneIndex,
          onApply: onApply,
          frameRefs: frameRefs,
          tagsOnly: tagsOnly,
        ),
      ),
    );
  }

  @override
  State<ScriptEditorBatchEditSheet> createState() =>
      _ScriptEditorBatchEditSheetState();
}

class _ScriptEditorBatchEditSheetState extends State<ScriptEditorBatchEditSheet> {
  int? _durationSec;
  String? _shotType;
  final _tagController = TextEditingController();
  bool _removeTag = false;

  void _apply() {
    final frames = _targetFrames();
    for (final frame in frames) {
      if (!widget.tagsOnly) {
        if (_durationSec != null) {
          frame.cineParams =
              frame.cineParams.copyWith(durationSec: _durationSec);
        }
        if (_shotType != null && _shotType!.isNotEmpty) {
          frame.cineParams = frame.cineParams.copyWith(shotType: _shotType);
        }
      }
      final tag = _tagController.text.trim();
      if (tag.isNotEmpty) {
        if (_removeTag) {
          frame.tags.remove(tag);
        } else {
          frame.tags.add(tag);
        }
      }
    }
    widget.onApply();
    Navigator.of(context).pop();
  }

  Iterable<FrameDraft> _targetFrames() {
    if (widget.frameRefs != null && widget.frameRefs!.isNotEmpty) {
      return widget.frameRefs!.map((r) => r.frame);
    }
    final actIndex =
        widget.scope == BatchEditScope.entireScript ? null : widget.actIndex;
    final sceneIndex =
        widget.scope == BatchEditScope.scene ? widget.sceneIndex : null;
    return draftFramesInScope(
      widget.draft,
      actIndex: actIndex,
      sceneIndex: sceneIndex,
    );
  }

  String get _scopeLabel {
    final count = _targetFrames().length;
    switch (widget.scope) {
      case BatchEditScope.entireScript:
        return '全剧本（$count 画）';
      case BatchEditScope.act:
        return '当前幕（$count 画）';
      case BatchEditScope.scene:
        return '当前场（$count 画）';
    }
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('批量编辑', style: AppTextStyles.title),
            const SizedBox(height: 4),
            Text(_scopeLabel, style: AppTextStyles.bodySecondary),
            const SizedBox(height: 16),
            if (!widget.tagsOnly) ...[
              DropdownButtonFormField<int>(
                initialValue: _durationSec,
                decoration: const InputDecoration(
                  labelText: '统一时长（可选）',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('不修改')),
                  DropdownMenuItem(value: 1, child: Text('1秒')),
                  DropdownMenuItem(value: 2, child: Text('2秒')),
                  DropdownMenuItem(value: 3, child: Text('3秒')),
                  DropdownMenuItem(value: 5, child: Text('5秒')),
                  DropdownMenuItem(value: 8, child: Text('8秒')),
                ],
                onChanged: (v) => setState(() => _durationSec = v),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _shotType,
                decoration: const InputDecoration(
                  labelText: '统一景别（可选）',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: null, child: Text('不修改')),
                  DropdownMenuItem(value: '全景', child: Text('全景')),
                  DropdownMenuItem(value: '中景', child: Text('中景')),
                  DropdownMenuItem(value: '近景', child: Text('近景')),
                  DropdownMenuItem(value: '特写', child: Text('特写')),
                ],
                onChanged: (v) => setState(() => _shotType = v),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _tagController,
              decoration: const InputDecoration(
                labelText: '标签',
                hintText: '输入要批量添加或移除的标签',
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('移除标签（而非添加）'),
              value: _removeTag,
              onChanged: (v) => setState(() => _removeTag = v),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _apply,
                child: const Text('应用到选中范围'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
