// --C:\Users\qianlNya\GolandProjects\rc0-go\service\reply\api\reply--

class Comment {
  final num id;

  final num screenplayId;

  final num userId;

  final num parentId;

  final num rootId;

  final String content;

  final String createAt;

  final String updateAt;
  Comment({
    required this.id,
    required this.screenplayId,
    required this.userId,
    required this.parentId,
    required this.rootId,
    required this.content,
    required this.createAt,
    required this.updateAt,
  });
  factory Comment.fromJson(Map<String, dynamic> m) {
    return Comment(
      id: m['id'] ?? 0,
      screenplayId: m['screenplay_id'] ?? 0,
      userId: m['user_id'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      rootId: m['root_id'] ?? 0,
      content: m['content'] ?? "",
      createAt: m['create_at'] ?? "",
      updateAt: m['update_at'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'screenplay_id': screenplayId,
      'user_id': userId,
      'parent_id': parentId,
      'root_id': rootId,
      'content': content,
      'create_at': createAt,
      'update_at': updateAt,
    };
  }
}

class CreateCommentReq {
  final num screenplayId;

  final num parentId;

  final String content;
  CreateCommentReq({
    required this.screenplayId,
    required this.parentId,
    required this.content,
  });
  factory CreateCommentReq.fromJson(Map<String, dynamic> m) {
    return CreateCommentReq(
      screenplayId: m['screenplay_id'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      content: m['content'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'screenplay_id': screenplayId,
      'parent_id': parentId,
      'content': content,
    };
  }
}

class DeleteCommentReq {
  final num id;
  DeleteCommentReq({required this.id});
  factory DeleteCommentReq.fromJson(Map<String, dynamic> m) {
    return DeleteCommentReq(id: m['id'] ?? 0);
  }
  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

class ListCommentsReq {
  final num screenplayId;

  final num parentId;

  final num page;

  final num pageSize;
  ListCommentsReq({
    required this.screenplayId,
    required this.parentId,
    required this.page,
    required this.pageSize,
  });
  factory ListCommentsReq.fromJson(Map<String, dynamic> m) {
    return ListCommentsReq(
      screenplayId: m['screenplay_id'] ?? 0,
      parentId: m['parent_id'] ?? 0,
      page: m['page'] ?? 0,
      pageSize: m['page_size'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'screenplay_id': screenplayId,
      'parent_id': parentId,
      'page': page,
      'page_size': pageSize,
    };
  }
}

class ListCommentsResp {
  final List<Comment> list;

  final num total;
  ListCommentsResp({required this.list, required this.total});
  factory ListCommentsResp.fromJson(Map<String, dynamic> m) {
    return ListCommentsResp(
      list: ((m['list'] ?? []) as List<dynamic>)
          .map((i) => Comment.fromJson(i))
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

class UpdateCommentReq {
  final num id;

  final String content;
  UpdateCommentReq({required this.id, required this.content});
  factory UpdateCommentReq.fromJson(Map<String, dynamic> m) {
    return UpdateCommentReq(id: m['id'] ?? 0, content: m['content'] ?? "");
  }
  Map<String, dynamic> toJson() {
    return {'id': id, 'content': content};
  }
}
