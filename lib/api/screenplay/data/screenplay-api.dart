// --C:\Users\qianlNya\GolandProjects\rc0-go\service\screenplay\api\screenplay--

class Act {
  final num id;

  final num screenplayId;

  final String title;

  final String summary;

  final num sort;

  final num sceneCount;

  final num frameCount;

  final num status;

  final String createAt;

  final String updateAt;

  final num creator;

  final num updater;
  Act({
    required this.id,
    required this.screenplayId,
    required this.title,
    required this.summary,
    required this.sort,
    required this.sceneCount,
    required this.frameCount,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.creator,
    required this.updater,
  });
  factory Act.fromJson(Map<String, dynamic> m) {
    return Act(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      sort: m['sort'] ?? 0,
      sceneCount: m['scene_count'] ?? 0,
      frameCount: m['frame_count'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
      creator: m['creator'] ?? 0,
      updater: m['updater'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'title': title,
      'summary': summary,
      'sort': sort,
      'scene_count': sceneCount,
      'frame_count': frameCount,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
      'creator': creator,
      'updater': updater,
    };
  }
}

class ActNode {
  final Act act;

  final List<SceneNode> scenes;

  final TreePage scenePage;
  ActNode({required this.act, required this.scenes, required this.scenePage});
  factory ActNode.fromJson(Map<String, dynamic> m) {
    final actSource = m['act'] is Map<String, dynamic>
        ? m['act'] as Map<String, dynamic>
        : m;
    return ActNode(
      act: Act.fromJson(actSource),
      scenes: ((m['scenes'] ?? []) as List<dynamic>)
          .map((i) => SceneNode.fromJson(i as Map<String, dynamic>))
          .toList(),
      scenePage: m['scene_page'] == null
          ? TreePage(page: 1, pageSize: 100, total: 0)
          : TreePage.fromJson(m['scene_page'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'act': act.toJson(),
      'scenes': scenes.map((i) => i.toJson()),
      'scene_page': scenePage.toJson(),
    };
  }
}

class BatchUploadItem {
  final String ref;

  final String md5;

  final String filename;

  final String objectKey;

  final String bucket;

  final String storage;

  final num size;

  final bool deduplicated;

  final String url;
  BatchUploadItem({
    required this.ref,
    required this.md5,
    required this.filename,
    required this.objectKey,
    required this.bucket,
    required this.storage,
    required this.size,
    required this.deduplicated,
    required this.url,
  });
  factory BatchUploadItem.fromJson(Map<String, dynamic> m) {
    return BatchUploadItem(
      ref: m['ref'] ?? "",
      md5: m['md5'] ?? "",
      filename: m['filename'] ?? "",
      objectKey: m['object_key'] ?? "",
      bucket: m['bucket'] ?? "",
      storage: m['storage'] ?? "",
      size: m['size'] ?? 0,
      deduplicated: m['deduplicated'] ?? false,
      url: m['url'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'ref': ref,
      'md5': md5,
      'filename': filename,
      'object_key': objectKey,
      'bucket': bucket,
      'storage': storage,
      'size': size,
      'deduplicated': deduplicated,
      'url': url,
    };
  }
}

class BatchUploadTreeAssetsReq {
  final num id;
  BatchUploadTreeAssetsReq({required this.id});
  factory BatchUploadTreeAssetsReq.fromJson(Map<String, dynamic> m) {
    return BatchUploadTreeAssetsReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class BatchUploadTreeAssetsResp {
  final List<BatchUploadItem> items;
  BatchUploadTreeAssetsResp({required this.items});
  factory BatchUploadTreeAssetsResp.fromJson(Map<String, dynamic> m) {
    return BatchUploadTreeAssetsResp(
      items: ((m['items'] ?? []) as List<dynamic>)
          .map((i) => BatchUploadItem.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'items': items.map((i) => i.toJson())};
  }
}

class CreateActReq {
  final num screenplayId;

  final String title;

  final String summary;

  final num sort;

  final num status;
  CreateActReq({
    required this.screenplayId,
    required this.title,
    required this.summary,
    required this.sort,
    required this.status,
  });
  factory CreateActReq.fromJson(Map<String, dynamic> m) {
    return CreateActReq(
      screenplayId: m['id'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      sort: m['sort'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'title': title,
      'summary': summary,
      'sort': sort,
      'status': status,
    };
  }
}

class CreateFrameReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final String title;

  final String dialogue;

  final String actionNote;

  final num durationSec;

  final num sort;

  final String thumbnailUrl;

  final String imageUrl;

  final num status;
  CreateFrameReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.title,
    required this.dialogue,
    required this.actionNote,
    required this.durationSec,
    required this.sort,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.status,
  });
  factory CreateFrameReq.fromJson(Map<String, dynamic> m) {
    return CreateFrameReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      title: m['title'] ?? "",
      dialogue: m['dialogue'] ?? "",
      actionNote: m['action_note'] ?? "",
      durationSec: m['duration_sec'] ?? 0,
      sort: m['sort'] ?? 0,
      thumbnailUrl: m['thumbnail_url'] ?? "",
      imageUrl: m['image_url'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'title': title,
      'dialogue': dialogue,
      'action_note': actionNote,
      'duration_sec': durationSec,
      'sort': sort,
      'thumbnail_url': thumbnailUrl,
      'image_url': imageUrl,
      'status': status,
    };
  }
}

class CreateSceneReq {
  final num screenplayId;

  final num actId;

  final String title;

  final String summary;

  final String location;

  final String timeOfDay;

  final num sort;

  final num status;
  CreateSceneReq({
    required this.screenplayId,
    required this.actId,
    required this.title,
    required this.summary,
    required this.location,
    required this.timeOfDay,
    required this.sort,
    required this.status,
  });
  factory CreateSceneReq.fromJson(Map<String, dynamic> m) {
    return CreateSceneReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      location: m['location'] ?? "",
      timeOfDay: m['time_of_day'] ?? "",
      sort: m['sort'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'title': title,
      'summary': summary,
      'location': location,
      'time_of_day': timeOfDay,
      'sort': sort,
      'status': status,
    };
  }
}

class CreateScreenplayReq {
  final num kind;

  final String title;

  final String subtitle;

  final String summary;

  final String coverUrl;

  final num publishStatus;

  final num visibility;

  final num status;
  CreateScreenplayReq({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.coverUrl,
    required this.publishStatus,
    required this.visibility,
    required this.status,
  });
  factory CreateScreenplayReq.fromJson(Map<String, dynamic> m) {
    return CreateScreenplayReq(
      kind: m['kind'] ?? 0,
      title: m['title'] ?? "",
      subtitle: m['subtitle'] ?? "",
      summary: m['summary'] ?? "",
      coverUrl: m['cover_url'] ?? "",
      publishStatus: m['publish_status'] ?? 0,
      visibility: m['visibility'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'kind': kind,
      'visibility': visibility,
      'publish_status': publishStatus,
      'cover_url': coverUrl,
      'status': status,
    };
  }
}

class CreateSpFavoriteReq {
  final num screenplayId;

  final num userId;

  final num status;
  CreateSpFavoriteReq({
    required this.screenplayId,
    required this.userId,
    required this.status,
  });
  factory CreateSpFavoriteReq.fromJson(Map<String, dynamic> m) {
    return CreateSpFavoriteReq(
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'screenplay_id': screenplayId, 'user_id': userId, 'status': status};
  }
}

class CreateSpLikeReq {
  final num screenplayId;

  final num userId;

  final num status;
  CreateSpLikeReq({
    required this.screenplayId,
    required this.userId,
    required this.status,
  });
  factory CreateSpLikeReq.fromJson(Map<String, dynamic> m) {
    return CreateSpLikeReq(
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'screenplay_id': screenplayId, 'user_id': userId, 'status': status};
  }
}

class DeleteActReq {
  final num screenplayId;

  final num actId;
  DeleteActReq({required this.screenplayId, required this.actId});
  factory DeleteActReq.fromJson(Map<String, dynamic> m) {
    return DeleteActReq(screenplayId: m['id'] ?? 0, actId: m['actId'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'actId': actId};
  }
}

class DeleteFrameReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final num frameId;
  DeleteFrameReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.frameId,
  });
  factory DeleteFrameReq.fromJson(Map<String, dynamic> m) {
    return DeleteFrameReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      frameId: m['frameId'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'frameId': frameId,
    };
  }
}

class DeleteSceneReq {
  final num screenplayId;

  final num actId;

  final num sceneId;
  DeleteSceneReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
  });
  factory DeleteSceneReq.fromJson(Map<String, dynamic> m) {
    return DeleteSceneReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'actId': actId, 'sceneId': sceneId};
  }
}

class DeleteScreenplayReq {
  final num id;
  DeleteScreenplayReq({required this.id});
  factory DeleteScreenplayReq.fromJson(Map<String, dynamic> m) {
    return DeleteScreenplayReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteScreenplayTreeReq {
  final num id;
  DeleteScreenplayTreeReq({required this.id});
  factory DeleteScreenplayTreeReq.fromJson(Map<String, dynamic> m) {
    return DeleteScreenplayTreeReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteSpFavoriteReq {
  final num id;
  DeleteSpFavoriteReq({required this.id});
  factory DeleteSpFavoriteReq.fromJson(Map<String, dynamic> m) {
    return DeleteSpFavoriteReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class DeleteSpLikeReq {
  final num id;
  DeleteSpLikeReq({required this.id});
  factory DeleteSpLikeReq.fromJson(Map<String, dynamic> m) {
    return DeleteSpLikeReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class Frame {
  final num id;

  final num screenplayId;

  final num actId;

  final num sceneId;

  final String title;

  final String dialogue;

  final String actionNote;

  final num durationSec;

  final num sort;

  final String thumbnailUrl;

  final String imageUrl;

  final String imageRef;

  final String thumbnailRef;

  final num status;

  final String createAt;

  final String updateAt;

  final num creator;

  final num updater;
  Frame({
    required this.id,
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.title,
    required this.dialogue,
    required this.actionNote,
    required this.durationSec,
    required this.sort,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.imageRef,
    required this.thumbnailRef,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.creator,
    required this.updater,
  });
  factory Frame.fromJson(Map<String, dynamic> m) {
    return Frame(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      actId: m['act_id'] ?? 0,
      sceneId: m['scene_id'] ?? 0,
      title: m['title'] ?? "",
      dialogue: m['dialogue'] ?? "",
      actionNote: m['action_note'] ?? "",
      durationSec: m['duration_sec'] ?? 0,
      sort: m['sort'] ?? 0,
      thumbnailUrl: m['thumbnail_url'] ?? "",
      imageUrl: m['image_url'] ?? "",
      imageRef: m['image_ref'] ?? "",
      thumbnailRef: m['thumbnail_ref'] ?? "",
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
      creator: m['creator'] ?? 0,
      updater: m['updater'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'act_id': actId,
      'scene_id': sceneId,
      'title': title,
      'dialogue': dialogue,
      'action_note': actionNote,
      'duration_sec': durationSec,
      'sort': sort,
      'thumbnail_url': thumbnailUrl,
      'image_url': imageUrl,
      'image_ref': imageRef,
      'thumbnail_ref': thumbnailRef,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
      'creator': creator,
      'updater': updater,
    };
  }
}

class FrameNode {
  final Frame frame;
  FrameNode({required this.frame});
  factory FrameNode.fromJson(Map<String, dynamic> m) {
    return FrameNode(frame: Frame.fromJson(m['frame']));
  }
  Map<String, dynamic> toJson() {
    return {'frame': frame.toJson()};
  }
}

class GetActReq {
  final num screenplayId;

  final num actId;
  GetActReq({required this.screenplayId, required this.actId});
  factory GetActReq.fromJson(Map<String, dynamic> m) {
    return GetActReq(screenplayId: m['id'] ?? 0, actId: m['actId'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'actId': actId};
  }
}

class GetFrameReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final num frameId;
  GetFrameReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.frameId,
  });
  factory GetFrameReq.fromJson(Map<String, dynamic> m) {
    return GetFrameReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      frameId: m['frameId'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'frameId': frameId,
    };
  }
}

class GetSceneReq {
  final num screenplayId;

  final num actId;

  final num sceneId;
  GetSceneReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
  });
  factory GetSceneReq.fromJson(Map<String, dynamic> m) {
    return GetSceneReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'actId': actId, 'sceneId': sceneId};
  }
}

class GetScreenplayReq {
  final num id;
  GetScreenplayReq({required this.id});
  factory GetScreenplayReq.fromJson(Map<String, dynamic> m) {
    return GetScreenplayReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetScreenplayTreeReq {
  final num id;

  final num depth;

  final num actPage;

  final num actPageSize;

  final num scenePage;

  final num scenePageSize;

  final num framePage;

  final num framePageSize;
  GetScreenplayTreeReq({
    required this.id,
    required this.depth,
    required this.actPage,
    required this.actPageSize,
    required this.scenePage,
    required this.scenePageSize,
    required this.framePage,
    required this.framePageSize,
  });
  factory GetScreenplayTreeReq.fromJson(Map<String, dynamic> m) {
    return GetScreenplayTreeReq(
      id: m['id'] ?? 0,
      depth: m['depth'] ?? 0,
      actPage: m['act_page'] ?? 0,
      actPageSize: m['act_page_size'] ?? 0,
      scenePage: m['scene_page'] ?? 0,
      scenePageSize: m['scene_page_size'] ?? 0,
      framePage: m['frame_page'] ?? 0,
      framePageSize: m['frame_page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'depth': depth,
      'act_page': actPage,
      'act_page_size': actPageSize,
      'scene_page': scenePage,
      'scene_page_size': scenePageSize,
      'frame_page': framePage,
      'frame_page_size': framePageSize,
    };
  }
}

/// Normalizes API tree JSON to the local canonical shape:
/// `acts[].act`, `acts[].scenes[].scene`, `acts[].scenes[].frames[]`.
Map<String, dynamic> normalizeScreenplayTreeJson(Map<String, dynamic> source) {
  final root = Map<String, dynamic>.from(source);
  final screenplay = root['screenplay'];
  if (screenplay is Map<String, dynamic>) {
    final sp = Map<String, dynamic>.from(screenplay);
    if (sp['summary'] == null) sp['summary'] = '';
    if (sp['subtitle'] == null) sp['subtitle'] = '';
    root['screenplay'] = sp;
  }

  final rawActs = root['acts'];
  if (rawActs is! List) return root;

  root['acts'] = rawActs.map((rawAct) {
    final actMap = Map<String, dynamic>.from(rawAct as Map<String, dynamic>);
    if (actMap['act'] is! Map<String, dynamic>) {
      actMap['act'] = Map<String, dynamic>.from(actMap);
    }
    final rawScenes = actMap['scenes'];
    if (rawScenes is List) {
      actMap['scenes'] = rawScenes.map((rawScene) {
        final sceneMap =
            Map<String, dynamic>.from(rawScene as Map<String, dynamic>);
        if (sceneMap['scene'] is! Map<String, dynamic>) {
          sceneMap['scene'] = Map<String, dynamic>.from(sceneMap);
        }
        return sceneMap;
      }).toList();
    }
    return actMap;
  }).toList();

  return root;
}

class GetScreenplayTreeResp {
  final Screenplay screenplay;

  final List<ActNode> acts;

  final TreePage actPage;
  GetScreenplayTreeResp({
    required this.screenplay,
    required this.acts,
    required this.actPage,
  });
  factory GetScreenplayTreeResp.fromJson(Map<String, dynamic> m) {
    final normalized = normalizeScreenplayTreeJson(m);
    return GetScreenplayTreeResp(
      screenplay: Screenplay.fromJson(
        normalized['screenplay'] as Map<String, dynamic>,
      ),
      acts: ((normalized['acts'] ?? []) as List<dynamic>)
          .map((i) => ActNode.fromJson(i as Map<String, dynamic>))
          .toList(),
      actPage: normalized['act_page'] == null
          ? TreePage(page: 1, pageSize: 100, total: 0)
          : TreePage.fromJson(normalized['act_page'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'screenplay': screenplay.toJson(),
      'acts': acts.map((i) => i.toJson()),
      'act_page': actPage.toJson(),
    };
  }
}

class GetSpFavoriteReq {
  final num id;
  GetSpFavoriteReq({required this.id});
  factory GetSpFavoriteReq.fromJson(Map<String, dynamic> m) {
    return GetSpFavoriteReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetSpLikeReq {
  final num id;
  GetSpLikeReq({required this.id});
  factory GetSpLikeReq.fromJson(Map<String, dynamic> m) {
    return GetSpLikeReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class ListActsReq {
  final num screenplayId;

  final num page;

  final num pageSize;
  ListActsReq({
    required this.screenplayId,
    required this.page,
    required this.pageSize,
  });
  factory ListActsReq.fromJson(Map<String, dynamic> m) {
    return ListActsReq(
      screenplayId: m['id'] ?? 0,
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'page': page, 'page_size': pageSize};
  }
}

class ListActsResp {
  final List<Act> list;

  final num total;
  ListActsResp({required this.list, required this.total});
  factory ListActsResp.fromJson(Map<String, dynamic> m) {
    return ListActsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Act.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListFramesReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final num page;

  final num pageSize;
  ListFramesReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.page,
    required this.pageSize,
  });
  factory ListFramesReq.fromJson(Map<String, dynamic> m) {
    return ListFramesReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class ListFramesResp {
  final List<Frame> list;

  final num total;
  ListFramesResp({required this.list, required this.total});
  factory ListFramesResp.fromJson(Map<String, dynamic> m) {
    return ListFramesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Frame.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListScenesReq {
  final num screenplayId;

  final num actId;

  final num page;

  final num pageSize;
  ListScenesReq({
    required this.screenplayId,
    required this.actId,
    required this.page,
    required this.pageSize,
  });
  factory ListScenesReq.fromJson(Map<String, dynamic> m) {
    return ListScenesReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class ListScenesResp {
  final List<Scene> list;

  final num total;
  ListScenesResp({required this.list, required this.total});
  factory ListScenesResp.fromJson(Map<String, dynamic> m) {
    return ListScenesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Scene.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListScreenplaysReq {
  final num page;

  final num pageSize;

  final num kind;

  final num publishStatus;

  final num visibility;

  final String title;

  final num creator;
  ListScreenplaysReq({
    required this.page,
    required this.pageSize,
    required this.kind,
    required this.publishStatus,
    required this.visibility,
    required this.title,
    required this.creator,
  });
  factory ListScreenplaysReq.fromJson(Map<String, dynamic> m) {
    return ListScreenplaysReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      kind: m['kind'] ?? 0,
      publishStatus: m['publish_status'] ?? 0,
      visibility: m['visibility'] ?? 0,
      title: m['title'] ?? "",
      creator: m['creator'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'kind': kind,
      'publish_status': publishStatus,
      'visibility': visibility,
      'title': title,
      'creator': creator,
    };
  }
}

class AuthorSummary {
  final num id;

  final String nickname;

  final String avatar;
  AuthorSummary({
    required this.id,
    required this.nickname,
    required this.avatar,
  });
  factory AuthorSummary.fromJson(Map<String, dynamic> m) {
    return AuthorSummary(
      id: m['id'] ?? 0,
      nickname: m['nickname'] ?? '',
      avatar: m['avatar'] ?? '',
    );
  }
}

class FeedItemDto {
  final String itemType;

  final Screenplay screenplay;

  final AuthorSummary? author;
  FeedItemDto({
    required this.itemType,
    required this.screenplay,
    this.author,
  });
  factory FeedItemDto.fromJson(Map<String, dynamic> m) {
    final screenplayJson = m['screenplay'] is Map<String, dynamic>
        ? m['screenplay'] as Map<String, dynamic>
        : m;
    return FeedItemDto(
      itemType: m['item_type'] ?? '',
      screenplay: Screenplay.fromJson(screenplayJson),
      author: m['author'] is Map<String, dynamic>
          ? AuthorSummary.fromJson(m['author'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ListScreenplaysResp {
  final List<Screenplay> list;

  final List<FeedItemDto> items;

  final num total;

  final num page;

  final num pageSize;
  ListScreenplaysResp({
    required this.list,
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  factory ListScreenplaysResp.fromJson(Map<String, dynamic> m) {
    final rawItems = (m['items'] ?? m['list'] ?? []) as List<dynamic>;
    final feedItems = rawItems
        .map((i) => FeedItemDto.fromJson(i as Map<String, dynamic>))
        .toList();
    return ListScreenplaysResp(
      list: feedItems.map((item) => item.screenplay).toList(),
      items: feedItems,
      total: m['total'] ?? 0,
      page: m['page'] ?? 1,
      pageSize: m['page_size'] ?? 20,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => {
            'item_type': i.itemType,
            'screenplay': i.screenplay.toJson(),
            if (i.author != null) 'author': {
              'id': i.author!.id,
              'nickname': i.author!.nickname,
              'avatar': i.author!.avatar,
            },
          }),
      'total': total,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class ListSpFavoritesReq {
  final num page;

  final num pageSize;

  final num screenplayId;

  final num userId;

  final num status;

  final num deleted;
  ListSpFavoritesReq({
    required this.page,
    required this.pageSize,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.deleted,
  });
  factory ListSpFavoritesReq.fromJson(Map<String, dynamic> m) {
    return ListSpFavoritesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListSpFavoritesResp {
  final List<SpFavorite> list;

  final num total;
  ListSpFavoritesResp({required this.list, required this.total});
  factory ListSpFavoritesResp.fromJson(Map<String, dynamic> m) {
    return ListSpFavoritesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => SpFavorite.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class ListSpLikesReq {
  final num page;

  final num pageSize;

  final num screenplayId;

  final num userId;

  final num status;

  final num deleted;
  ListSpLikesReq({
    required this.page,
    required this.pageSize,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.deleted,
  });
  factory ListSpLikesReq.fromJson(Map<String, dynamic> m) {
    return ListSpLikesReq(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      deleted: m['deleted'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'page_size': pageSize,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
      'deleted': deleted,
    };
  }
}

class ListSpLikesResp {
  final List<SpLike> list;

  final num total;
  ListSpLikesResp({required this.list, required this.total});
  factory ListSpLikesResp.fromJson(Map<String, dynamic> m) {
    return ListSpLikesResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => SpLike.fromJson(i))
          .toList(),
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'list': list.map((i) => i.toJson()), 'total': total};
  }
}

class PingResp {
  final String pong;
  PingResp({required this.pong});
  factory PingResp.fromJson(Map<String, dynamic> m) {
    return PingResp(pong: m['pong'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'pong': pong};
  }
}

class ReorderActsReq {
  final num screenplayId;

  final List<SortItem> items;
  ReorderActsReq({required this.screenplayId, required this.items});
  factory ReorderActsReq.fromJson(Map<String, dynamic> m) {
    return ReorderActsReq(
      screenplayId: m['id'] ?? 0,
      items: ((m['items'] ?? []) as List<dynamic>)
          .map((i) => SortItem.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'id': screenplayId, 'items': items.map((i) => i.toJson())};
  }
}

class ReorderFramesReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final List<SortItem> items;
  ReorderFramesReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.items,
  });
  factory ReorderFramesReq.fromJson(Map<String, dynamic> m) {
    return ReorderFramesReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      items: ((m['items'] ?? []) as List<dynamic>)
          .map((i) => SortItem.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'items': items.map((i) => i.toJson()),
    };
  }
}

class ReorderScenesReq {
  final num screenplayId;

  final num actId;

  final List<SortItem> items;
  ReorderScenesReq({
    required this.screenplayId,
    required this.actId,
    required this.items,
  });
  factory ReorderScenesReq.fromJson(Map<String, dynamic> m) {
    return ReorderScenesReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      items: ((m['items'] ?? []) as List<dynamic>)
          .map((i) => SortItem.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'items': items.map((i) => i.toJson()),
    };
  }
}

class TreeAssetEntry {
  final String kind;

  final String remoteUrl;

  final num? remoteImageId;

  final num? remoteImageFileId;

  TreeAssetEntry({
    required this.kind,
    this.remoteUrl = '',
    this.remoteImageId,
    this.remoteImageFileId,
  });

  factory TreeAssetEntry.fromJson(Map<String, dynamic> m) {
    return TreeAssetEntry(
      kind: m['kind'] ?? '',
      remoteUrl: m['remote_url'] ?? '',
      remoteImageId: m['remote_image_id'],
      remoteImageFileId: m['remote_image_file_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'remote_url': remoteUrl,
      'remote_image_id': remoteImageId,
      'remote_image_file_id': remoteImageFileId,
    };
  }
}

class SaveScreenplayTreeReq {
  final Map<String, TreeAssetEntry> assetMap;

  final Screenplay screenplay;

  final List<ActNode> acts;

  SaveScreenplayTreeReq({
    this.assetMap = const {},
    required this.screenplay,
    required this.acts,
  });

  factory SaveScreenplayTreeReq.fromJson(Map<String, dynamic> m) {
    final rawAssetMap = m['asset_map'] as Map<String, dynamic>? ?? {};
    return SaveScreenplayTreeReq(
      assetMap: rawAssetMap.map(
        (key, value) => MapEntry(
          key,
          TreeAssetEntry.fromJson(value as Map<String, dynamic>),
        ),
      ),
      screenplay: Screenplay.fromJson(m['screenplay'] as Map<String, dynamic>),
      acts: ((m['acts'] ?? []) as List<dynamic>)
          .map((i) => ActNode.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (assetMap.isNotEmpty)
        'asset_map': assetMap.map((key, value) => MapEntry(key, value.toJson())),
      'screenplay': screenplay.toJson(),
      'acts': acts.map((i) => i.toJson()).toList(),
    };
  }
}

class Scene {
  final num id;

  final num screenplayId;

  final num actId;

  final String title;

  final String summary;

  final String location;

  final String timeOfDay;

  final num sort;

  final num frameCount;

  final num status;

  final String createAt;

  final String updateAt;

  final num creator;

  final num updater;
  Scene({
    required this.id,
    required this.screenplayId,
    required this.actId,
    required this.title,
    required this.summary,
    required this.location,
    required this.timeOfDay,
    required this.sort,
    required this.frameCount,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.creator,
    required this.updater,
  });
  factory Scene.fromJson(Map<String, dynamic> m) {
    return Scene(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      actId: m['act_id'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      location: m['location'] ?? "",
      timeOfDay: m['time_of_day'] ?? "",
      sort: m['sort'] ?? 0,
      frameCount: m['frame_count'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
      creator: m['creator'] ?? 0,
      updater: m['updater'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'act_id': actId,
      'title': title,
      'summary': summary,
      'location': location,
      'time_of_day': timeOfDay,
      'sort': sort,
      'frame_count': frameCount,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
      'creator': creator,
      'updater': updater,
    };
  }
}

class SceneNode {
  final Scene scene;

  final List<Frame> frames;

  final TreePage framePage;
  SceneNode({
    required this.scene,
    required this.frames,
    required this.framePage,
  });
  factory SceneNode.fromJson(Map<String, dynamic> m) {
    final sceneSource = m['scene'] is Map<String, dynamic>
        ? m['scene'] as Map<String, dynamic>
        : m;
    return SceneNode(
      scene: Scene.fromJson(sceneSource),
      frames: ((m['frames'] ?? []) as List<dynamic>)
          .map((i) => Frame.fromJson(i as Map<String, dynamic>))
          .toList(),
      framePage: m['frame_page'] == null
          ? TreePage(page: 1, pageSize: 100, total: 0)
          : TreePage.fromJson(m['frame_page'] as Map<String, dynamic>),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'scene': scene.toJson(),
      'frames': frames.map((i) => i.toJson()),
      'frame_page': framePage.toJson(),
    };
  }
}

class Screenplay {
  final num id;

  final num kind;

  final String title;

  final String subtitle;

  final String summary;

  final String coverUrl;

  final String coverRef;

  final num publishStatus;

  final num visibility;

  final String publishedAt;

  final num actCount;

  final num sceneCount;

  final num frameCount;

  final num status;

  final String createAt;

  final String updateAt;

  final num creator;

  final num updater;

  final num viewCount;

  final num likeCount;

  final num favoriteCount;

  final num commentCount;

  final num forkCount;

  final num? forkSourceId;

  final num? forkRootId;

  final bool isLiked;

  final bool isFavorited;
  Screenplay({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.coverUrl,
    required this.coverRef,
    required this.publishStatus,
    required this.visibility,
    required this.publishedAt,
    required this.actCount,
    required this.sceneCount,
    required this.frameCount,
    required this.status,
    required this.createAt,
    required this.updateAt,
    required this.creator,
    required this.updater,
    required this.viewCount,
    required this.likeCount,
    required this.favoriteCount,
    required this.commentCount,
    required this.forkCount,
    this.forkSourceId,
    this.forkRootId,
    required this.isLiked,
    required this.isFavorited,
  });
  factory Screenplay.fromJson(Map<String, dynamic> m) {
    return Screenplay(
      id: m['id'] ?? 0,
      kind: m['kind'] ?? 0,
      title: m['title'] ?? "",
      subtitle: m['subtitle'] ?? "",
      summary: m['summary'] ?? "",
      coverUrl: m['cover_url'] ?? "",
      coverRef: m['cover_ref'] ?? "",
      publishStatus: m['publish_status'] ?? 0,
      visibility: m['visibility'] ?? 0,
      publishedAt: m['published_at'] ?? "",
      actCount: m['act_count'] ?? 0,
      sceneCount: m['scene_count'] ?? 0,
      frameCount: m['frame_count'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
      creator: m['creator'] ?? 0,
      updater: m['updater'] ?? 0,
      viewCount: m['view_count'] ?? 0,
      likeCount: m['like_count'] ?? 0,
      favoriteCount: m['favorite_count'] ?? 0,
      commentCount: m['comment_count'] ?? 0,
      forkCount: m['fork_count'] ?? 0,
      forkSourceId: m['fork_source_id'] as num?,
      forkRootId: m['fork_root_id'] as num?,
      isLiked: m['is_liked'] ?? false,
      isFavorited: m['is_favorited'] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind,
      'title': title,
      'subtitle': subtitle,
      'summary': summary,
      'cover_url': coverUrl,
      'cover_ref': coverRef,
      'publish_status': publishStatus,
      'visibility': visibility,
      'published_at': publishedAt,
      'act_count': actCount,
      'scene_count': sceneCount,
      'frame_count': frameCount,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
      'creator': creator,
      'updater': updater,
      'view_count': viewCount,
      'like_count': likeCount,
      'favorite_count': favoriteCount,
      'comment_count': commentCount,
      'fork_count': forkCount,
      if (forkSourceId != null) 'fork_source_id': forkSourceId,
      if (forkRootId != null) 'fork_root_id': forkRootId,
      'is_liked': isLiked,
      'is_favorited': isFavorited,
    };
  }
}

class ScreenplayEngagementReq {
  final num id;
  ScreenplayEngagementReq({required this.id});
  factory ScreenplayEngagementReq.fromJson(Map<String, dynamic> m) {
    return ScreenplayEngagementReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class SortItem {
  final num id;

  final num sort;
  SortItem({required this.id, required this.sort});
  factory SortItem.fromJson(Map<String, dynamic> m) {
    return SortItem(id: m['id'] ?? 0, sort: m['sort'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'sort': sort};
  }
}

class SpFavorite {
  final num id;

  final num screenplayId;

  final num userId;

  final num status;

  final String createAt;

  final String updateAt;
  SpFavorite({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory SpFavorite.fromJson(Map<String, dynamic> m) {
    return SpFavorite(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class SpLike {
  final num id;

  final num screenplayId;

  final num userId;

  final num status;

  final String createAt;

  final String updateAt;
  SpLike({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
    required this.createAt,
    required this.updateAt,
  });
  factory SpLike.fromJson(Map<String, dynamic> m) {
    return SpLike(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class TreePage {
  final num page;

  final num pageSize;

  final num total;
  TreePage({required this.page, required this.pageSize, required this.total});
  factory TreePage.fromJson(Map<String, dynamic> m) {
    return TreePage(
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
      total: m['total'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {'page': page, 'page_size': pageSize, 'total': total};
  }
}

class UpdateActReq {
  final num screenplayId;

  final num actId;

  final String title;

  final String summary;

  final num sort;

  final num status;
  UpdateActReq({
    required this.screenplayId,
    required this.actId,
    required this.title,
    required this.summary,
    required this.sort,
    required this.status,
  });
  factory UpdateActReq.fromJson(Map<String, dynamic> m) {
    return UpdateActReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      sort: m['sort'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'title': title,
      'summary': summary,
      'sort': sort,
      'status': status,
    };
  }
}

class UpdateFrameReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final num frameId;

  final String title;

  final String dialogue;

  final String actionNote;

  final num durationSec;

  final num sort;

  final String thumbnailUrl;

  final String imageUrl;

  final num status;
  UpdateFrameReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.frameId,
    required this.title,
    required this.dialogue,
    required this.actionNote,
    required this.durationSec,
    required this.sort,
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.status,
  });
  factory UpdateFrameReq.fromJson(Map<String, dynamic> m) {
    return UpdateFrameReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      frameId: m['frameId'] ?? 0,
      title: m['title'] ?? "",
      dialogue: m['dialogue'] ?? "",
      actionNote: m['action_note'] ?? "",
      durationSec: m['duration_sec'] ?? 0,
      sort: m['sort'] ?? 0,
      thumbnailUrl: m['thumbnail_url'] ?? "",
      imageUrl: m['image_url'] ?? "",
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'frameId': frameId,
      'title': title,
      'dialogue': dialogue,
      'action_note': actionNote,
      'duration_sec': durationSec,
      'sort': sort,
      'thumbnail_url': thumbnailUrl,
      'image_url': imageUrl,
      'status': status,
    };
  }
}

class UpdateSceneReq {
  final num screenplayId;

  final num actId;

  final num sceneId;

  final String title;

  final String summary;

  final String location;

  final String timeOfDay;

  final num sort;

  final num status;
  UpdateSceneReq({
    required this.screenplayId,
    required this.actId,
    required this.sceneId,
    required this.title,
    required this.summary,
    required this.location,
    required this.timeOfDay,
    required this.sort,
    required this.status,
  });
  factory UpdateSceneReq.fromJson(Map<String, dynamic> m) {
    return UpdateSceneReq(
      screenplayId: m['id'] ?? 0,
      actId: m['actId'] ?? 0,
      sceneId: m['sceneId'] ?? 0,
      title: m['title'] ?? "",
      summary: m['summary'] ?? "",
      location: m['location'] ?? "",
      timeOfDay: m['time_of_day'] ?? "",
      sort: m['sort'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': screenplayId,
      'actId': actId,
      'sceneId': sceneId,
      'title': title,
      'summary': summary,
      'location': location,
      'time_of_day': timeOfDay,
      'sort': sort,
      'status': status,
    };
  }
}

class UpdateScreenplayReq {
  final num id;

  final num kind;

  final String title;

  final String subtitle;

  final String summary;

  final String coverUrl;

  final num publishStatus;

  final num visibility;

  final num status;
  UpdateScreenplayReq({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.coverUrl,
    required this.publishStatus,
    required this.visibility,
    required this.status,
  });
  factory UpdateScreenplayReq.fromJson(Map<String, dynamic> m) {
    return UpdateScreenplayReq(
      id: m['id'] ?? 0,
      kind: m['kind'] ?? 0,
      title: m['title'] ?? "",
      subtitle: m['subtitle'] ?? "",
      summary: m['summary'] ?? "",
      coverUrl: m['cover_url'] ?? "",
      publishStatus: m['publish_status'] ?? 0,
      visibility: m['visibility'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind,
      'title': title,
      'subtitle': subtitle,
      'summary': summary,
      'cover_url': coverUrl,
      'publish_status': publishStatus,
      'visibility': visibility,
      'status': status,
    };
  }
}

class UpdateSpFavoriteReq {
  final num id;

  final num screenplayId;

  final num userId;

  final num status;
  UpdateSpFavoriteReq({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
  });
  factory UpdateSpFavoriteReq.fromJson(Map<String, dynamic> m) {
    return UpdateSpFavoriteReq(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
    };
  }
}

class UpdateSpLikeReq {
  final num id;

  final num screenplayId;

  final num userId;

  final num status;
  UpdateSpLikeReq({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.status,
  });
  factory UpdateSpLikeReq.fromJson(Map<String, dynamic> m) {
    return UpdateSpLikeReq(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'status': status,
    };
  }
}
