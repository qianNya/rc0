import 'script_act.dart';
import 'script_frame.dart';

/// 剧本 — 完整发布单元
class Screenplay {
  static const int kindPersonal = 1;
  static const int kindTemplate = 2;

  const Screenplay({
    required this.id,
    required this.title,
    this.synopsis = '',
    this.tags = const [],
    this.author = '我',
    this.authorBio = '摄影创作者',
    this.authorAvatar,
    this.ownerUserId,
    this.likes = 0,
    this.views = 0,
    this.favorites = 0,
    this.isLiked = false,
    this.isFavorited = false,
    this.acts = const [],
    this.isLocal = false,
    this.createdAt,
    this.updatedAt,
    this.coverUrl,
    this.localCoverPath,
    this.apiActCount,
    this.apiSceneCount,
    this.apiFrameCount,
    this.kind = kindPersonal,
    this.forkSourceId,
    this.forkRootId,
    this.forkCount = 0,
    this.forkedFromId,
    this.forkedFromLocalId,
    this.imagesLocalized = false,
    this.remoteScreenplayId,
    this.visibility,
    this.treeJsonObjectKey,
    this.publishedAt,
  });

  final String id;
  final String title;
  final String synopsis;
  final List<String> tags;
  final String author;
  final String authorBio;
  final String? authorAvatar;
  final int? ownerUserId;
  final int likes;
  final int views;
  final int favorites;
  final bool isLiked;
  final bool isFavorited;
  final List<ScriptAct> acts;
  final bool isLocal;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? coverUrl;
  final String? localCoverPath;
  final int? apiActCount;
  final int? apiSceneCount;
  final int? apiFrameCount;
  final int kind;
  final int? forkSourceId;
  final int? forkRootId;
  final int forkCount;
  final int? forkedFromId;
  final String? forkedFromLocalId;
  final bool imagesLocalized;
  final int? remoteScreenplayId;
  final int? visibility;
  final String? treeJsonObjectKey;
  final DateTime? publishedAt;

  bool get isTemplate => kind == kindTemplate;

  /// Prefer [forkSourceId]; [forkedFromId] is kept as a local alias.
  int? get effectiveForkSourceId => forkSourceId ?? forkedFromId;

  bool get isForkCopy =>
      effectiveForkSourceId != null || forkedFromLocalId != null;

  bool get isPublished => remoteScreenplayId != null;

  bool get isPrivate => visibility == 0;

  /// Route id for detail page: published scripts use remote id when available.
  String get detailRouteId {
    if (isPublished && remoteScreenplayId != null) {
      return remoteScreenplayId.toString();
    }
    return id;
  }

  bool get needsImageDownload =>
      isLocal &&
      !imagesLocalized &&
      allFrames.any((f) {
        final p = f.remoteImageUrl ?? f.imagePath;
        return p.startsWith('http://') || p.startsWith('https://');
      });

  int get actCount => acts.isNotEmpty ? acts.length : (apiActCount ?? 0);

  int get sceneCount => acts.isNotEmpty
      ? acts.fold(0, (sum, act) => sum + act.sceneCount)
      : (apiSceneCount ?? 0);

  int get frameCount => acts.isNotEmpty
      ? acts.fold(0, (sum, act) => sum + act.frameCount)
      : (apiFrameCount ?? 0);

  String? get coverImagePath {
    if (localCoverPath != null &&
        localCoverPath!.isNotEmpty &&
        !_isNetworkUrl(localCoverPath!)) {
      return localCoverPath;
    }
    for (final act in acts) {
      for (final scene in act.scenes) {
        for (final frame in scene.frames) {
          final local = frame.localImagePath;
          if (local != null &&
              local.isNotEmpty &&
              !_isNetworkUrl(local)) {
            return local;
          }
          final path = frame.imagePath;
          if (path.isNotEmpty && !_isNetworkUrl(path)) {
            return path;
          }
        }
      }
    }
    if (coverUrl != null &&
        coverUrl!.isNotEmpty &&
        _isNetworkUrl(coverUrl!)) {
      return coverUrl;
    }
    return null;
  }

