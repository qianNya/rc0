import 'dart:io';

import '../../../core/auth/auth_bridge.dart';
import '../../../core/media/app_media_upload_service.dart';
import '../../upload/data/image_pick_service.dart';
import '../../upload/domain/upload_image_file.dart';
import '../domain/ai_prompt_builder.dart';
import 'screenplay_draft.dart';
import 'shoot_params_draft.dart';

class FrameGenerationResult {
  const FrameGenerationResult({this.error, this.image});

  final String? error;
  final UploadImageFile? image;

  bool get isSuccess => error == null && image != null;
}

/// Encapsulates frame image generation workflow.
/// Current: pick image + optional cloud upload via POST /images.
/// TODO: replace with POST /generation/... when backend is ready.
class FrameGenerationRepository {
  FrameGenerationRepository._();

  static final FrameGenerationRepository instance =
      FrameGenerationRepository._();

  final _imagePickService = ImagePickService();

  Future<FrameGenerationResult> generateImageForFrame({
    required ScreenplayDraft draft,
    required int actIndex,
    required int sceneIndex,
    required int frameIndex,
    bool uploadToCloud = true,
  }) async {
    final frame = draft.acts[actIndex].scenes[sceneIndex].frames[frameIndex];
    final scene = draft.acts[actIndex].scenes[sceneIndex];

    if (frame.positivePrompt.trim().isEmpty) {
      final shootParams = effectiveParamsForFrame(
        draft,
        actIndex,
        sceneIndex,
        frameIndex,
      );
      frame.positivePrompt = AiPromptBuilder.buildPositive(
        frame: frame,
        scene: scene,
        shootParams: shootParams,
      );
      if (frame.negativePrompt.trim().isEmpty) {
        frame.negativePrompt = AiPromptBuilder.defaultNegativePrompt;
      }
    }

    try {
      final result = await _imagePickService.pickImages();
      if (result.added.isEmpty) {
        return const FrameGenerationResult(error: '未选择图片');
      }

      var image = result.added.first;

      if (uploadToCloud && AuthBridge.isLoggedIn) {
        final file = File(image.path);
        if (await file.exists()) {
          final uploaded =
              await AppMediaUploadService.instance.uploadLocalFile(file.path);
          if (uploaded.error != null) {
            return FrameGenerationResult(error: uploaded.error);
          }
        }
      }

      frame.image = image;
      return FrameGenerationResult(image: image);
    } catch (e) {
      return FrameGenerationResult(error: '生成失败：$e');
    }
  }

  Future<FrameGenerationResult> addReferenceImage({
    required FrameDraft frame,
  }) async {
    try {
      final result = await _imagePickService.pickImages();
      if (result.added.isEmpty) {
        return const FrameGenerationResult(error: '未选择参考图');
      }
      frame.referenceImages.addAll(result.added);
      return FrameGenerationResult(image: result.added.first);
    } catch (e) {
      return FrameGenerationResult(error: '添加参考图失败：$e');
    }
  }

  Future<String?> generateVideoForFrame() async {
    // TODO: POST /generation/video when backend is ready.
    return '视频生成即将上线';
  }
}
