/// Shooting parameters: device, aspect ratio, focal length, lighting.
class ShootParams {
  const ShootParams({
    this.device,
    this.aspectRatio,
    this.lensMm,
    this.lighting,
  });

  final String? device;
  final String? aspectRatio;
  final String? lensMm;
  final String? lighting;

  bool get isEmpty =>
      (device == null || device!.isEmpty) &&
      (aspectRatio == null || aspectRatio!.isEmpty) &&
      (lensMm == null || lensMm!.isEmpty) &&
      (lighting == null || lighting!.isEmpty);

  bool get hasAnyValue =>
      (device != null && device!.isNotEmpty) ||
      (aspectRatio != null && aspectRatio!.isNotEmpty) ||
      (lensMm != null && lensMm!.isNotEmpty) ||
      (lighting != null && lighting!.isNotEmpty);

  ShootParams copyWith({
    String? device,
    String? aspectRatio,
    String? lensMm,
    String? lighting,
    bool clearDevice = false,
    bool clearAspectRatio = false,
    bool clearLensMm = false,
    bool clearLighting = false,
  }) {
    return ShootParams(
      device: clearDevice ? null : (device ?? this.device),
      aspectRatio: clearAspectRatio ? null : (aspectRatio ?? this.aspectRatio),
      lensMm: clearLensMm ? null : (lensMm ?? this.lensMm),
      lighting: clearLighting ? null : (lighting ?? this.lighting),
    );
  }

  Map<String, dynamic> toJson() => {
        if (device != null && device!.isNotEmpty) 'device': device,
        if (aspectRatio != null && aspectRatio!.isNotEmpty)
          'aspect_ratio': aspectRatio,
        if (lensMm != null && lensMm!.isNotEmpty) 'lens_mm': lensMm,
        if (lighting != null && lighting!.isNotEmpty) 'lighting': lighting,
      };

  factory ShootParams.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ShootParams();
    return ShootParams(
      device: json['device'] as String?,
      aspectRatio: json['aspect_ratio'] as String? ?? json['aspectRatio'] as String?,
      lensMm: json['lens_mm'] as String? ?? json['lensMm'] as String?,
      lighting: json['lighting'] as String?,
    );
  }

  /// Merge [override] on top of [base]; null fields in override inherit from base.
  static ShootParams resolve(ShootParams base, ShootParams? override) {
    if (override == null || override.isEmpty) return base;
    return ShootParams(
      device: override.device ?? base.device,
      aspectRatio: override.aspectRatio ?? base.aspectRatio,
      lensMm: override.lensMm ?? base.lensMm,
      lighting: override.lighting ?? base.lighting,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShootParams &&
      other.device == device &&
      other.aspectRatio == aspectRatio &&
      other.lensMm == lensMm &&
      other.lighting == lighting;

  @override
  int get hashCode => Object.hash(device, aspectRatio, lensMm, lighting);
}

/// Partial override: each null field inherits from parent level.
typedef ShootParamsOverride = ShootParams;
