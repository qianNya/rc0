import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:rc0_feature_editor/rc0_feature_editor.dart';

/// App shell implementation of [EditorHostPort].
final class AppEditorHostPort implements EditorHostPort {
  const AppEditorHostPort();

  @override
  Future<void> openEditor(BuildContext context, EditorOpenArgs args) async {
    if (!context.mounted) return;
    await context.push(args.routePath);
  }
}
