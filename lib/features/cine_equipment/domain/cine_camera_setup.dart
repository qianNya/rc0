/// Saved or inline camera rig: body + lens + focal length + aperture.
class CineCameraSetup {
  const CineCameraSetup({
    required this.id,
    required this.title,
    required this.bodyId,
    required this.lensId,
    required this.focalLengthMm,
    required this.apertureF,
    this.isBuiltIn = false,
    this.favorite = false,
    this.remoteId,
  });

  final String id;
  final String title;
  final String bodyId;
  final String lensId;
  final double focalLengthMm;
  final double apertureF;
  final bool isBuiltIn;
  final bool favorite;
  final int? remoteId;

  bool get isEmpty =>
      bodyId.isEmpty && lensId.isEmpty && focalLengthMm <= 0 && apertureF <= 0;

  CineCameraSetup copyWith({
    String? id,
    String? title,
    String? bodyId,
    String? lensId,
    double? focalLengthMm,
    double? apertureF,
    bool? isBuiltIn,
    bool? favorite,
    int? remoteId,
  }) {
    return CineCameraSetup(
      id: id ?? this.id,
      title: title ?? this.title,
      bodyId: bodyId ?? this.bodyId,
      lensId: lensId ?? this.lensId,
      focalLengthMm: focalLengthMm ?? this.focalLengthMm,
      apertureF: apertureF ?? this.apertureF,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      favorite: favorite ?? this.favorite,
      remoteId: remoteId ?? this.remoteId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body_id': bodyId,
        'lens_id': lensId,
        'focal_length_mm': focalLengthMm,
        'aperture_f': apertureF,
        'is_built_in': isBuiltIn,
        if (remoteId != null) 'remote_id': remoteId,
      };

  factory CineCameraSetup.fromJson(Map<String, dynamic> json) {
    final remoteRaw = json['remote_id'] ?? json['remoteId'];
    int? remoteId;
    if (remoteRaw is num) {
      remoteId = remoteRaw.toInt();
    }

    final idValue = json['id'];
    if (idValue is num) {
      remoteId ??= idValue.toInt();
    }

    final slug = json['slug'] as String?;
    final String id;
    if (slug != null && slug.isNotEmpty) {
      id = slug;
    } else if (idValue is String && idValue.isNotEmpty) {
      id = idValue;
    } else if (remoteId != null) {
      id = 'setup-$remoteId';
    } else {
      id = '';
    }

    return CineCameraSetup(
      id: id,
      title: json['title'] as String? ?? '',
      bodyId: json['body_id'] as String? ??
          json['bodyId'] as String? ??
          json['body_slug'] as String? ??
          '',
      lensId: json['lens_id'] as String? ??
          json['lensId'] as String? ??
          json['lens_slug'] as String? ??
          '',
      focalLengthMm: _toDouble(json['focal_length_mm'] ?? json['focalLengthMm']),
      apertureF: _toDouble(json['aperture_f'] ?? json['apertureF']),
      isBuiltIn: json['is_built_in'] == true || (json['scope'] as num?) == 0,
      remoteId: remoteId,
    );
  }

  static double _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
