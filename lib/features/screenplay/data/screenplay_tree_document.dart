import 'dart:convert';

import '../../../core/domain/screenplay/screenplay.dart';
import 'screenplay_api_mapper.dart';

/// App metadata stored alongside API-compatible tree JSON.
class ScreenplayLocalMeta {
  const ScreenplayLocalMeta({
    required this.localId,
    this.isLocal = true,
    this.tags = const [],
    this.author = '我',
    this.authorBio = '摄影创作者',
    this.forkedFromId,
    this.forkedFromLocalId,
    this.imagesLocalized = false,
    this.createdAt,
    this.remoteScreenplayId,
    this.visibility,
    this.treeJsonObjectKey,
    this.publishedAt,
  });

  final String localId;
  final bool isLocal;
  final List<String> tags;
  final String author;
  final String authorBio;
  final int? forkedFromId;
  final String? forkedFromLocalId;
  final bool imagesLocalized;
  final DateTime? createdAt;
  final int? remoteScreenplayId;
  final int? visibility;
  final String? treeJsonObjectKey;
  final DateTime? publishedAt;

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'is_local': isLocal,
        'tags': tags,
        'author': author,
        'author_bio': authorBio,
        'forked_from_id': forkedFromId,
        'forked_from_local_id': forkedFromLocalId,
        'images_localized': imagesLocalized,
        'created_at': createdAt?.toIso8601String(),
        'remote_screenplay_id': remoteScreenplayId,
        'visibility': visibility,
        'tree_json_object_key': treeJsonObjectKey,
        'published_at': publishedAt?.toIso8601String(),
      };

  factory ScreenplayLocalMeta.fromJson(Map<String, dynamic> json) {
    return ScreenplayLocalMeta(
      localId: json['local_id'] as String,
      isLocal: json['is_local'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      author: json['author'] as String? ?? '我',
      authorBio: json['author_bio'] as String? ?? '摄影创作者',
      forkedFromId: (json['forked_from_id'] as num?)?.toInt(),
      forkedFromLocalId: json['forked_from_local_id'] as String?,
      imagesLocalized: json['images_localized'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      remoteScreenplayId: (json['remote_screenplay_id'] as num?)?.toInt(),
      visibility: (json['visibility'] as num?)?.toInt(),
      treeJsonObjectKey: json['tree_json_object_key'] as String?,
      publishedAt: json['published_at'] != null
          ? DateTime.tryParse(json['published_at'] as String)
          : null,
    );
  }

  ScreenplayLocalMeta copyWith({
    String? localId,
    bool? isLocal,
    List<String>? tags,
    String? author,
    String? authorBio,
    int? forkedFromId,
    String? forkedFromLocalId,
    bool? imagesLocalized,
    DateTime? createdAt,
    int? remoteScreenplayId,
    int? visibility,
    String? treeJsonObjectKey,
    DateTime? publishedAt,
  }) {
    return ScreenplayLocalMeta(
      localId: localId ?? this.localId,
      isLocal: isLocal ?? this.isLocal,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      authorBio: authorBio ?? this.authorBio,
      forkedFromId: forkedFromId ?? this.forkedFromId,
      forkedFromLocalId: forkedFromLocalId ?? this.forkedFromLocalId,
      imagesLocalized: imagesLocalized ?? this.imagesLocalized,
      createdAt: createdAt ?? this.createdAt,
      remoteScreenplayId: remoteScreenplayId ?? this.remoteScreenplayId,
      visibility: visibility ?? this.visibility,
      treeJsonObjectKey: treeJsonObjectKey ?? this.treeJsonObjectKey,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

/// Persisted document: API tree shape + app meta.
class ScreenplayTreeDocument {
  const ScreenplayTreeDocument({
    required this.tree,
    required this.meta,
  });

  final Map<String, dynamic> tree;
  final ScreenplayLocalMeta meta;

  Map<String, dynamic> toJson() => {
        'tree': tree,
        'meta': meta.toJson(),
      };

  factory ScreenplayTreeDocument.fromJson(Map<String, dynamic> json) {
    return ScreenplayTreeDocument(
      tree: Map<String, dynamic>.from(json['tree'] as Map),
      meta: ScreenplayLocalMeta.fromJson(
        Map<String, dynamic>.from(json['meta'] as Map),
      ),
    );
  }

  factory ScreenplayTreeDocument.fromScreenplay(
    Screenplay screenplay, {
    ScreenplayLocalMeta? existingMeta,
  }) {
    final numericId = existingMeta?.remoteScreenplayId ??
        _numericIdFor(screenplay.id);
    final baseMeta = existingMeta;
    return ScreenplayTreeDocument(
      tree: ScreenplayApiMapper.toTreeJson(
        screenplay,
        screenplayNumericId: numericId,
      ),
      meta: ScreenplayLocalMeta(
        localId: screenplay.id,
        isLocal: screenplay.isLocal,
        tags: screenplay.tags,
        author: screenplay.author,
        authorBio: screenplay.authorBio,
        forkedFromId: screenplay.forkedFromId ?? baseMeta?.forkedFromId,
        forkedFromLocalId:
            screenplay.forkedFromLocalId ?? baseMeta?.forkedFromLocalId,
        imagesLocalized: screenplay.imagesLocalized,
        createdAt: screenplay.createdAt ?? baseMeta?.createdAt,
        remoteScreenplayId:
            screenplay.remoteScreenplayId ?? baseMeta?.remoteScreenplayId,
        visibility: screenplay.visibility ?? baseMeta?.visibility,
        treeJsonObjectKey:
            screenplay.treeJsonObjectKey ?? baseMeta?.treeJsonObjectKey,
        publishedAt: screenplay.publishedAt ?? baseMeta?.publishedAt,
      ),
    );
  }

  Screenplay toScreenplay() => ScreenplayApiMapper.screenplayFromDocument(this);

  static int _numericIdFor(String id) {
    final parsed = int.tryParse(id.replaceFirst(RegExp(r'^script-'), ''));
    if (parsed != null) return parsed;
    return DateTime.now().millisecondsSinceEpoch % 1000000000;
  }
}

bool isTreeShapedDocument(Map<String, dynamic> json) =>
    json.containsKey('tree') && json.containsKey('meta');

bool isLegacyFlatScreenplay(Map<String, dynamic> json) =>
    json.containsKey('id') && json.containsKey('acts') && !json.containsKey('tree');

Map<String, dynamic> deepCopyJson(Map<String, dynamic> source) {
  return jsonDecode(jsonEncode(source)) as Map<String, dynamic>;
}
