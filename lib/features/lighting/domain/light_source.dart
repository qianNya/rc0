import 'dart:math' as math;

/// Role of a light in a multi-light rig.
enum LightRole {
  key,
  fill,
  rim,
  background,
}

extension LightRoleLabel on LightRole {
  String get label {
    switch (this) {
      case LightRole.key:
        return '主光';
      case LightRole.fill:
        return '辅光';
      case LightRole.rim:
        return '轮廓光';
      case LightRole.background:
        return '背景光';
    }
  }
}

enum LightType {
  softbox,
  spot,
  rim,
  ambient,
  neon,
}

extension LightTypeLabel on LightType {
  String get label {
    switch (this) {
      case LightType.softbox:
        return '柔光箱';
      case LightType.spot:
        return '聚光灯';
      case LightType.rim:
        return '轮廓灯';
      case LightType.ambient:
        return '环境光';
      case LightType.neon:
        return '霓虹灯';
    }
  }
}

enum LightQuality { hard, soft, mixed }

extension LightQualityLabel on LightQuality {
  String get label {
    switch (this) {
      case LightQuality.hard:
        return '硬光';
      case LightQuality.soft:
        return '柔光';
      case LightQuality.mixed:
        return '混合';
    }
  }
}

/// A single light in a lighting scheme rig.
class LightSource {
  const LightSource({
    required this.id,
    required this.role,
    this.type = LightType.softbox,
    this.intensity = 70,
    this.colorTempK = 5500,
    this.azimuthDeg = 45,
    this.elevationDeg = 30,
    this.quality = LightQuality.soft,
    this.colorArgb = 0xFFFFFFFF,
    this.enabled = true,
  });

  final String id;
  final LightRole role;
  final LightType type;
  final int intensity;
  final int colorTempK;
  final double azimuthDeg;
  final double elevationDeg;
  final LightQuality quality;
  final int colorArgb;
  final bool enabled;

  double get intensityFactor => (intensity.clamp(0, 100)) / 100.0;

  LightSource copyWith({
    String? id,
    LightRole? role,
    LightType? type,
    int? intensity,
    int? colorTempK,
    double? azimuthDeg,
    double? elevationDeg,
    LightQuality? quality,
    int? colorArgb,
    bool? enabled,
  }) {
    return LightSource(
      id: id ?? this.id,
      role: role ?? this.role,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      colorTempK: colorTempK ?? this.colorTempK,
      azimuthDeg: azimuthDeg ?? this.azimuthDeg,
      elevationDeg: elevationDeg ?? this.elevationDeg,
      quality: quality ?? this.quality,
      colorArgb: colorArgb ?? this.colorArgb,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'type': type.name,
        'intensity': intensity,
        'color_temp_k': colorTempK,
        'azimuth_deg': azimuthDeg,
        'elevation_deg': elevationDeg,
        'quality': quality.name,
        'color_argb': colorArgb,
        'enabled': enabled,
      };

  factory LightSource.fromJson(Map<String, dynamic> json) {
    return LightSource(
      id: json['id'] as String? ?? '',
      role: LightRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => LightRole.key,
      ),
      type: LightType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => LightType.softbox,
      ),
      intensity: (json['intensity'] as num?)?.toInt() ?? 70,
      colorTempK: (json['color_temp_k'] as num?)?.toInt() ?? 5500,
      azimuthDeg: (json['azimuth_deg'] as num?)?.toDouble() ?? 45,
      elevationDeg: (json['elevation_deg'] as num?)?.toDouble() ?? 30,
      quality: LightQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => LightQuality.soft,
      ),
      colorArgb: (json['color_argb'] as num?)?.toInt() ?? 0xFFFFFFFF,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  /// Spherical direction for 3D placement (radius = 1).
  ({double x, double y, double z}) get direction {
    final az = azimuthDeg * math.pi / 180;
    final el = elevationDeg * math.pi / 180;
    final cosEl = math.cos(el);
    return (
      x: math.sin(az) * cosEl,
      y: math.sin(el),
      z: math.cos(az) * cosEl,
    );
  }
}

String newLightId() => 'light-${DateTime.now().microsecondsSinceEpoch}';
