import 'dart:io';

import '../../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import '../../../../core/domain/screenplay/screenplay_image_resolver.dart';
import 'screenplay_tree_document.dart';

abstract final class ScreenplayApiMapper {
  static Screenplay fromListItem(api.Screenplay item) {
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
    );
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

  static Screenplay _applySocial(Screenplay base, api.Screenplay sp) {
    return base.copyWith(
      author: '创作者',
      ownerUserId: sp.creator.toInt(),
      likes: sp.likeCount.toInt(),
      views: sp.viewCount.toInt(),
      favorites: sp.favoriteCount.toInt(),
      isLiked: sp.isLiked,
      isFavorited: sp.isFavorited,
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
    );
  }

  static Screenplay screenplayFromDocument(ScreenplayTreeDocument doc) {
    final base = _screenplayFromRawTree(doc.tree);
    return base.copyWith(
      id: doc.meta.localId,
      tags: doc.meta.tags,
      author: doc.meta.author,
      authorBio: doc.meta.authorBio,
      isLocal: doc.meta.isLocal,
      forkedFromId: doc.meta.forkedFromId,
      forkedFromLocalId: doc.meta.forkedFromLocalId,
      imagesLocalized: doc.meta.imagesLocalized,
      createdAt: doc.meta.createdAt,
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
      'kind': 1,
      'title': sp.title,
      'subtitle': '',
      'summary': sp.synopsis,
      'cover_url': coverRemoteUrl ?? '',
      'cover_object_id': 0,
      'publish_status': 0,
      'visibility': 0,
      'published_at': '',
      'act_count': sp.acts.isNotEmpty ? sp.acts.length : (sp.apiActCount ?? 0),
      'scene_count': sp.acts.isNotEmpty ? sceneTotal : (sp.apiSceneCount ?? 0),
      'frame_count': sp.acts.isNotEmpty ? frameTotal : (sp.apiFrameCount ?? 0),
      'status': 0,
      'create_at': '',
      'update_at': '',
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
      json['local_thumbnail_path'] = localImagePath;
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

  /// Picks cover URL for createScreenplay shell from batch upload results.
  static String coverUrlForShell(Map<String, String> assetMap) {
    final cover = assetMap[coverRef];
    if (cover != null && cover.isNotEmpty) return cover;
    for (final url in assetMap.values) {
      if (url.isNotEmpty) return url;
    }
    return '';
  }

  static String frameRef(int actIdx, int sceneIdx, int frameIdx) =>
      'frame-$actIdx-$sceneIdx-$frameIdx';

  /// Collects local files that need batch upload with stable refs.
  static Map<String, File> collectLocalAssets(Map<String, dynamic> tree) {
    final refToFile = <String, File>{};
    final screenplayMap = tree['screenplay'] as Map<String, dynamic>?;
    if (screenplayMap != null &&
        ScreenplayImageResolver.coverRemoteUrl(screenplayMap) == null) {
      final coverSrc = ScreenplayImageResolver.localUploadPath(
        screenplayMap['local_cover_path'] as String?,
      );
      if (coverSrc != null) {
        refToFile[coverRef] = File(coverSrc);
      }
    }

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

  /// Dedupes refs that point to the same local file (e.g. cover-ref + frame-0-0-0).
  static ({Map<String, File> unique, Map<String, String> refToPrimaryRef})
      dedupeRefsByFile(Map<String, File> refToFile) {
    final pathToPrimaryRef = <String, String>{};
    final refToPrimaryRef = <String, String>{};
    final unique = <String, File>{};

    for (final entry in refToFile.entries) {
      final canonical = _canonicalFilePath(entry.value);
      final primaryRef = pathToPrimaryRef[canonical];
      if (primaryRef == null) {
        pathToPrimaryRef[canonical] = entry.key;
        refToPrimaryRef[entry.key] = entry.key;
        unique[entry.key] = entry.value;
      } else {
        refToPrimaryRef[entry.key] = primaryRef;
      }
    }

    return (unique: unique, refToPrimaryRef: refToPrimaryRef);
  }

  /// Expands uploaded URLs from primary refs to all aliased refs.
  static Map<String, String> expandRefUrls({
    required Map<String, File> refToFile,
    required Map<String, String> uploaded,
    required Map<String, String> refToPrimaryRef,
  }) {
    final expanded = <String, String>{};
    for (final entry in refToFile.entries) {
      final primaryRef = refToPrimaryRef[entry.key] ?? entry.key;
      final url = uploaded[primaryRef];
      if (url != null && url.isNotEmpty) {
        expanded[entry.key] = url;
      }
    }
    return expanded;
  }

  static String _canonicalFilePath(File file) {
    try {
      return file.absolute.resolveSymbolicLinksSync().toLowerCase();
    } catch (_) {
      return file.absolute.path.toLowerCase();
    }
  }

  /// Builds PUT `/tree` JSON body (Mode A) aligned with `screenplay.http` `saveScreenplayTreeJson`.
  static Map<String, dynamic> buildSaveTreePayload({
    required Map<String, dynamic> tree,
    required int visibility,
    required Map<String, String> assetMap,
    required bool isRepublish,
    int version = 0,
    DateTime? publishedAt,
  }) {
    final screenplayMap =
        Map<String, dynamic>.from(tree['screenplay'] as Map<String, dynamic>);
    final title = screenplayMap['title'] as String? ?? '';
    final summary = screenplayMap['summary'] as String? ?? '';

    final screenplayPayload = <String, dynamic>{
      'title': title,
    };
    if (summary.isNotEmpty) {
      screenplayPayload['summary'] = summary;
    }

    final coverRemote = ScreenplayImageResolver.coverRemoteUrl(screenplayMap);

    if (assetMap.containsKey(coverRef)) {
      screenplayPayload['cover_ref'] = coverRef;
    } else if (coverRemote != null) {
      screenplayPayload['cover_url'] = coverRemote;
    }

    if (isRepublish) {
      screenplayPayload['visibility'] = visibility;
      final publishTime = publishedAt ?? DateTime.now();
      screenplayPayload['publish_status'] = 1;
      screenplayPayload['published_at'] = publishTime.toIso8601String();
    }

    final actPayloads = <Map<String, dynamic>>[];
    final acts = tree['acts'] as List<dynamic>? ?? [];
    for (var actIdx = 0; actIdx < acts.length; actIdx++) {
      final actNode = acts[actIdx] as Map<String, dynamic>;
      final actMap = actNode['act'] as Map<String, dynamic>;
      final actId = _saveNodeId(
        (actMap['id'] as num?)?.toInt() ?? 0,
        isRepublish,
      );

      final scenePayloads = <Map<String, dynamic>>[];
      final scenes = actNode['scenes'] as List<dynamic>? ?? [];
      for (var sceneIdx = 0; sceneIdx < scenes.length; sceneIdx++) {
        final sceneNode = scenes[sceneIdx] as Map<String, dynamic>;
        final sceneMap = sceneNode['scene'] as Map<String, dynamic>;
        final sceneId = _saveNodeId(
          (sceneMap['id'] as num?)?.toInt() ?? 0,
          isRepublish,
        );

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
            'dialogue': frameMap['dialogue'] as String? ?? '',
            'action_note': frameMap['action_note'] as String? ?? '',
            'sort': (frameMap['sort'] as num?)?.toInt() ?? frameIdx + 1,
          };
          if (frameId > 0) framePayload['id'] = frameId;

          final remoteUrl = ScreenplayImageResolver.frameRemoteUrl(frameMap);

          if (assetMap.containsKey(ref)) {
            framePayload['image_ref'] = ref;
            framePayload['thumbnail_ref'] = ref;
          } else if (remoteUrl != null) {
            framePayload['image_url'] = remoteUrl;
            framePayload['thumbnail_url'] = remoteUrl;
          }

          framePayloads.add(framePayload);
        }

        final scenePayload = <String, dynamic>{
          'scene': {
            if (sceneId > 0) 'id': sceneId,
            'title': sceneMap['title'] as String? ?? '',
            'summary': sceneMap['summary'] as String? ?? '',
            'location': sceneMap['location'] as String? ?? '',
            'time_of_day': sceneMap['time_of_day'] as String? ?? '',
            'sort': (sceneMap['sort'] as num?)?.toInt() ?? sceneIdx + 1,
          },
          'frames': framePayloads,
        };
        scenePayloads.add(scenePayload);
      }

      actPayloads.add({
        'act': {
          if (actId > 0) 'id': actId,
          'title': actMap['title'] as String? ?? '',
          'summary': actMap['summary'] as String? ?? '',
          'sort': (actMap['sort'] as num?)?.toInt() ?? actIdx + 1,
        },
        'scenes': scenePayloads,
      });
    }

    final payload = <String, dynamic>{
      'asset_map': assetMap,
      'screenplay': screenplayPayload,
      'acts': actPayloads,
    };
    if (version > 0) {
      payload['version'] = version;
    }
    return payload;
  }

  static int _saveNodeId(int existingId, bool isRepublish) {
    if (!isRepublish) return 0;
    return existingId > 0 ? existingId : 0;
  }

  /// Merges save-tree response into a local document, preserving local paths.
  static ScreenplayTreeDocument applySaveTreeResponse({
    required api.GetScreenplayTreeResp response,
    required ScreenplayLocalMeta meta,
    Map<String, dynamic>? previousTree,
  }) {
    final tree = treeToJsonMap(response);
    if (previousTree != null) {
      _preserveLocalPaths(tree, previousTree);
    }

    final sp = response.screenplay;
    final publishedAt = sp.publishedAt.isNotEmpty
        ? DateTime.tryParse(sp.publishedAt)
        : meta.publishedAt;

    return ScreenplayTreeDocument(
      tree: tree,
      meta: meta.copyWith(
        remoteScreenplayId: sp.id.toInt(),
        visibility: sp.visibility.toInt(),
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
        }
      }
    }
  }
}
