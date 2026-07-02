enum ActionModelKind { gltf, obj, unsupported }

class ActionModelSource {
  ActionModelSource({
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.kind,
    this.loaderPath,
    this.fileName,
    this.filePath,
  });

  final String name;
  final String extension;
  final int sizeBytes;
  final ActionModelKind kind;
  final String? loaderPath;
  final String? fileName;
  final String? filePath;

  bool get canRender => kind != ActionModelKind.unsupported;

  String get sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    if (sizeBytes >= 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '$sizeBytes B';
  }

  String get statusLabel {
    if (!canRender) {
      if (extension == 'pmx') {
        return '已导入 PMX：$name · $sizeLabel（等待 PMX 渲染器支持）';
      }
      return '已导入：$name · $sizeLabel（当前格式等待渲染器支持）';
    }
    return '已导入：$name · $sizeLabel · Unity Runtime（需导出库）';
  }

  String get renderModeLabel {
    if (!canRender) return '等待渲染器支持';
    return 'Unity Runtime（需导出库）';
  }
}

class BundledModelAsset {
  const BundledModelAsset({
    required this.label,
    required this.loaderPath,
    required this.fileName,
    required this.sizeBytes,
  });

  final String label;
  final String loaderPath;
  final String fileName;
  final int sizeBytes;

  ActionModelSource toSource() {
    return ActionModelSource(
      name: label,
      extension: 'gltf',
      sizeBytes: sizeBytes,
      kind: ActionModelKind.gltf,
      loaderPath: loaderPath,
      fileName: fileName,
    );
  }
}

const bundledModelAssets = [
  BundledModelAsset(
    label: 'Aku Aku',
    loaderPath: 'assets/model/aku_aku/',
    fileName: 'scene.gltf',
    sizeBytes: 8642,
  ),
  BundledModelAsset(
    label: '羽蜕-浅憩之处',
    loaderPath: 'assets/model/yt/',
    fileName: '羽蜕-浅憩之处.gltf',
    sizeBytes: 8439037,
  ),
];
