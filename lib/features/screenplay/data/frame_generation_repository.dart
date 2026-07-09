import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../core/auth/auth_bridge.dart';
import '../../../core/media/app_media_upload_service.dart';
import '../../../core/network/api_callback.dart';
import '../../character/data/character_repository.dart';
import '../../upload/data/image_pick_service.dart';
import '../../upload/domain/upload_image_file.dart';
import '../../../api/character/api/character-api.dart' as character_api;
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
      String? appearance;
      String? stylePrompt;
      String? negativeStyle;
      final propNames = <String>[];
      final characterId = frame.characterId;
      if (characterId != null) {
        final detail =
            await CharacterRepository.instance.fetchDetail(characterId);
        final entry = detail.character;
        if (entry != null) {
          appearance = entry.appearance;
          if (entry.style.promptFragment.isNotEmpty) {
            stylePrompt = entry.style.promptFragment;
          }
          if (entry.style.negativeFragment.isNotEmpty) {
            negativeStyle = entry.style.negativeFragment;
          }
        }
        if (frame.costumeId != null) {
          final costumes =
              await CharacterRepository.instance.listCostumes(characterId);
          for (final c in costumes.items) {
            if (c.id == frame.costumeId && c.description.isNotEmpty) {
              appearance = c.description;
              break;
            }
          }
        }
        if (frame.propIds.isNotEmpty) {
          final props =
              await CharacterRepository.instance.listProps(characterId);
          for (final id in frame.propIds) {
            for (final p in props.items) {
              if (p.id == id) propNames.add(p.name);
            }
          }
        }
      }
      frame.positivePrompt = AiPromptBuilder.buildPositive(
        frame: frame,
        scene: scene,
        shootParams: shootParams,
        characterAppearance: appearance,
        characterStylePrompt: stylePrompt,
        propNames: propNames,
      );
      if (frame.negativePrompt.trim().isEmpty) {
        frame.negativePrompt = AiPromptBuilder.buildNegative(
          existing: negativeStyle,
        );
      }
    }

    try {
      final result = await _imagePickService.pickImages();
      if (result.added.isEmpty) {
        return const FrameGenerationResult(error: '未选择图片');
      }

      var image = result.added.first;
      int? uploadedImageId;

      if (uploadToCloud && AuthBridge.isLoggedIn && !kIsWeb) {
        final file = File(image.path);
        if (await file.exists()) {
          final uploaded =
              await AppMediaUploadService.instance.uploadLocalFile(file.path);
          if (uploaded.error != null) {
            return FrameGenerationResult(error: uploaded.error);
          }
          uploadedImageId = uploaded.result?.imageId;
          final displayUrl = uploaded.result?.displayUrl;
          if (displayUrl != null && displayUrl.isNotEmpty) {
            image = UploadImageFile(
              path: displayUrl,
              name: image.name,
            );
          }
        }
      }

      // PRD relation_type=7: archive generation result against bound character.
      final characterId = frame.characterId;
      if (uploadedImageId != null &&
          uploadedImageId > 0 &&
          characterId != null &&
          characterId > 0) {
        await apiCallback<Map<String, dynamic>>(
          ({ok, fail, eventually}) => character_api.linkImageCharacter(
            uploadedImageId!,
            characterId: characterId,
            relationType: 7,
            ok: ok,
            fail: fail,
            eventually: eventually,
          ),
        );
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
