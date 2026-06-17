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
  ActNode({required this.act, required this.scenes});
  factory ActNode.fromJson(Map<String, dynamic> m) {
    return ActNode(
      act: Act.fromJson(m['act']),
      scenes: ((m['scenes'] ?? []) as List<dynamic>)
          .map((i) => SceneNode.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'act': act.toJson(), 'scenes': scenes.map((i) => i.toJson())};
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

  final num dataObjectId;

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
    required this.dataObjectId,
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
      dataObjectId: m['data_object_id'] ?? 0,
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
      'data_object_id': dataObjectId,
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

  final num coverObjectId;

  final num publishStatus;

  final num visibility;

  final num status;
  CreateScreenplayReq({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.coverUrl,
    required this.coverObjectId,
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
      coverObjectId: m['cover_object_id'] ?? 0,
      publishStatus: m['publish_status'] ?? 0,
      visibility: m['visibility'] ?? 0,
      status: m['status'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'kind': kind,
      'title': title,
      'subtitle': subtitle,
      'summary': summary,
      'cover_url': coverUrl,
      'cover_object_id': coverObjectId,
      'publish_status': publishStatus,
      'visibility': visibility,
      'status': status,
    };
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

  final num dataObjectId;

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
    required this.dataObjectId,
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
      dataObjectId: m['data_object_id'] ?? 0,
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
      'data_object_id': dataObjectId,
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
  GetScreenplayTreeReq({required this.id});
  factory GetScreenplayTreeReq.fromJson(Map<String, dynamic> m) {
    return GetScreenplayTreeReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class GetScreenplayTreeResp {
  final Screenplay screenplay;

  final List<ActNode> acts;
  GetScreenplayTreeResp({required this.screenplay, required this.acts});
  factory GetScreenplayTreeResp.fromJson(Map<String, dynamic> m) {
    return GetScreenplayTreeResp(
      screenplay: Screenplay.fromJson(m['screenplay']),
      acts: ((m['acts'] ?? []) as List<dynamic>)
          .map((i) => ActNode.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'screenplay': screenplay.toJson(),
      'acts': acts.map((i) => i.toJson()),
    };
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

class ListScreenplaysResp {
  final List<Screenplay> list;

  final num total;
  ListScreenplaysResp({required this.list, required this.total});
  factory ListScreenplaysResp.fromJson(Map<String, dynamic> m) {
    return ListScreenplaysResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Screenplay.fromJson(i))
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
  SceneNode({required this.scene, required this.frames});
  factory SceneNode.fromJson(Map<String, dynamic> m) {
    return SceneNode(
      scene: Scene.fromJson(m['scene']),
      frames: ((m['frames'] ?? []) as List<dynamic>)
          .map((i) => Frame.fromJson(i))
          .toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {'scene': scene.toJson(), 'frames': frames.map((i) => i.toJson())};
  }
}

class Screenplay {
  final num id;

  final num kind;

  final String title;

  final String subtitle;

  final String summary;

  final String coverUrl;

  final num coverObjectId;

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

  final bool isLiked;

  final bool isFavorited;
  Screenplay({
    required this.id,
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.coverUrl,
    required this.coverObjectId,
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
      coverObjectId: m['cover_object_id'] ?? 0,
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
      'cover_object_id': coverObjectId,
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

  final num dataObjectId;

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
    required this.dataObjectId,
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
      dataObjectId: m['data_object_id'] ?? 0,
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
      'data_object_id': dataObjectId,
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

  final num coverObjectId;

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
    required this.coverObjectId,
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
      coverObjectId: m['cover_object_id'] ?? 0,
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
      'cover_object_id': coverObjectId,
      'publish_status': publishStatus,
      'visibility': visibility,
      'status': status,
    };
  }
}
