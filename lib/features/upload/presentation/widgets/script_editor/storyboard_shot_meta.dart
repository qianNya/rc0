import '../../../../screenplay/domain/cine_params.dart';

/// One-line camera meta for storyboard cards, e.g. `85mm | 平视 | 三分法`.
String storyboardShotMetaLine(CineParams params) {
  final parts = <String>[];
  final lens = params.lensMm?.trim();
  if (lens != null && lens.isNotEmpty) {
    parts.add(lens.endsWith('mm') ? lens : '${lens}mm');
  }
  final angle = params.cameraAngle?.trim();
  if (angle != null && angle.isNotEmpty) {
    parts.add(angle);
  }
  final composition = params.composition?.trim();
  if (composition != null && composition.isNotEmpty) {
    parts.add(composition);
  }
  return parts.join(' | ');
}

String storyboardShotDurationLabel(int durationSec) =>
    '${durationSec.toStringAsFixed(1)}s';

String storyboardShotSequenceLabel(int index) =>
    (index + 1).toString().padLeft(2, '0');
