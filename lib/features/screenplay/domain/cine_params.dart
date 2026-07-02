/// Cinematic / shot parameters per frame (景别/机位/运镜/焦段/构图/时长).
///
/// Roadmap: [movement] may evolve into `movement_keyframes` in `extra_params`
/// for Camera Nodes; not implemented yet.
class CineParams {
  const CineParams({
    this.shotType,
    this.cameraAngle,
    this.movement,
    this.lensMm,
    this.composition,
    this.durationSec = defaultDurationSec,
  });

  static const int defaultDurationSec = 3;

  final String? shotType;
  final String? cameraAngle;
  final String? movement;
  final String? lensMm;
  final String? composition;
  final int durationSec;

  bool get isEmpty =>
      (shotType == null || shotType!.isEmpty) &&
      (cameraAngle == null || cameraAngle!.isEmpty) &&
      (movement == null || movement!.isEmpty) &&
      (lensMm == null || lensMm!.isEmpty) &&
      (composition == null || composition!.isEmpty) &&
      durationSec == defaultDurationSec;

  CineParams copyWith({
    String? shotType,
    String? cameraAngle,
    String? movement,
    String? lensMm,
    String? composition,
    int? durationSec,
    bool clearShotType = false,
    bool clearCameraAngle = false,
    bool clearMovement = false,
    bool clearLensMm = false,
    bool clearComposition = false,
  }) {
    return CineParams(
      shotType: clearShotType ? null : (shotType ?? this.shotType),
      cameraAngle:
          clearCameraAngle ? null : (cameraAngle ?? this.cameraAngle),
      movement: clearMovement ? null : (movement ?? this.movement),
      lensMm: clearLensMm ? null : (lensMm ?? this.lensMm),
      composition:
          clearComposition ? null : (composition ?? this.composition),
      durationSec: durationSec ?? this.durationSec,
    );
  }

  Map<String, dynamic> toExtraParams({
    String? positivePrompt,
    String? negativePrompt,
  }) {
    final map = <String, dynamic>{};
    if (cameraAngle != null && cameraAngle!.isNotEmpty) {
      map['angle'] = cameraAngle;
    }
    if (movement != null && movement!.isNotEmpty) {
      map['movement'] = movement;
    }
    if (composition != null && composition!.isNotEmpty) {
      map['composition'] = composition;
    }
    if (positivePrompt != null && positivePrompt.isNotEmpty) {
      map['positive_prompt'] = positivePrompt;
    }
    if (negativePrompt != null && negativePrompt.isNotEmpty) {
      map['negative_prompt'] = negativePrompt;
    }
    return map;
  }

  factory CineParams.fromFrameMap(Map<String, dynamic> frameMap) {
    final extra = frameMap['extra_params'];
    final extraMap = extra is Map<String, dynamic>
        ? extra
        : (extra is Map ? Map<String, dynamic>.from(extra) : <String, dynamic>{});

    final lensRaw = frameMap['lens_mm'];
    String? lensMm;
    if (lensRaw != null && '$lensRaw'.isNotEmpty) {
      lensMm = '$lensRaw';
    }

    return CineParams(
      shotType: _nonEmpty(frameMap['shot_type'] as String?),
      cameraAngle: _nonEmpty(extraMap['angle'] as String?),
      movement: _nonEmpty(extraMap['movement'] as String?),
      lensMm: lensMm,
      composition: _nonEmpty(extraMap['composition'] as String?),
      durationSec: (frameMap['duration_sec'] as num?)?.toInt() ?? defaultDurationSec,
    );
  }

  static String? _nonEmpty(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String? promptsFromExtra(
    Map<String, dynamic> extraMap,
    String key,
  ) {
    return _nonEmpty(extraMap[key] as String?);
  }
}
