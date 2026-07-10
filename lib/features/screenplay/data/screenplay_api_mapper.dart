import 'dart:io';

import '../../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../core/domain/screenplay/screenplay_image_resolver.dart';
import 'screenplay_draft.dart';
import 'cine_params_draft.dart';
import 'shoot_params_draft.dart';
import 'screenplay_tree_document.dart';
import 'data_upload_repository.dart';

abstract final class ScreenplayApiMapper {
  static Screenplay fromFeedItem(api.FeedItemDto item) {
    final sp = item.screenplay;
    final author = item.author;
    return fromListItem(
      sp,
      authorName: _authorLabel(
        author: author,
        creatorId: sp.creator.toInt(),
      ),
      authorAvatar: author?.avatar.isNotEmpty == true ? author!.avatar : null,
    );
  }

  static Screenplay fromListItem(
    api.Screenplay item, {
    String? authorName,
    String? authorAvatar,
  }) {
    return _applySocial(
      Screenplay(
        id: item.id.toString(),
        title: item.title,
        synopsis: item.summary,
        coverUrl: item.coverUrl.isNotEmpty ? item.coverUrl : null,
        apiActCount: item.actCount.toInt(),
        apiSceneCount: item.sceneCount.toInt(),
        apiFrameCount: item.frameCount.toInt(),
        isLocal: false,
        remoteScreenplayId: item.id.toInt(),
      ),
      item,
      authorName: authorName,
      authorAvatar: authorAvatar,
    );
  }

  static String _authorLabel({
    api.AuthorSummary? author,
    required int creatorId,
  }) {
    if (author != null && author.nickname.isNotEmpty) {
      return author.nickname;
    }
    if (creatorId > 0) return '用户 $creatorId';
    return '创作者';
  }

  static Screenplay fromTree(api.GetScreenplayTreeResp tree) {
    return _screenplayFromTree(tree);
  }

  static Screenplay screenplayFromTreeJson(Map<String, dynamic> treeJson) {
    return _screenplayFromTree(api.GetScreenplayTreeResp.fromJson(treeJson));
  }

  static Screenplay _screenplayFromTree(api.GetScreenplayTreeResp tree) {
    final sp = tree.screenplay;
    return _applySocial(
      Screenplay(
        id: sp.id.toString(),
        title: sp.title,
        synopsis: sp.summary,
        coverUrl: sp.coverUrl.isNotEmpty ? sp.coverUrl : null,
        acts: tree.acts.map(_mapActNode).toList(),
        isLocal: false,
        remoteScreenplayId: sp.id.toInt(),
        apiActCount: sp.actCount.toInt(),
        apiSceneCount: sp.sceneCount.toInt(),
        apiFrameCount: sp.frameCount.toInt(),
      ),
      sp,
    );
  }

  static Screenplay _applySocial(
    Screenplay base,
    api.Screenplay sp, {
    String? authorName,
    String? authorAvatar,
  }) {
    final creatorId = sp.creator.toInt();
    final kind = sp.kind.toInt();
    final forkSource = sp.forkSourceId?.toInt();
    final forkRoot = sp.forkRootId?.toInt();
    final publishedAt = sp.publishedAt.isNotEmpty
        ? DateTime.tryParse(sp.publishedAt)
        : null;
    final createdAt =
        sp.createAt.isNotEmpty ? DateTime.tryParse(sp.createAt) : null;
    final featuredAt = sp.featuredAt.isNotEmpty
        ? DateTime.tryParse(sp.featuredAt)
        : null;
    return base.copyWith(
      author: authorName ??
          (creatorId > 0 ? '用户 $creatorId' : '创作者'),
      authorAvatar: authorAvatar,
      ownerUserId: creatorId > 0 ? creatorId : null,
      likes: sp.likeCount.toInt(),
      views: sp.viewCount.toInt(),
      favorites: sp.favoriteCount.toInt(),
      isLiked: sp.isLiked,
      isFavorited: sp.isFavorited,
      visibility: sp.visibility.toInt(),
      kind: kind > 0 ? kind : Screenplay.kindPersonal,
      forkCount: sp.forkCount.toInt(),
      forkSourceId: forkSource,
      forkRootId: forkRoot,
      forkedFromId: forkSource,
      publishedAt: publishedAt,
      createdAt: createdAt,
      durationSec: sp.durationSec.toInt(),
      isFeatured: sp.isFeatured,
      featuredAt: featuredAt,
      hotScore: sp.hotScore.toDouble(),
    );
  }