  static bool _isNetworkUrl(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  String get hierarchySummary => '$actCount幕 · $sceneCount场 · $frameCount画';

  List<ScriptFrame> get allFrames {
    final frames = <ScriptFrame>[];
    for (final act in acts) {
      for (final scene in act.scenes) {
        frames.addAll(scene.frames);
      }
    }
    return frames;
  }

  List<String> get allTags {
    final set = <String>{...tags};
    for (final frame in allFrames) {
      set.addAll(frame.tags);
    }
    return set.toList();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'synopsis': synopsis,
        'tags': tags,
        'author': author,
        'authorBio': authorBio,
        'authorAvatar': authorAvatar,
        'ownerUserId': ownerUserId,
        'likes': likes,
        'views': views,
        'favorites': favorites,
        'isLiked': isLiked,
        'isFavorited': isFavorited,
        'acts': acts.map((a) => a.toJson()).toList(),
        'isLocal': isLocal,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'coverUrl': coverUrl,
        'localCoverPath': localCoverPath,
        'apiActCount': apiActCount,
        'apiSceneCount': apiSceneCount,
        'apiFrameCount': apiFrameCount,
        'kind': kind,
        'forkSourceId': forkSourceId,
        'forkRootId': forkRootId,
        'forkCount': forkCount,
        'forkedFromId': forkedFromId ?? forkSourceId,
        'forkedFromLocalId': forkedFromLocalId,
        'imagesLocalized': imagesLocalized,
        'remoteScreenplayId': remoteScreenplayId,
        'visibility': visibility,
        'treeJsonObjectKey': treeJsonObjectKey,
        'publishedAt': publishedAt?.toIso8601String(),
      };

  factory Screenplay.fromJson(Map<String, dynamic> json) {
    final forkSource = json['forkSourceId'] as int? ??
        (json['fork_source_id'] as num?)?.toInt() ??
        json['forkedFromId'] as int?;
    final forkedFrom = json['forkedFromId'] as int? ?? forkSource;
    return Screenplay(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      author: json['author'] as String? ?? '我',
      authorBio: json['authorBio'] as String? ?? '摄影创作者',
      authorAvatar: json['authorAvatar'] as String?,
      ownerUserId: json['ownerUserId'] as int?,
      likes: json['likes'] as int? ?? 0,
      views: json['views'] as int? ?? 0,
      favorites: json['favorites'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isFavorited: json['isFavorited'] as bool? ?? false,
      acts: (json['acts'] as List<dynamic>?)
              ?.map((e) => ScriptAct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      isLocal: json['isLocal'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      coverUrl: json['coverUrl'] as String?,
      localCoverPath: json['localCoverPath'] as String?,
      apiActCount: json['apiActCount'] as int?,
      apiSceneCount: json['apiSceneCount'] as int?,
      apiFrameCount: json['apiFrameCount'] as int?,
      kind: json['kind'] as int? ?? kindPersonal,
      forkSourceId: forkSource,
      forkRootId: json['forkRootId'] as int? ??
          (json['fork_root_id'] as num?)?.toInt(),
      forkCount: json['forkCount'] as int? ??
          (json['fork_count'] as num?)?.toInt() ??
          0,
      forkedFromId: forkedFrom,
      forkedFromLocalId: json['forkedFromLocalId'] as String?,
      imagesLocalized: json['imagesLocalized'] as bool? ?? false,
      remoteScreenplayId: json['remoteScreenplayId'] as int?,
      visibility: json['visibility'] as int?,
      treeJsonObjectKey: json['treeJsonObjectKey'] as String?,
      publishedAt: json['publishedAt'] != null
          ? DateTime.tryParse(json['publishedAt'] as String)
          : null,
    );
  }

  Screenplay copyWith({
    String? id,
    String? title,
    String? synopsis,
    List<String>? tags,
    String? author,
    String? authorBio,
    String? authorAvatar,
    int? ownerUserId,
    int? likes,
    int? views,
    int? favorites,
    bool? isLiked,
    bool? isFavorited,
    List<ScriptAct>? acts,
    bool? isLocal,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? coverUrl,
    String? localCoverPath,
    int? apiActCount,
    int? apiSceneCount,
    int? apiFrameCount,
    int? kind,
    int? forkSourceId,
    int? forkRootId,
    int? forkCount,
    int? forkedFromId,
    String? forkedFromLocalId,
    bool? imagesLocalized,
    int? remoteScreenplayId,
    int? visibility,
    String? treeJsonObjectKey,
    DateTime? publishedAt,
  }) {
    final nextForkSource = forkSourceId ?? forkedFromId ?? this.forkSourceId;
    final nextForkedFrom = forkedFromId ?? forkSourceId ?? this.forkedFromId;
    return Screenplay(
      id: id ?? this.id,
      title: title ?? this.title,
      synopsis: synopsis ?? this.synopsis,
      tags: tags ?? this.tags,
      author: author ?? this.author,
      authorBio: authorBio ?? this.authorBio,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      likes: likes ?? this.likes,
      views: views ?? this.views,
      favorites: favorites ?? this.favorites,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
      acts: acts ?? this.acts,
      isLocal: isLocal ?? this.isLocal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      coverUrl: coverUrl ?? this.coverUrl,
      localCoverPath: localCoverPath ?? this.localCoverPath,
      apiActCount: apiActCount ?? this.apiActCount,
      apiSceneCount: apiSceneCount ?? this.apiSceneCount,
      apiFrameCount: apiFrameCount ?? this.apiFrameCount,
      kind: kind ?? this.kind,
      forkSourceId: nextForkSource,
      forkRootId: forkRootId ?? this.forkRootId,
      forkCount: forkCount ?? this.forkCount,
      forkedFromId: nextForkedFrom,
      forkedFromLocalId: forkedFromLocalId ?? this.forkedFromLocalId,
      imagesLocalized: imagesLocalized ?? this.imagesLocalized,
      remoteScreenplayId: remoteScreenplayId ?? this.remoteScreenplayId,
      visibility: visibility ?? this.visibility,
      treeJsonObjectKey: treeJsonObjectKey ?? this.treeJsonObjectKey,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}
