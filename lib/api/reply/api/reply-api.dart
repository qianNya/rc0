import 'api.dart';
import '../data/reply-api.dart';

/// reply-api

/// --/api/reply/comments/:id--
///
/// request: UpdateCommentReq
/// response: Comment
Future updateComment(
  int id,
  UpdateCommentReq request, {
  Function(Comment)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/reply/comments/${id}",
    request,
    ok: (data) {
      if (ok != null) ok(Comment.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/reply/comments/:id--
///
/// request: DeleteCommentReq
/// response:
Future deleteComment(
  int id,
  DeleteCommentReq request, {
  Function()? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/reply/comments/${id}",
    request,
    ok: (data) {
      if (ok != null) ok();
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/reply/screenplays/:screenplay_id/comments--
///
/// request: ListCommentsReq
/// response: ListCommentsResp
Future listComments(
  int screenplay_id, {
  Function(ListCommentsResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/reply/screenplays/${screenplay_id}/comments",
    ok: (data) {
      if (ok != null) ok(ListCommentsResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/reply/screenplays/:screenplay_id/comments--
///
/// request: CreateCommentReq
/// response: Comment
Future createComment(
  int screenplay_id,
  CreateCommentReq request, {
  Function(Comment)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiPost(
    "/api/reply/screenplays/${screenplay_id}/comments",
    request,
    ok: (data) {
      if (ok != null) ok(Comment.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}

/// --/api/reply/ping--
///
/// request:
/// response: PingResp
Future ping({
  Function(PingResp)? ok,
  Function(String)? fail,
  Function? eventually,
}) async {
  await apiGet(
    "/api/reply/ping",
    ok: (data) {
      if (ok != null) ok(PingResp.fromJson(data));
    },
    fail: fail,
    eventually: eventually,
  );
}
