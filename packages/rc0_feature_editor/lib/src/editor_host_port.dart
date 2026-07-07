import 'package:flutter/widgets.dart';

import 'editor_open_args.dart';

/// App shell navigates to editor without cross-feature imports.
abstract interface class EditorHostPort {
  Future<void> openEditor(BuildContext context, EditorOpenArgs args);
}
