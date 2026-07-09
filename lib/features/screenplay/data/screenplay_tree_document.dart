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
    this.kind = Screenplay.kindPersonal,
    this.forkSourceId,
    this.forkRootId,
    this.forkCount = 0,
    this.forkedFromId,
    this.forkedFromLocalId,
    this.imagesLocalized = false,
    this.browseCache = false,
    this.createdAt,
    this.updatedAt,
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
  final int kind;
  final int? forkSourceId;
  final int? forkRootId;
  final int forkCount;
  final int? forkedFromId;
  final String? forkedFromLocalId;
  final bool imagesLocalized;
  final bool browseCache;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? remoteScreenplayId;
  final int? visibility;
  final String? treeJsonObjectKey;
  final DateTime? publishedAt;

  int? get effectiveForkSourceId => forkSourceId ?? forkedFromId;

  Map<String, dynamic> toJson() => {
        'local_id': localId,
        'is_local': isLocal,
        'tags': tags,
        'author': author,
        'author_bio': authorBio,
        'kind': kind,
        'fork_source_id': forkSourceId ?? forkedFromId,
        'fork_root_id': forkRootId,
        'fork_count': forkCount,
        'forked_from_id': forkedFromId ?? forkSourceId,
        'forked_from_local_id': forkedFromLocalId,
        'images_localized': imagesLocalized,
        'browse_cache': browseCache,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'remote_screenplay_id': remoteScreenplayId,
        'visibility': visibility,
        'tree_json_object_key': treeJsonObjectKey,
        'published_at': publishedAt?.toIso8601String(),
      };

  factory ScreenplayLocalMeta.fromJson(Map<String, dynamic> json) {
    final forkSource = (json['fork_source_id'] as num?)?.toInt() ??
        (json['forked_from_id'] as num?)?.toInt();
    final forkedFrom = (json['forked_from_id'] as num?)?.toInt() ?? forkSource;
    return ScreenplayLocalMeta(
      localId: json['local_id'] as String,
      isLocal: json['is_local'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      author: json['author'] as String? ?? '我',
      authorBio: json['author_bio'] as String? ?? '摄影创作者',
      kind: (json['kind'] as num?)?.toInt() ?? Screenplay.kindPersonal,
      forkSourceId: forkSource,
      forkRootId: (json['fork_root_id'] as num?)?.toInt(),
      forkCount: (json['fork_count'] as num?)?.toInt() ?? 0,
      forkedFromId: forkedFrom,
      forkedFromLocalId: json['forked_from_local_id'] as String?,
      imagesLocalized: json['images_localized'] as bool? ?? false,
      browseCache: json['browse_cache'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
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
    int? kind,
    int? forkSourceId,
    int? forkRootId,
    int? forkCount,
    int? forkedFromId,
    String? forkedFromLocalId,
    bool? imagesLocalized,
    bool? browseCache,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? remoteScreenplayId,
    int? visibility,
    String? treeJsonObjectKey,
    DateTime? publishedAt,
  }) {
    final nextForkSource = forkSourceId ?? forkedFromId ?? this.forkSourceId;
    final nextForkedFrom = forkedFromId ?? forkSourceId ?? this.forkedFromId;
    return ScreenplayLocalMeta(
      localId: localId ?? this.localId,
      isLocal: isLocal ?? this.isLocal,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      authorBio: authorBio ?? this.authorBio,
      kind: kind ?? this.kind,
      forkSourceId: nextForkSource,
      forkRootId: forkRootId ?? this.forkRootId,
      forkCount: forkCount ?? this.forkCount,
      forkedFromId: nextForkedFrom,
      forkedFromLocalId: forkedFromLocalId ?? this.forkedFromLocalId,
      imagesLocalized: imagesLocalized ?? this.imagesLocalized,
      browseCache: browseCache ?? this.browseCache,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    final forkSource =
        screenplay.effectiveForkSourceId ?? baseMeta?.effectiveForkSourceId;
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
        kind: screenplay.kind,
        forkSourceId: forkSource,
        forkRootId: screenplay.forkRootId ?? baseMeta?.forkRootId,
        forkCount: screenplay.forkCount,
        forkedFromId: forkSource,
        forkedFromLocalId:
            screenplay.forkedFromLocalId ?? baseMeta?.forkedFromLocalId,
        imagesLocalized: screenplay.imagesLocalized,
        createdAt: screenplay.createdAt ?? baseMeta?.createdAt,
        updatedAt: screenplay.updatedAt ?? baseMeta?.updatedAt,
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
