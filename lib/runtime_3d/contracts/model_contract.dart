import '../../features/action/presentation/models/action_model_source.dart';

/// Model load payload sent to Unity CharacterModule / AssetStreamingModule.
class ModelLoadPayload {
  const ModelLoadPayload({
    this.path,
    this.bundledKey,
    this.extension,
    this.name,
  });

  final String? path;
  final String? bundledKey;
  final String? extension;
  final String? name;

  factory ModelLoadPayload.fromSource(ActionModelSource source) {
    String? bundledKey;
    if (source.loaderPath != null && source.fileName != null) {
      if (source.loaderPath!.contains('aku_aku')) {
        bundledKey = 'aku_aku';
      } else if (source.loaderPath!.contains('yt')) {
        bundledKey = 'yt';
      }
    }

    return ModelLoadPayload(
      path: source.filePath ??
          (bundledKey == null ? '${source.loaderPath ?? ''}${source.fileName}' : null),
      bundledKey: bundledKey,
      extension: source.extension,
      name: source.name,
    );
  }

  Map<String, dynamic> toJson() => {
        if (path != null) 'path': path,
        if (bundledKey != null) 'bundledKey': bundledKey,
        if (extension != null) 'extension': extension,
        if (name != null) 'name': name,
      };
}
