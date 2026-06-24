/// Shooting parameters: device, aspect ratio, lighting.
class ShootParams {
  const ShootParams({this.device, this.aspectRatio, this.lighting});

  final String? device;
  final String? aspectRatio;
  final String? lighting;

  bool get isEmpty =>
      (device == null || device!.isEmpty) &&
      (aspectRatio == null || aspectRatio!.isEmpty) &&
      (lighting == null || lighting!.isEmpty);

  bool get hasAnyValue =>
      (device != null && device!.isNotEmpty) ||
      (aspectRatio != null && aspectRatio!.isNotEmpty) ||
      (lighting != null && lighting!.isNotEmpty);

  ShootParams copyWith({
    String? device,
    String? aspectRatio,
    String? lighting,
    bool clearDevice = false,
    bool clearAspectRatio = false,
    bool clearLighting = false,
  }) {
    return ShootParams(
      device: clearDevice ? null : (device ?? this.device),
      aspectRatio: clearAspectRatio ? null : (aspectRatio ?? this.aspectRatio),
      lighting: clearLighting ? null : (lighting ?? this.lighting),
    );
  }

  Map<String, dynamic> toJson() => {
        if (device != null && device!.isNotEmpty) 'device': device,
        if (aspectRatio != null && aspectRatio!.isNotEmpty)
          'aspect_ratio': aspectRatio,
        if (lighting != null && lighting!.isNotEmpty) 'lighting': lighting,
      };

  factory ShootParams.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ShootParams();
    return ShootParams(
      device: json['device'] as String?,
      aspectRatio: json['aspect_ratio'] as String? ?? json['aspectRatio'] as String?,
      lighting: json['lighting'] as String?,
    );
  }

  /// Merge [override] on top of [base]; null fields in override inherit from base.
  static ShootParams resolve(ShootParams base, ShootParams? override) {
    if (override == null || override.isEmpty) return base;
    return ShootParams(
      device: override.device ?? base.device,
      aspectRatio: override.aspectRatio ?? base.aspectRatio,
      lighting: override.lighting ?? base.lighting,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ShootParams &&
      other.device == device &&
      other.aspectRatio == aspectRatio &&
      other.lighting == lighting;

  @override
  int get hashCode => Object.hash(device, aspectRatio, lighting);
}

/// Partial override: each null field inherits from parent level.
typedef ShootParamsOverride = ShootParams;
