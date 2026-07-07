import 'package:flutter/foundation.dart';

/// End-to-end unified image reference (PRD §3.8 / TECHNICAL_DESIGN §5.1).
///
/// Replaces the ~9 parallel schemes (id / file_id+role / url / local path /
/// ref / cache path / asset) with a single model.
@immutable
class ImageRef {
  const ImageRef({
    this.imageId,
    this.fileId,
    this.remoteUrl,
    this.localPath,
  });

  /// Server-side `acgn_image.id`.
  final String? imageId;

  /// Server-side `acgn_image_file.id` (variant role resolved at read time).
  final String? fileId;

  /// CDN / presigned URL; may be empty until server fills it in.
  final String? remoteUrl;

  /// Client-only local draft path; never sent as authoritative remote state.
  final String? localPath;

  bool get isEmpty =>
      (imageId == null || imageId!.isEmpty) &&
      (fileId == null || fileId!.isEmpty) &&
      (remoteUrl == null || remoteUrl!.isEmpty) &&
      (localPath == null || localPath!.isEmpty);

  bool get hasRemoteId =>
      imageId != null && imageId!.isNotEmpty ||
      fileId != null && fileId!.isNotEmpty;

  bool get hasLocalPath =>
      localPath != null && localPath!.isNotEmpty;

  ImageRef copyWith({
    String? imageId,
    String? fileId,
    String? remoteUrl,
    String? localPath,
    bool clearImageId = false,
    bool clearFileId = false,
    bool clearRemoteUrl = false,
    bool clearLocalPath = false,
  }) {
    return ImageRef(
      imageId: clearImageId ? null : (imageId ?? this.imageId),
      fileId: clearFileId ? null : (fileId ?? this.fileId),
      remoteUrl: clearRemoteUrl ? null : (remoteUrl ?? this.remoteUrl),
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
    );
  }

  Map<String, dynamic> toJson() => {
        if (imageId != null && imageId!.isNotEmpty) 'image_id': imageId,
        if (fileId != null && fileId!.isNotEmpty) 'file_id': fileId,
        if (remoteUrl != null && remoteUrl!.isNotEmpty) 'remote_url': remoteUrl,
        if (localPath != null && localPath!.isNotEmpty) 'local_path': localPath,
      };

  factory ImageRef.fromJson(Map<String, dynamic> json) {
    return ImageRef(
      imageId: _str(json['image_id'] ?? json['imageId']),
      fileId: _str(json['file_id'] ?? json['fileId']),
      remoteUrl: _str(json['remote_url'] ?? json['remoteUrl']),
      localPath: _str(json['local_path'] ?? json['localPath']),
    );
  }

  /// Reads a frame node from screenplay tree JSON (legacy field compatible).
  factory ImageRef.fromFrameMap(Map<String, dynamic> frame) {
    return ImageRef(
      imageId: _str(frame['acgn_image_id']),
      fileId: _str(frame['acgn_image_file_id']),
      remoteUrl: _str(frame['image_url'] ?? frame['thumbnail_url']),
      localPath: _str(frame['local_image_path'] ?? frame['local_thumbnail_path']),
    );
  }

  /// Reads cover from screenplay root map.
  factory ImageRef.fromCoverMap(Map<String, dynamic> screenplay) {
    return ImageRef(
      imageId: _str(screenplay['cover_image_id']),
      fileId: _str(screenplay['cover_image_file_id']),
      remoteUrl: _str(screenplay['cover_url']),
      localPath: _str(screenplay['local_cover_path']),
    );
  }

  /// Writes unified fields back into a frame tree node (dual-write compat).
  Map<String, dynamic> applyToFrameMap(Map<String, dynamic> frame) {
    final copy = Map<String, dynamic>.from(frame);
    _setOrRemove(copy, 'acgn_image_id', imageId);
    _setOrRemove(copy, 'acgn_image_file_id', fileId);
    _setOrRemove(copy, 'image_url', remoteUrl);
    _setOrRemove(copy, 'local_image_path', localPath);
    return copy;
  }

  Map<String, dynamic> applyToCoverMap(Map<String, dynamic> screenplay) {
    final copy = Map<String, dynamic>.from(screenplay);
    _setOrRemove(copy, 'cover_image_id', imageId);
    _setOrRemove(copy, 'cover_image_file_id', fileId);
    _setOrRemove(copy, 'cover_url', remoteUrl);
    _setOrRemove(copy, 'local_cover_path', localPath);
    return copy;
  }

  @override
  bool operator ==(Object other) =>
      other is ImageRef &&
      other.imageId == imageId &&
      other.fileId == fileId &&
      other.remoteUrl == remoteUrl &&
      other.localPath == localPath;

  @override
  int get hashCode => Object.hash(imageId, fileId, remoteUrl, localPath);

  @override
  String toString() =>
      'ImageRef(imageId: $imageId, fileId: $fileId, remoteUrl: $remoteUrl, localPath: $localPath)';

  static String? _str(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static void _setOrRemove(Map<String, dynamic> map, String key, String? value) {
    if (value == null || value.isEmpty) {
      map.remove(key);
    } else {
      map[key] = value;
    }
  }
}
