import '../../../../api/screenplay/data/screenplay-api.dart' as api;
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_act.dart';
import '../../../../core/domain/screenplay/script_frame.dart';
import '../../../../core/domain/screenplay/script_scene.dart';
import 'screenplay_image_resolver.dart';
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
    final coverDisplay = ScreenplayImageResolver.coverDisplayPath(screenplayMap);

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
      coverUrl: coverRemote ?? coverDisplay,
      localCoverPath: coverLocal,
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
    final coverDisplay = ScreenplayImageResolver.displayPath(
          localPath: coverLocal,
          remoteUrl: coverRemote != null && isNetworkUrl(coverRemote)
              ? coverRemote
              : null,
          legacyPath: coverRemote,
        ) ??
        sp.coverImagePath ??
        '';

    final screenplayMap = <String, dynamic>{
      'id': screenplayNumericId,
      'kind': 1,
      'title': sp.title,
      'subtitle': '',
      'summary': sp.synopsis,
      'cover_url': coverRemote != null && isNetworkUrl(coverRemote)
          ? coverRemote
          : coverDisplay,
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
    if (coverLocal != null && coverLocal.isNotEmpty) {
      screenplayMap['local_cover_path'] = coverLocal;
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
    final localPath = frame.localImagePath;
    final remoteUrl = frame.remoteImageUrl;
    final legacyPath = frame.imagePath;

    String imageUrl;
    String? localImagePath;
    String? localThumbnailPath;

    if (remoteUrl != null && remoteUrl.isNotEmpty) {
      imageUrl = remoteUrl;
      if (localPath != null && localPath.isNotEmpty) {
        localImagePath = localPath;
        localThumbnailPath = localPath;
      }
    } else if (localPath != null && localPath.isNotEmpty) {
      imageUrl = localPath;
      localImagePath = localPath;
      localThumbnailPath = localPath;
    } else if (legacyPath.isNotEmpty && isNetworkUrl(legacyPath)) {
      imageUrl = legacyPath;
    } else {
      imageUrl = legacyPath;
      if (legacyPath.isNotEmpty) {
        localImagePath = legacyPath;
        localThumbnailPath = legacyPath;
      }
    }

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
      'thumbnail_url': imageUrl,
      'image_url': imageUrl,
      'data_object_id': 0,
      'status': 0,
      'create_at': '',
      'update_at': '',
    };
    if (localImagePath != null) json['local_image_path'] = localImagePath;
    if (localThumbnailPath != null) {
      json['local_thumbnail_path'] = localThumbnailPath;
    }
    return json;
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
}
