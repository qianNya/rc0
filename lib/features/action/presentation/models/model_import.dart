import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'action_model_source.dart';

bool get isRc0RuntimeSupported => !kIsWeb || true;

/// Legacy alias used by wiki pages during migration.
bool get isRealModelViewerRealtimeSupported => isRc0RuntimeSupported;

Future<ActionModelSource?> actionModelSourceFromFile(PlatformFile file) async {
  final extension = (file.extension ?? file.name.split('.').last).toLowerCase();
  final sizeBytes = file.size;

  if (extension == 'pmx' || extension == 'vrm') {
    return ActionModelSource(
      name: file.name,
      extension: extension,
      sizeBytes: sizeBytes,
      kind: ActionModelKind.unsupported,
    );
  }

  if (extension == 'gltf' || extension == 'glb' || extension == 'obj') {
    if (file.path != null && !kIsWeb) {
      final path = file.path!;
      final separator = Platform.pathSeparator;
      final slash = path.lastIndexOf(separator);
      final dir = slash >= 0 ? path.substring(0, slash + 1) : '';
      final fileName = slash >= 0 ? path.substring(slash + 1) : path;
      return ActionModelSource(
        name: file.name,
        extension: extension,
        sizeBytes: sizeBytes,
        kind: extension == 'obj' ? ActionModelKind.obj : ActionModelKind.gltf,
        loaderPath: dir,
        fileName: fileName,
        filePath: path,
      );
    }
  }

  return ActionModelSource(
    name: file.name,
    extension: extension,
    sizeBytes: sizeBytes,
    kind: ActionModelKind.unsupported,
  );
}