  /// API-compatible tree JSON with real Lists (safe for cache / fork).
  static Map<String, dynamic> treeToJsonMap(api.GetScreenplayTreeResp tree) {
    return {
      'screenplay': tree.screenplay.toJson(),
      'acts': tree.acts.map((actNode) {
        return {
          'act': actNode.act.toJson(),
          'scenes': actNode.scenes.map((sceneNode) {
            return {
              'scene': sceneNode.scene.toJson(),
              'frames': sceneNode.frames.map((f) => f.toJson()).toList(),
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  static Screenplay _screenplayFromRawTree(Map<String, dynamic> tree) {
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
    final coverRemote = ScreenplayImageResolver.coverRemoteUrl(screenplayMap);
    final coverLocal = screenplayMap['local_cover_path'] as String?;

    final acts = <ScriptAct>[];
    final actNodes = tree['acts'] as List<dynamic>? ?? [];
    for (final actNode in actNodes) {
      final actMap = (actNode as Map<String, dynamic>)['act'] as Map<String, dynamic>;
      final scenes = <ScriptScene>[];
      final sceneNodes = actNode['scenes'] as List<dynamic>? ?? [];
      for (final sceneNode in sceneNodes) {
        final sceneMap =
            (sceneNode as Map<String, dynamic>)['scene'] as Map<String, dynamic>;
        final frames = <ScriptFrame>[];
        final frameNodes = sceneNode['frames'] as List<dynamic>? ?? [];
        for (final frameNode in frameNodes) {
          frames.add(_mapFrameFromMap(frameNode as Map<String, dynamic>));
        }
        scenes.add(
          ScriptScene(
            id: sceneMap['id'].toString(),
            orderIndex: (sceneMap['sort'] as num?)?.toInt() ?? 0,
            title: sceneMap['title'] as String? ?? '',
            location: sceneMap['location'] as String? ?? '',
            timeOfDay: sceneMap['time_of_day'] as String? ?? '',
            description: sceneMap['summary'] as String? ?? '',
            frames: frames,
          ),
        );
      }
      acts.add(
        ScriptAct(
          id: actMap['id'].toString(),
          orderIndex: (actMap['sort'] as num?)?.toInt() ?? 0,
          title: actMap['title'] as String? ?? '',
          synopsis: actMap['summary'] as String? ?? '',
          scenes: scenes,
        ),
      );
    }

    final kind = (screenplayMap['kind'] as num?)?.toInt() ?? Screenplay.kindPersonal;
    final forkSource = (screenplayMap['fork_source_id'] as num?)?.toInt();
    return Screenplay(
      id: screenplayMap['id'].toString(),
      title: screenplayMap['title'] as String? ?? '',
      synopsis: screenplayMap['summary'] as String? ?? '',
      coverUrl: coverRemote,
      localCoverPath: coverLocal ?? ScreenplayImageResolver.legacyCoverPath(screenplayMap),
      acts: acts,
      isLocal: false,
      apiActCount: (screenplayMap['act_count'] as num?)?.toInt(),
      apiSceneCount: (screenplayMap['scene_count'] as num?)?.toInt(),
      apiFrameCount: (screenplayMap['frame_count'] as num?)?.toInt(),
      kind: kind > 0 ? kind : Screenplay.kindPersonal,
      forkSourceId: forkSource,
      forkRootId: (screenplayMap['fork_root_id'] as num?)?.toInt(),
      forkCount: (screenplayMap['fork_count'] as num?)?.toInt() ?? 0,
      forkedFromId: forkSource,
      visibility: (screenplayMap['visibility'] as num?)?.toInt(),
    );
  }

  static Screenplay screenplayFromDocument(ScreenplayTreeDocument doc) {
    final base = _screenplayFromRawTree(doc.tree);
    final forkSource = doc.meta.effectiveForkSourceId;
    return base.copyWith(
      id: doc.meta.localId,
      tags: doc.meta.tags,
      author: doc.meta.author,
      authorBio: doc.meta.authorBio,
      isLocal: doc.meta.isLocal,
      kind: doc.meta.kind,
      forkSourceId: forkSource,
      forkRootId: doc.meta.forkRootId,
      forkCount: doc.meta.forkCount,
      forkedFromId: forkSource,
      forkedFromLocalId: doc.meta.forkedFromLocalId,
      imagesLocalized: doc.meta.imagesLocalized,
      createdAt: doc.meta.createdAt,
      updatedAt: doc.meta.updatedAt,
      remoteScreenplayId: doc.meta.remoteScreenplayId,
      visibility: doc.meta.visibility,
      treeJsonObjectKey: doc.meta.treeJsonObjectKey,
      publishedAt: doc.meta.publishedAt,
    );
  }

  static Map<String, dynamic> toTreeJson(
    Screenplay sp, {
    required int screenplayNumericId,
  }) {
    var frameTotal = 0;
    var sceneTotal = 0;
    final actNodes = <Map<String, dynamic>>[];

    for (final act in sp.acts) {
      final actNumericId = _parseNumericId(act.id, act.orderIndex);
      final sceneNodes = <Map<String, dynamic>>[];

      for (final scene in act.scenes) {
        sceneTotal++;
        final sceneNumericId = _parseNumericId(scene.id, scene.orderIndex);
        final frames = <Map<String, dynamic>>[];

        for (final frame in scene.frames) {
          frameTotal++;
          frames.add(_frameToJson(
            frame: frame,
            screenplayId: screenplayNumericId,
            actId: actNumericId,
            sceneId: sceneNumericId,
          ));
        }

        sceneNodes.add({
          'scene': {
            'id': sceneNumericId,
            'screenplay_id': screenplayNumericId,
            'act_id': actNumericId,
            'title': scene.title,
            'summary': scene.description,
            'location': scene.location,
            'time_of_day': scene.timeOfDay,
            'sort': scene.orderIndex,
            'frame_count': frames.length,
            'status': 0,
            'create_at': '',
            'update_at': '',
          },
          'frames': frames,
        });
      }

      actNodes.add({
        'act': {
          'id': actNumericId,
          'screenplay_id': screenplayNumericId,
          'title': act.title,
          'summary': act.synopsis,
          'sort': act.orderIndex,
          'scene_count': sceneNodes.length,
          'frame_count': sceneNodes.fold<int>(
            0,
            (sum, s) =>
                sum + ((s['frames'] as List<dynamic>?)?.length ?? 0),
          ),
          'status': 0,
          'create_at': '',
          'update_at': '',
        },
        'scenes': sceneNodes,
      });
    }

    final coverRemote = sp.coverUrl;
    final coverLocal = sp.localCoverPath;
    final coverRemoteUrl = coverRemote != null && isNetworkUrl(coverRemote)
        ? coverRemote
        : null;
    final coverLocalPath = _resolveCoverLocalPath(
      coverLocal: coverLocal,
      coverRemote: coverRemote,
      fallbackPath: sp.coverImagePath,
    );

    final screenplayMap = <String, dynamic>{
      'id': screenplayNumericId,
      'kind': sp.kind,
      'title': sp.title,
      'subtitle': '',
      'summary': sp.synopsis,
      'cover_url': coverRemoteUrl ?? '',
      'cover_object_id': 0,
      'publish_status': 0,
      'visibility': sp.visibility ?? 0,
      'published_at': '',
      'act_count': sp.acts.isNotEmpty ? sp.acts.length : (sp.apiActCount ?? 0),
      'scene_count': sp.acts.isNotEmpty ? sceneTotal : (sp.apiSceneCount ?? 0),
      'frame_count': sp.acts.isNotEmpty ? frameTotal : (sp.apiFrameCount ?? 0),
      'status': 0,
      'create_at': '',
      'update_at': '',
      if (sp.effectiveForkSourceId != null)
        'fork_source_id': sp.effectiveForkSourceId,
      if (sp.forkRootId != null) 'fork_root_id': sp.forkRootId,
      'fork_count': sp.forkCount,
    };
    if (coverLocalPath != null && coverLocalPath.isNotEmpty) {
      screenplayMap['local_cover_path'] = coverLocalPath;
    }

    return {
      'screenplay': screenplayMap,
      'acts': actNodes,
    };
  }

  static Map<String, dynamic> _frameToJson({
    required ScriptFrame frame,
    required int screenplayId,
    required int actId,
    required int sceneId,
  }) {
    final frameId = _parseNumericId(frame.id, frame.orderIndex);
    final localImagePath = _resolveFrameLocalPath(frame);
    final remoteUrl = _resolveFrameRemoteUrl(frame);

    final json = <String, dynamic>{
      'id': frameId,
      'screenplay_id': screenplayId,
      'act_id': actId,
      'scene_id': sceneId,
      'title': '',
      'dialogue': frame.caption,
      'action_note': frame.actionNote,
      'duration_sec': 0,
      'sort': frame.orderIndex,
      'thumbnail_url': remoteUrl ?? '',
      'image_url': remoteUrl ?? '',
      'data_object_id': 0,
      'status': 0,
      'create_at': '',
      'update_at': '',
    };
    if (localImagePath != null) {
      json['local_image_path'] = localImagePath;
      if (frame.localThumbnailPath != null &&
          frame.localThumbnailPath!.isNotEmpty) {
        json['local_thumbnail_path'] = frame.localThumbnailPath;
      } else if (!ScreenplayImageResolver.isNetworkUrl(localImagePath)) {
        json['local_thumbnail_path'] = localImagePath;
      }
    }
    return json;
  }

  static String? _resolveCoverLocalPath({
    String? coverLocal,
    String? coverRemote,
    String? fallbackPath,
  }) {
    if (coverLocal != null &&
        coverLocal.isNotEmpty &&
        !isNetworkUrl(coverLocal)) {
      return coverLocal;
    }
    if (coverRemote != null &&
        coverRemote.isNotEmpty &&
        !isNetworkUrl(coverRemote)) {
      return coverRemote;
    }
    if (fallbackPath != null &&
        fallbackPath.isNotEmpty &&
        !isNetworkUrl(fallbackPath)) {
      return fallbackPath;
    }
    return null;
  }

  static String? _resolveFrameLocalPath(ScriptFrame frame) {
    final local = frame.localImagePath;
    if (local != null && local.isNotEmpty && !isNetworkUrl(local)) {
      return local;
    }
    if (frame.imagePath.isNotEmpty && !isNetworkUrl(frame.imagePath)) {
      return frame.imagePath;
    }
    return null;
  }

  static String? _resolveFrameRemoteUrl(ScriptFrame frame) {
    final remote = frame.remoteImageUrl;
    if (remote != null && remote.isNotEmpty && isNetworkUrl(remote)) {
      return remote;
    }
    if (frame.imagePath.isNotEmpty && isNetworkUrl(frame.imagePath)) {
      return frame.imagePath;
    }
    return null;
  }

  static int _parseNumericId(String id, int fallback) {
    final direct = int.tryParse(id);
    if (direct != null) return direct;
    final match = RegExp(r'(\d+)').allMatches(id).lastOrNull;
    if (match != null) return int.parse(match.group(1)!);
    return fallback;
  }

  static ScriptAct _mapActNode(api.ActNode node) {
    final act = node.act;
    return ScriptAct(
      id: act.id.toString(),
      orderIndex: act.sort.toInt(),
      title: act.title,
      synopsis: act.summary,
      scenes: node.scenes.map(_mapSceneNode).toList(),
    );
  }

  static ScriptScene _mapSceneNode(api.SceneNode node) {
    final scene = node.scene;
    return ScriptScene(
      id: scene.id.toString(),
      orderIndex: scene.sort.toInt(),
      title: scene.title,
      location: scene.location,
      timeOfDay: scene.timeOfDay,
      description: scene.summary,
      frames: node.frames.map(_mapFrame).toList(),
    );
  }

  static ScriptFrame _mapFrame(api.Frame frame) {
    return _mapFrameFromMap(frame.toJson());
  }

  static ScriptFrame _mapFrameFromMap(Map<String, dynamic> frame) {
    final remoteUrl = ScreenplayImageResolver.frameRemoteUrl(frame);
    final localPath = ScreenplayImageResolver.frameLocalPath(frame);
    final display = ScreenplayImageResolver.frameEffectivePath(frame) ?? '';
    return ScriptFrame(
      id: frame['id'].toString(),
      orderIndex: (frame['sort'] as num?)?.toInt() ?? 0,
      imagePath: display,
      localImagePath: localPath,
      remoteImageUrl: remoteUrl,
      caption: frame['dialogue'] as String? ?? '',
      actionNote: frame['action_note'] as String? ?? '',
    );
  }

  static bool isNetworkUrl(String path) =>
      ScreenplayImageResolver.isNetworkUrl(path);

  static const coverRef = 'cover-ref';

  static String frameRef(int actIdx, int sceneIdx, int frameIdx) =>
      'frame-$actIdx-$sceneIdx-$frameIdx';

  static String referenceImageRef(int actIdx, int sceneIdx, int frameIdx, int refIdx) =>
      'frame-$actIdx-$sceneIdx-$frameIdx-ref-$refIdx';

  /// Local cover file pending upload via POST /screenplays/{id}/cover.
  static File? collectLocalCoverFile(Map<String, dynamic> tree) {
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>?;
    if (screenplayMap == null ||
        ScreenplayImageResolver.coverRemoteUrl(screenplayMap) != null) {
      return null;
    }
    final coverSrc = ScreenplayImageResolver.localUploadPath(
      screenplayMap['local_cover_path'] as String?,
    );
    return coverSrc == null ? null : File(coverSrc);
  }

  /// Collects local frame files that need upload with stable refs.
  static Map<String, File> collectLocalFrameAssets(Map<String, dynamic> tree) {
    final refToFile = <String, File>{};
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final scenes =
          (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
              [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final frames = (scenes[sceneIdx] as Map<String, dynamic>)['frames']
                as List<dynamic>? ??
            [];
        for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
          final frameMap = frames[frameIdx] as Map<String, dynamic>;
          if (ScreenplayImageResolver.frameRemoteUrl(frameMap) != null) {
            continue;
          }
          final uploadSrc = ScreenplayImageResolver.localUploadPath(
            ScreenplayImageResolver.frameLocalPath(frameMap),
          );
          if (uploadSrc == null) continue;
          refToFile[frameRef(actIdx, sceneIdx, frameIdx)] = File(uploadSrc);
        }
      }
    }

    return refToFile;
  }

  /// Collects local reference images pending upload (per-frame `reference_local_paths`).
  static Map<String, File> collectLocalReferenceAssets(
    Map<String, dynamic> tree,
  ) {
    final refToFile = <String, File>{};
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final scenes =
          (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
              [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final frames = (scenes[sceneIdx] as Map<String, dynamic>)['frames']
                as List<dynamic>? ??
            [];
        for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
          final frameMap = frames[frameIdx] as Map<String, dynamic>;
          final paths = frameMap['reference_local_paths'];
          if (paths is! List) continue;
          for (var refIdx = 0; refIdx < paths.length; refIdx++) {
            final uploadSrc = ScreenplayImageResolver.localUploadPath(
              paths[refIdx] as String?,
            );
            if (uploadSrc == null) continue;
            refToFile[referenceImageRef(actIdx, sceneIdx, frameIdx, refIdx)] =
                File(uploadSrc);
          }
        }
      }
    }
    return refToFile;
  }

  /// Collects local cover + frame files (legacy helper).
  static Map<String, File> collectLocalAssets(Map<String, dynamic> tree) {
    final refToFile = collectLocalFrameAssets(tree);
    refToFile.addAll(collectLocalReferenceAssets(tree));
    final cover = collectLocalCoverFile(tree);
    if (cover != null) {
      refToFile[coverRef] = cover;
    }
    return refToFile;
  }

  static Map<String, dynamic> _frameAssetEntry(UploadedImage uploaded) => {
        'kind': 'frame_image',
        'remote_url': uploaded.displayUrl,
        'remote_image_id': uploaded.imageId,
        'remote_image_file_id': uploaded.displayFileId,
      };

  static Map<String, dynamic> _thumbAssetEntry(UploadedImage uploaded) => {
        'kind': 'frame_thumbnail',
        'remote_url': uploaded.thumbUrl,
        'remote_image_id': uploaded.imageId,
        'remote_image_file_id': uploaded.thumbFileId,
      };

  static Map<String, dynamic> _referenceAssetEntry(UploadedImage uploaded) => {
        'kind': 'frame_reference',
        'remote_url': uploaded.displayUrl,
        'remote_image_id': uploaded.imageId,
        'remote_image_file_id': uploaded.displayFileId,
      };

  static String thumbRef(String frameRef) => '${frameRef}_thumb';

  static int? _existingFrameImageId(Map<String, dynamic> frameMap) {
    final imageId = (frameMap['acgn_image_id'] as num?)?.toInt() ?? 0;
    return imageId > 0 ? imageId : null;
  }

  /// Writes freshly uploaded image metadata into the local tree before tree sync.
  static void stampUploadedImages(
    Map<String, dynamic> tree,
    Map<String, UploadedImage> refToUploaded,
  ) {
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final scenes =
          (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
              [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final frames = (scenes[sceneIdx] as Map<String, dynamic>)['frames']
                as List<dynamic>? ??
            [];
        for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
          final ref = frameRef(actIdx, sceneIdx, frameIdx);
          final uploaded = refToUploaded[ref];
          if (uploaded == null) continue;
          final frameMap = frames[frameIdx] as Map<String, dynamic>;
          frameMap['acgn_image_id'] = uploaded.imageId;
          if (uploaded.displayUrl.isNotEmpty) {
            frameMap['image_url'] = uploaded.displayUrl;
          }
          if (uploaded.thumbUrl.isNotEmpty) {
            frameMap['thumbnail_url'] = uploaded.thumbUrl;
          }
          if (uploaded.displayFileId != null) {
            frameMap['acgn_image_file_id'] = uploaded.displayFileId;
          }
        }
      }
    }
  }

  @Deprecated('Use stampUploadedImages')
  static void stampUploadedImageIds(
    Map<String, dynamic> tree,
    Map<String, int> refToImageId,
  ) {
    stampUploadedImages(
      tree,
      refToImageId.map(
        (ref, id) => MapEntry(
          ref,
          UploadedImage(
            imageId: id,
            displayUrl: '',
            thumbUrl: '',
          ),
        ),
      ),
    );
  }

  /// Builds POST/PUT `/screenplays/{id}/tree` body (`SaveScreenplayTreeReq`).
  static Map<String, dynamic> buildSaveTreePayload({
    required Map<String, dynamic> tree,
    required int visibility,
    required Map<String, UploadedImage> refToUploaded,
    required bool isRepublish,
    String? coverUrl,
  }) {
    final screenplayMap =
        Map<String, dynamic>.from(tree['screenplay'] as Map<String, dynamic>);
    final title = screenplayMap['title'] as String? ?? '';
    final summary = screenplayMap['summary'] as String? ?? '';

    final screenplayPayload = <String, dynamic>{
      'title': title,
      'subtitle': screenplayMap['subtitle'] as String? ?? '',
      'cover_url': '',
      'cover_ref': null,
      'visibility': visibility,
    };
    if (summary.isNotEmpty) {
      screenplayPayload['summary'] = summary;
    }
    final kind = (screenplayMap['kind'] as num?)?.toInt();
    if (kind != null && kind > 0) {
      screenplayPayload['kind'] = kind;
    }

    final resolvedCoverUrl = coverUrl ??
        ScreenplayImageResolver.coverRemoteUrl(screenplayMap) ??
        '';
    if (resolvedCoverUrl.isNotEmpty) {
      screenplayPayload['cover_url'] = resolvedCoverUrl;
    }

    final assetMap = <String, dynamic>{};
    final actPayloads = <Map<String, dynamic>>[];
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final actNode = acts[actIdx] as Map<String, dynamic>;
      final actMap = actNode['act'] as Map<String, dynamic>;
      final actId = _saveNodeId(
        (actMap['id'] as num?)?.toInt() ?? 0,
        isRepublish,
      );

      final actFields = <String, dynamic>{
        'title': actMap['title'] as String? ?? '',
        'sort': (actMap['sort'] as num?)?.toInt() ?? actIdx + 1,
      };
      if (actId > 0) actFields['id'] = actId;
      final actSummary = actMap['summary'] as String?;
      if (actSummary != null && actSummary.isNotEmpty) {
        actFields['summary'] = actSummary;
      }

      final scenePayloads = <Map<String, dynamic>>[];
      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final sceneNode = scenes[sceneIdx] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneId = _saveNodeId(
          (sceneMap['id'] as num?)?.toInt() ?? 0,
          isRepublish,
        );

        final sceneFields = <String, dynamic>{
          'title': sceneMap['title'] as String? ?? '',
          'sort': (sceneMap['sort'] as num?)?.toInt() ?? sceneIdx + 1,
          'location': sceneMap['location'] as String? ?? '',
          'time_of_day': sceneMap['time_of_day'] as String? ?? '',
        };
        if (sceneId > 0) sceneFields['id'] = sceneId;
        final sceneSummary = sceneMap['summary'] as String?;
        if (sceneSummary != null && sceneSummary.isNotEmpty) {
          sceneFields['summary'] = sceneSummary;
        }

        final framePayloads = <Map<String, dynamic>>[];
        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIdx = 0; frameIdx < frames.length; frameIdx++) {
          final frameMap = frames[frameIdx] as Map<String, dynamic>;
          final ref = frameRef(actIdx, sceneIdx, frameIdx);
          final frameId = _saveNodeId(
            (frameMap['id'] as num?)?.toInt() ?? 0,
            isRepublish,
          );

          final framePayload = <String, dynamic>{
            'title': frameMap['title'] as String? ?? '',
            'sort': (frameMap['sort'] as num?)?.toInt() ?? frameIdx + 1,
            'duration_sec': (frameMap['duration_sec'] as num?)?.toInt() ?? 3,
            'aspect_ratio': frameMap['aspect_ratio'] as String? ?? '',
            'shot_type': frameMap['shot_type'] as String? ?? '',
            'extra_params': frameMap['extra_params'] ?? {},
            'image_url': '',
            'thumbnail_url': '',
            'image_ref': null,
            'thumbnail_ref': null,
          };
          if (frameId > 0) framePayload['id'] = frameId;

          final dialogue = frameMap['dialogue'] as String?;
          if (dialogue != null && dialogue.isNotEmpty) {
            framePayload['dialogue'] = dialogue;
          }
          final actionNote = frameMap['action_note'] as String?;
          if (actionNote != null && actionNote.isNotEmpty) {
            framePayload['action_note'] = actionNote;
          }

          final uploaded = refToUploaded[ref];
          final existingId = _existingFrameImageId(frameMap);
          final remoteUrl = ScreenplayImageResolver.frameRemoteUrl(frameMap);
          final thumbnailUrl =
              ScreenplayImageResolver.hasRemoteUrl(frameMap['thumbnail_url'] as String?)
                  ? frameMap['thumbnail_url'] as String
                  : '';

          if (uploaded != null) {
            assetMap.putIfAbsent(ref, () => _frameAssetEntry(uploaded));
            final tRef = thumbRef(ref);
            if (uploaded.thumbUrl.isNotEmpty) {
              assetMap.putIfAbsent(tRef, () => _thumbAssetEntry(uploaded));
              framePayload['thumbnail_ref'] = tRef;
            }
            framePayload['image_ref'] = ref;
          } else if (remoteUrl != null && existingId != null) {
            framePayload['image_url'] = remoteUrl;
            framePayload['acgn_image_id'] = existingId;
            if (thumbnailUrl.isNotEmpty) {
              framePayload['thumbnail_url'] = thumbnailUrl;
            }
            final fileId = (frameMap['acgn_image_file_id'] as num?)?.toInt();
            if (fileId != null && fileId > 0) {
              framePayload['acgn_image_file_id'] = fileId;
            }
          } else if (existingId != null) {
            final fallback = UploadedImage(
              imageId: existingId,
              displayUrl: remoteUrl ?? '',
              thumbUrl: thumbnailUrl,
              displayFileId:
                  (frameMap['acgn_image_file_id'] as num?)?.toInt(),
            );
            assetMap.putIfAbsent(ref, () => _frameAssetEntry(fallback));
            framePayload['image_ref'] = ref;
          }

          final characterId = (frameMap['acgn_character_id'] as num?)?.toInt();
          if (characterId != null && characterId > 0) {
            framePayload['acgn_character_id'] = characterId;
          }

          final referencePaths = frameMap['reference_local_paths'];
          if (referencePaths is List && referencePaths.isNotEmpty) {
            final referenceRefs = <String>[];
            for (var refIdx = 0; refIdx < referencePaths.length; refIdx++) {
              final refKey =
                  referenceImageRef(actIdx, sceneIdx, frameIdx, refIdx);
              final uploaded = refToUploaded[refKey];
              if (uploaded != null) {
                assetMap.putIfAbsent(
                  refKey,
                  () => _referenceAssetEntry(uploaded),
                );
                referenceRefs.add(refKey);
              }
            }
            if (referenceRefs.isNotEmpty) {
              framePayload['reference_refs'] = referenceRefs;
            }
          }

          framePayloads.add(framePayload);
        }

        scenePayloads.add({
          'scene': sceneFields,
          'frames': framePayloads,
        });
      }

      actPayloads.add({
        'act': actFields,
        'scenes': scenePayloads,
      });
    }

    return {
      if (assetMap.isNotEmpty) 'asset_map': assetMap,
      'screenplay': screenplayPayload,
      'acts': actPayloads,
    };
  }

  static int _saveNodeId(int existingId, bool isRepublish) {
    if (!isRepublish) return 0;
    return existingId > 0 ? existingId : 0;
  }

  /// Whether GET `/tree` already contains act/scene/frame hierarchy.
  static bool rawTreeHasHierarchy(Map<String, dynamic> rawTree) {
    final screenplay = rawTree['screenplay'] as Map<String, dynamic>?;
    if (screenplay != null) {
      final actCount = (screenplay['act_count'] as num?)?.toInt() ?? 0;
      if (actCount > 0) return true;
    }
    final acts = rawTree['acts'] as List<dynamic>? ?? [];
    return acts.isNotEmpty;
  }

  /// Copies remote act/scene/frame ids onto a local tree by structural index.
  static void stampServerNodeIds(
    Map<String, dynamic> localTree,
    Map<String, dynamic> serverTree,
  ) {
    final localActs = localTree['acts'] as List<dynamic>? ?? [];
    final serverActs = serverTree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0;
        actIdx < localActs.length && actIdx < serverActs.length;
        actIdx++) {
      final localActNode = localActs[actIdx] as Map<String, dynamic>;
      final serverActNode = serverActs[actIdx] as Map<String, dynamic>;
      final localAct = localActNode['act'] as Map<String, dynamic>;
      final serverAct = serverActNode['act'] as Map<String, dynamic>;
      final serverActId = (serverAct['id'] as num?)?.toInt() ?? 0;
      if (serverActId > 0) {
        localAct['id'] = serverActId;
      }

      final localScenes = localActNode['scenes'] as List<dynamic>? ?? [];
      final serverScenes = serverActNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIdx = 0;
          sceneIdx < localScenes.length && sceneIdx < serverScenes.length;
          sceneIdx++) {
        final localSceneNode = localScenes[sceneIdx] as Map<String, dynamic>;
        final serverSceneNode = serverScenes[sceneIdx] as Map<String, dynamic>;
        final localScene = localSceneNode['scene'] as Map<String, dynamic>;
        final serverScene = serverSceneNode['scene'] as Map<String, dynamic>;
        final serverSceneId = (serverScene['id'] as num?)?.toInt() ?? 0;
        if (serverSceneId > 0) {
          localScene['id'] = serverSceneId;
        }

        final localFrames = localSceneNode['frames'] as List<dynamic>? ?? [];
        final serverFrames = serverSceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIdx = 0;
            frameIdx < localFrames.length && frameIdx < serverFrames.length;
            frameIdx++) {
          final localFrame = localFrames[frameIdx] as Map<String, dynamic>;
          final serverFrame = serverFrames[frameIdx] as Map<String, dynamic>;
          final serverFrameId = (serverFrame['id'] as num?)?.toInt() ?? 0;
          if (serverFrameId > 0) {
            localFrame['id'] = serverFrameId;
          }
        }
      }
    }
  }

  /// Merges save-tree response into a local document, preserving local paths.
  static ScreenplayTreeDocument applySaveTreeResponse({
    required api.GetScreenplayTreeResp response,
    required ScreenplayLocalMeta meta,
    Map<String, dynamic>? previousTree,
    Map<String, dynamic>? rawTree,
  }) {
    final tree = rawTree != null
        ? deepCopyJson(rawTree)
        : treeToJsonMap(response);
    if (previousTree != null) {
      _preserveLocalPaths(tree, previousTree);
    }

    final sp = response.screenplay;
    final publishedAt = sp.publishedAt.isNotEmpty
        ? DateTime.tryParse(sp.publishedAt)
        : meta.publishedAt;
    final kind = sp.kind.toInt();
    final forkSource = sp.forkSourceId?.toInt() ?? meta.effectiveForkSourceId;
    final forkRoot = sp.forkRootId?.toInt() ?? meta.forkRootId;

    return ScreenplayTreeDocument(
      tree: tree,
      meta: meta.copyWith(
        remoteScreenplayId: sp.id.toInt(),
        visibility: sp.visibility.toInt(),
        kind: kind > 0 ? kind : meta.kind,
        forkSourceId: forkSource,
        forkRootId: forkRoot,
        forkCount: sp.forkCount.toInt(),
        forkedFromId: forkSource,
        updatedAt: DateTime.now(),
        publishedAt: publishedAt ?? DateTime.now(),
      ),
    );
  }

  /// Applies raw GET `/tree` JSON (preserves fields missing from generated DTOs).
  static ScreenplayTreeDocument applyRawTreeResponse({
    required Map<String, dynamic> rawTree,
    required ScreenplayLocalMeta meta,
    Map<String, dynamic>? previousTree,
  }) {
    final tree = deepCopyJson(rawTree);
    if (previousTree != null) {
      _preserveLocalPaths(tree, previousTree);
    }

    final sp = tree['screenplay'] as Map<String, dynamic>;
    final publishedAtRaw = sp['published_at'] as String? ?? '';
    final publishedAt = publishedAtRaw.isNotEmpty
        ? DateTime.tryParse(publishedAtRaw)
        : meta.publishedAt;
    final kind = (sp['kind'] as num?)?.toInt() ?? meta.kind;
    final forkSource = (sp['fork_source_id'] as num?)?.toInt() ??
        meta.effectiveForkSourceId;
    final forkRoot =
        (sp['fork_root_id'] as num?)?.toInt() ?? meta.forkRootId;

    return ScreenplayTreeDocument(
      tree: tree,
      meta: meta.copyWith(
        remoteScreenplayId: (sp['id'] as num?)?.toInt(),
        visibility: (sp['visibility'] as num?)?.toInt() ?? meta.visibility,
        kind: kind > 0 ? kind : meta.kind,
        forkSourceId: forkSource,
        forkRootId: forkRoot,
        forkCount: (sp['fork_count'] as num?)?.toInt() ?? meta.forkCount,
        forkedFromId: forkSource,
        updatedAt: DateTime.now(),
        publishedAt: publishedAt ?? DateTime.now(),
      ),
    );
  }

  static void _preserveLocalPaths(
    Map<String, dynamic> tree,
    Map<String, dynamic> previousTree,
  ) {
    final prevScreenplay = previousTree['screenplay'] as Map<String, dynamic>?;
    final screenplay = tree['screenplay'] as Map<String, dynamic>;
    final localCover = prevScreenplay?['local_cover_path'] as String?;
    if (localCover != null && localCover.isNotEmpty) {
      screenplay['local_cover_path'] = localCover;
    }

    final prevActs = previousTree['acts'] as List<dynamic>? ?? [];
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0;
        actIdx < acts.length && actIdx < prevActs.length;
        actIdx++) {
      final prevScenes =
          (prevActs[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
              [];
      final scenes =
          (acts[actIdx] as Map<String, dynamic>)['scenes'] as List<dynamic>? ??
              [];
      for (var sceneIdx = 0;
          sceneIdx < scenes.length && sceneIdx < prevScenes.length;
          sceneIdx++) {
        final prevFrames = (prevScenes[sceneIdx] as Map<String, dynamic>)['frames']
                as List<dynamic>? ??
            [];
        final frames = (scenes[sceneIdx] as Map<String, dynamic>)['frames']
                as List<dynamic>? ??
            [];
        for (var frameIdx = 0;
            frameIdx < frames.length && frameIdx < prevFrames.length;
            frameIdx++) {
          final prevFrame = prevFrames[frameIdx] as Map<String, dynamic>;
          final frame = frames[frameIdx] as Map<String, dynamic>;
          final localImage = prevFrame['local_image_path'] as String?;
          final localThumb = prevFrame['local_thumbnail_path'] as String?;
          if (localImage != null && localImage.isNotEmpty) {
            frame['local_image_path'] = localImage;
          }
          if (localThumb != null && localThumb.isNotEmpty) {
            frame['local_thumbnail_path'] = localThumb;
          }
          final prevRefs = prevFrame['reference_local_paths'];
          if (prevRefs is List && prevRefs.isNotEmpty) {
            frame['reference_local_paths'] = List<dynamic>.from(prevRefs);
          }
        }
      }
    }
  }

  /// Writes draft shoot defaults/overrides and resolved frame params into tree JSON.
  static Map<String, dynamic> applyDraftShootParamsToTree(
    Map<String, dynamic> tree,
    ScreenplayDraft draft,
  ) {
    final copy = deepCopyJson(tree);
    final screenplayMap = copy['screenplay'] as Map<String, dynamic>;
    screenplayMap['shoot_defaults'] = draft.defaultParams.toJson();
    if (draft.linkedCharacters.isEmpty) {
      screenplayMap.remove('linked_characters');
    } else {
      screenplayMap['linked_characters'] =
          draft.linkedCharacters.map((c) => c.toJson()).toList();
    }
    if (draft.linkedScenes.isEmpty) {
      screenplayMap.remove('linked_scenes');
    } else {
      screenplayMap['linked_scenes'] =
          draft.linkedScenes.map((s) => s.toJson()).toList();
    }
    if (draft.lightingSchemeId != null && draft.lightingSchemeId!.isNotEmpty) {
      screenplayMap['lighting_scheme_id'] = draft.lightingSchemeId;
    } else {
      screenplayMap.remove('lighting_scheme_id');
    }
    if (draft.lightingRig != null && draft.lightingRig!.isNotEmpty) {
      screenplayMap['lighting_rig'] = draft.lightingRig;
    } else {
      screenplayMap.remove('lighting_rig');
    }
    if (draft.cineSetupId != null && draft.cineSetupId!.isNotEmpty) {
      screenplayMap['cine_setup_id'] = draft.cineSetupId;
    } else {
      screenplayMap.remove('cine_setup_id');
    }
    if (draft.cineSetup != null && draft.cineSetup!.isNotEmpty) {
      screenplayMap['cine_setup'] = draft.cineSetup;
    } else {
      screenplayMap.remove('cine_setup');
    }

    final acts = copy['acts'] as List<dynamic>? ?? [];
    for (var actIndex = 0;
        actIndex < acts.length && actIndex < draft.acts.length;
        actIndex++) {
      final actNode = acts[actIndex] as Map<String, dynamic>;
      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIndex = 0;
          sceneIndex < scenes.length &&
              sceneIndex < draft.acts[actIndex].scenes.length;
          sceneIndex++) {
        final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneDraft = draft.acts[actIndex].scenes[sceneIndex];

        if (sceneDraft.sceneLibraryId != null &&
            sceneDraft.sceneLibraryId!.isNotEmpty) {
          sceneMap['scene_library_id'] = sceneDraft.sceneLibraryId;
          sceneMap['scene_library_title'] = sceneDraft.sceneLibraryTitle;
        } else {
          sceneMap.remove('scene_library_id');
          sceneMap.remove('scene_library_title');
        }

        if (sceneHasParamOverride(sceneDraft)) {
          sceneMap['shoot_override'] = sceneDraft.paramOverride!.toJson();
        } else {
          sceneMap.remove('shoot_override');
        }

        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIndex = 0;
            frameIndex < frames.length && frameIndex < sceneDraft.frames.length;
            frameIndex++) {
          final frameMap = frames[frameIndex] as Map<String, dynamic>;
          final frameDraft = sceneDraft.frames[frameIndex];
          final effective = effectiveParamsForFrame(
            draft,
            actIndex,
            sceneIndex,
            frameIndex,
          );

          frameMap['aspect_ratio'] = effective.aspectRatio ?? '';
          frameMap['extra_params'] = <String, dynamic>{
            if (effective.device != null && effective.device!.isNotEmpty)
              'device': effective.device,
            if (effective.lighting != null && effective.lighting!.isNotEmpty)
              'lighting': effective.lighting,
          };

          if (frameHasParamOverride(frameDraft)) {
            frameMap['shoot_override'] = frameDraft.paramOverride!.toJson();
          } else {
            frameMap.remove('shoot_override');
          }

          writeCineParamsToFrameMap(frameMap, frameDraft);

          if (frameDraft.lightingSchemeId != null &&
              frameDraft.lightingSchemeId!.isNotEmpty) {
            frameMap['lighting_scheme_id'] = frameDraft.lightingSchemeId;
          } else {
            frameMap.remove('lighting_scheme_id');
          }
          if (frameDraft.lightingRig != null &&
              frameDraft.lightingRig!.isNotEmpty) {
            frameMap['lighting_rig'] = frameDraft.lightingRig;
          } else {
            frameMap.remove('lighting_rig');
          }
          if (frameDraft.cineSetupId != null &&
              frameDraft.cineSetupId!.isNotEmpty) {
            frameMap['cine_setup_id'] = frameDraft.cineSetupId;
          } else {
            frameMap.remove('cine_setup_id');
          }
          if (frameDraft.cineSetup != null &&
              frameDraft.cineSetup!.isNotEmpty) {
            frameMap['cine_setup'] = frameDraft.cineSetup;
          } else {
            frameMap.remove('cine_setup');
          }
        }
      }
    }

    return copy;
  }

  /// Writes draft act/scene/frame tags into tree JSON.
  static Map<String, dynamic> applyDraftTagsToTree(
    Map<String, dynamic> tree,
    ScreenplayDraft draft,
  ) {
    final copy = deepCopyJson(tree);

    final acts = copy['acts'] as List<dynamic>? ?? [];
    for (var actIndex = 0;
        actIndex < acts.length && actIndex < draft.acts.length;
        actIndex++) {
      final actNode = acts[actIndex] as Map<String, dynamic>;
      final actMap = actNode['act'] as Map<String, dynamic>;
      final actDraft = draft.acts[actIndex];

      if (actDraft.tags.isEmpty) {
        actMap.remove('tags');
      } else {
        actMap['tags'] = actDraft.tags.toList()..sort();
      }

      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIndex = 0;
          sceneIndex < scenes.length &&
              sceneIndex < actDraft.scenes.length;
          sceneIndex++) {
        final sceneNode = scenes[sceneIndex] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneDraft = actDraft.scenes[sceneIndex];

        if (sceneDraft.tags.isEmpty) {
          sceneMap.remove('tags');
        } else {
          sceneMap['tags'] = sceneDraft.tags.toList()..sort();
        }

        final frames = sceneNode['frames'] as List<dynamic>? ?? [];
        for (var frameIndex = 0;
            frameIndex < frames.length && frameIndex < sceneDraft.frames.length;
            frameIndex++) {
          final frameMap = frames[frameIndex] as Map<String, dynamic>;
          final frameDraft = sceneDraft.frames[frameIndex];

          if (frameDraft.tags.isEmpty) {
            frameMap.remove('tags');
          } else {
            frameMap['tags'] = frameDraft.tags.toList()..sort();
          }
        }
      }
    }

    return copy;
  }
}
