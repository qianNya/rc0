import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../screenplay/data/screenplay_draft.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../domain/upload_image_file.dart';

class FrameListEditor extends StatelessWidget {
  const FrameListEditor({
    super.key,
    required this.frames,
    required this.onRemove,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    this.compact = false,
  });

  final List<FrameDraft> frames;
  final ValueChanged<int> onRemove;
  final void Function(int index, String value) onCaptionChanged;
  final void Function(int index, String value) onActionNoteChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (frames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('画 · 分镜画面', style: AppTextStyles.label),
        const SizedBox(height: 8),
        ...List.generate(frames.length, (index) {
          final frame = frames[index];
          final paths = frames.map((f) => f.image.path).toList();
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => showImagePreview(
                    context,
                    imagePaths: paths,
                    initialIndex: index,
                    captions: frames.map((f) => f.caption).toList(),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    child: Image.file(
                      File(frame.image.path),
                      width: compact ? 72 : 88,
                      height: compact ? 72 : 88,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          hintText: '画面说明',
                          isDense: true,
                        ),
                        onChanged: (v) => onCaptionChanged(index, v),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        decoration: const InputDecoration(
                          hintText: '动作/拍摄要点',
                          isDense: true,
                        ),
                        onChanged: (v) => onActionNoteChanged(index, v),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => onRemove(index),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class SceneEditorSection extends StatelessWidget {
  const SceneEditorSection({
    super.key,
    required this.scene,
    required this.sceneIndex,
    required this.actIndex,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
    required this.frames,
    required this.onPickFrames,
    required this.onRemoveFrame,
    required this.onCaptionChanged,
    required this.onActionNoteChanged,
    this.compact = false,
  });

  final SceneDraft scene;
  final int sceneIndex;
  final int actIndex;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool canRemove;
  final List<FrameDraft> frames;
  final VoidCallback onPickFrames;
  final ValueChanged<int> onRemoveFrame;
  final void Function(int index, String value) onCaptionChanged;
  final void Function(int index, String value) onActionNoteChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '第${sceneIndex + 1}场',
                style: AppTextStyles.label,
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: scene.title,
            decoration: const InputDecoration(hintText: '场标题'),
            onChanged: (v) {
              scene.title = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: scene.location,
                  decoration: const InputDecoration(hintText: '地点'),
                  onChanged: (v) {
                    scene.location = v;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: scene.timeOfDay,
                  decoration: const InputDecoration(hintText: '时间'),
                  onChanged: (v) {
                    scene.timeOfDay = v;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: scene.description,
            decoration: const InputDecoration(hintText: '场描述'),
            maxLines: 2,
            onChanged: (v) {
              scene.description = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onPickFrames,
            icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
            label: const Text('添加画面'),
          ),
          const SizedBox(height: 8),
          FrameListEditor(
            frames: frames,
            onRemove: onRemoveFrame,
            onCaptionChanged: onCaptionChanged,
            onActionNoteChanged: onActionNoteChanged,
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class ActEditorSection extends StatelessWidget {
  const ActEditorSection({
    super.key,
    required this.act,
    required this.actIndex,
    required this.onChanged,
    required this.onRemove,
    required this.canRemove,
    required this.onAddScene,
    required this.sceneBuilder,
  });

  final ActDraft act;
  final int actIndex;
  final VoidCallback onChanged;
  final VoidCallback onRemove;
  final bool canRemove;
  final VoidCallback onAddScene;
  final Widget Function(int sceneIndex) sceneBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('第${actIndex + 1}幕', style: AppTextStyles.title),
              const Spacer(),
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: '幕标题'),
            onChanged: (v) {
              act.title = v;
              onChanged();
            },
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: '幕简介'),
            maxLines: 2,
            onChanged: (v) {
              act.synopsis = v;
              onChanged();
            },
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < act.scenes.length; i++) sceneBuilder(i),
          TextButton.icon(
            onPressed: onAddScene,
            icon: const Icon(Icons.add),
            label: const Text('添加场'),
          ),
        ],
      ),
    );
  }
}

/// Pick target for image picker within draft hierarchy.
class FramePickTarget {
  FramePickTarget({required this.actIndex, required this.sceneIndex});

  final int actIndex;
  final int sceneIndex;
}

void addImagesToScene(
  ScreenplayDraft draft,
  FramePickTarget target,
  List<UploadImageFile> images,
) {
  final scene = draft.acts[target.actIndex].scenes[target.sceneIndex];
  for (final image in images) {
    scene.frames.add(FrameDraft(image: image));
  }
}

int countDraftFrames(ScreenplayDraft draft) {
  var count = 0;
  for (final act in draft.acts) {
    for (final scene in act.scenes) {
      count += scene.frames.length;
    }
  }
  return count;
}
