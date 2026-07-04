import '../domain/camera_body.dart';
import '../domain/cine_camera_setup.dart';
import '../domain/lens.dart';
import 'equipment_catalog.dart';
import 'equipment_repository.dart';

/// JSON + prompt helpers for [CineCameraSetup].
abstract final class EquipmentSetupMapper {
  static Map<String, dynamic> setupToJson(CineCameraSetup setup) =>
      setup.toJson();

  static CineCameraSetup? setupFromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    final setup = CineCameraSetup.fromJson(json);
    return setup.isEmpty ? null : setup;
  }

  static String displaySummary(CineCameraSetup setup) {
    if (setup.title.isNotEmpty) return setup.title;
    final body = _findBody(setup.bodyId);
    final lens = _findLens(setup.lensId);
    final parts = <String>[];
    if (body != null) parts.add(body.displayName);
    if (lens != null) parts.add(lens.displayName);
    if (setup.focalLengthMm > 0) {
      parts.add('${setup.focalLengthMm.toStringAsFixed(0)}mm');
    }
    if (setup.apertureF > 0) {
      parts.add('f/${_formatAperture(setup.apertureF)}');
    }
    return parts.isEmpty ? '未设置' : parts.join(' · ');
  }

  static String promptDescription(CineCameraSetup setup) {
    final parts = <String>[];
    final body = _findBody(setup.bodyId);
    final lens = _findLens(setup.lensId);
    if (body != null && body.promptHint.isNotEmpty) {
      parts.add(body.promptHint);
    }
    if (lens != null && lens.promptHint.isNotEmpty) {
      parts.add(lens.promptHint);
    }
    if (setup.focalLengthMm > 0) {
      parts.add('${setup.focalLengthMm.toStringAsFixed(0)}mm focal length');
    }
    if (setup.apertureF > 0) {
      parts.add('f/${_formatAperture(setup.apertureF)} aperture');
    }
    return parts.join(', ');
  }

  static String bodyLabel(CameraBody? body) =>
      body?.displayName ?? '未选择机身';

  static String lensLabel(Lens? lens) => lens?.displayName ?? '未选择镜头';

  static CameraBody? _findBody(String id) =>
      EquipmentRepository.instance.findBodyById(id) ??
      EquipmentCatalog.findBodyById(id);

  static Lens? _findLens(String id) =>
      EquipmentRepository.instance.findLensById(id) ??
      EquipmentCatalog.findLensById(id);

  static String _formatAperture(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toString();
  }
}
