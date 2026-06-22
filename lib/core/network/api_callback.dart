import 'dart:async';

/// Wraps a callback-style API call into `Future<(T?, String?)>`.
Future<(T?, String?)> apiCallback<T>(
  Future<void> Function({
    void Function(T)? ok,
    void Function(String)? fail,
    void Function()? eventually,
  }) call,
) async {
  final completer = Completer<(T?, String?)>();
  await call(
    ok: (value) {
      if (!completer.isCompleted) completer.complete((value, null));
    },
    fail: (msg) {
      if (!completer.isCompleted) completer.complete((null, msg));
    },
  );
  return completer.future;
}

/// Wraps API calls whose success callback returns a value (create/update).
Future<String?> apiCallbackMutate(
  Future<void> Function({
    void Function(dynamic)? ok,
    void Function(String)? fail,
    void Function()? eventually,
  }) call,
) async {
  final (_, err) = await apiCallback<dynamic>(
    ({ok, fail, eventually}) async {
      await call(
        ok: (value) => ok?.call(value),
        fail: fail,
        eventually: eventually,
      );
    },
  );
  return err;
}

/// Wraps a void-success callback API into `Future<String?>` (null = success).
Future<String?> apiCallbackVoid(
  Future<void> Function({
    void Function()? ok,
    void Function(String)? fail,
    void Function()? eventually,
  }) call,
) async {
  final completer = Completer<String?>();
  await call(
    ok: () {
      if (!completer.isCompleted) completer.complete(null);
    },
    fail: (msg) {
      if (!completer.isCompleted) completer.complete(msg);
    },
  );
  return completer.future;
}

/// Wraps API that may fail silently (e.g. profile fetch on startup).
Future<T?> apiCallbackOptional<T>(
  Future<void> Function({
    void Function(T)? ok,
    void Function(String)? fail,
    void Function()? eventually,
  }) call,
) async {
  final (value, _) = await apiCallback<T>(call);
  return value;
}

String adminStr(dynamic value) => value?.toString() ?? '';

Map<String, String> adminRowFromJson(Map<String, dynamic> json) {
  return json.map((key, value) => MapEntry(key, adminStr(value)));
}
