import '../data/screenplay_draft.dart';
import '../../lighting/data/lighting_scheme_mapper.dart';
import '../../cine_equipment/data/equipment_draft_binding.dart';
import '../../cine_equipment/data/equipment_setup_mapper.dart';
import '../domain/cine_params.dart';
import '../domain/shoot_params.dart';

/// Builds AI prompts from frame, scene, and project context.
abstract final class AiPromptBuilder {
  static const defaultNegativePrompt =
      'low quality, blurry, distorted, watermark, text, logo, bad anatomy';

  static String buildPositive({
    required FrameDraft frame,
    required SceneDraft scene,
    required ShootParams shootParams,
    String? characterAppearance,
    String? characterStylePrompt,
    List<String> propNames = const [],
  }) {
    final parts = <String>[];

    final caption = frame.caption.trim();
    if (caption.isNotEmpty) parts.add(caption);

    final action = frame.actionNote.trim();
    if (action.isNotEmpty) parts.add(action);

    final characterName = frame.characterName.trim();
    if (characterName.isNotEmpty) parts.add(characterName);

    final characterNote = frame.characterNote.trim();
    if (characterNote.isNotEmpty) {
      parts.add(characterNote);
    } else {
      final appearance = characterAppearance?.trim() ?? '';
      if (appearance.isNotEmpty) parts.add(appearance);
    }

    final stylePrompt = characterStylePrompt?.trim() ?? '';
    if (stylePrompt.isNotEmpty) parts.add(stylePrompt);

    for (final prop in propNames) {
      final name = prop.trim();
      if (name.isNotEmpty) parts.add(name);
    }

    final cine = frame.cineParams;
    final cineSetup = cineSetupFromDraftFrame(frame);
    final hasEquipment =
        cineSetup != null && !cineSetup.isEmpty;
    _addCinePart(parts, cine, skipLensMm: hasEquipment);

    if (hasEquipment) {
      final equipmentPrompt =
          EquipmentSetupMapper.promptDescription(cineSetup);
      if (equipmentPrompt.isNotEmpty) {
        parts.add(equipmentPrompt);
      }
    }

    final location = scene.location.trim();
    if (location.isNotEmpty) parts.add(location);

    final timeOfDay = scene.timeOfDay.trim();
    if (timeOfDay.isNotEmpty) parts.add(timeOfDay);

    final weather = scene.weather.trim();
    if (weather.isNotEmpty) parts.add(weather);

    if (shootParams.lighting != null && shootParams.lighting!.isNotEmpty) {
      final rigScheme = LightingSchemeMapper.rigFromJson(frame.lightingRig);
      if (rigScheme != null) {
        parts.add(LightingSchemeMapper.promptDescription(rigScheme));
      } else {
        parts.add('${shootParams.lighting} lighting');
      }
    }
    if (shootParams.aspectRatio != null && shootParams.aspectRatio!.isNotEmpty) {
      parts.add('${shootParams.aspectRatio} aspect ratio');
    }

    for (final tag in frame.tags) {
      final t = tag.trim();
      if (t.isNotEmpty) parts.add(t);
    }

    if (parts.isEmpty) {
      return 'cinematic storyboard frame, high detail, professional composition';
    }
    return parts.join(', ');
  }

  static void _addCinePart(
    List<String> parts,
    CineParams cine, {
    bool skipLensMm = false,
  }) {
    if (cine.shotType != null && cine.shotType!.isNotEmpty) {
      parts.add('${cine.shotType} shot');
    }
    if (cine.cameraAngle != null && cine.cameraAngle!.isNotEmpty) {
      parts.add('${cine.cameraAngle} camera angle');
    }
    if (cine.movement != null && cine.movement!.isNotEmpty) {
      parts.add('${cine.movement} camera movement');
    }
    if (!skipLensMm && cine.lensMm != null && cine.lensMm!.isNotEmpty) {
      parts.add('${cine.lensMm} lens');
    }
    if (cine.composition != null && cine.composition!.isNotEmpty) {
      parts.add('${cine.composition} composition');
    }
  }

  static String buildNegative({
    String? existing,
    String? characterNegativeStyle,
  }) {
    final trimmed = existing?.trim() ?? '';
    final styleNeg = characterNegativeStyle?.trim() ?? '';
    if (trimmed.isNotEmpty && styleNeg.isNotEmpty) {
      return '$trimmed, $styleNeg';
    }
    if (trimmed.isNotEmpty) return trimmed;
    if (styleNeg.isNotEmpty) {
      return '$defaultNegativePrompt, $styleNeg';
    }
    return defaultNegativePrompt;
  }
}
