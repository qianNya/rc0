import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'screenplay_image_resolver.dart';
import 'script_frame_display.dart';
import 'screenplay_local_repository.dart';
import 'screenplay_tree_document.dart';

class ScreenplayBundleService {
  ScreenplayBundleService._();

  static final ScreenplayBundleService instance = ScreenplayBundleService._();

  Future<({String? path, String? error})> exportToFile(
    ScreenplayTreeDocument document,
  ) async {
    try {
      final title = document.toScreenplay().title;
      final filename = '${_sanitizeFilename(title)}.rc0.json';
      final jsonText = const JsonEncoder.withIndent('  ').convert(
        document.toJson(),
      );

      if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        final savePath = await FilePicker.platform.saveFile(
          dialogTitle: '导出剧本 JSON',
          fileName: filename,
          type: FileType.custom,
          allowedExtensions: ['json'],
        );
        if (savePath == null) {
          return (path: null, error: null);
        }
        final file = File(savePath);
        await file.writeAsString(jsonText, encoding: utf8);
        return (path: file.path, error: null);
      }

      final dir = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${dir.path}/exports');
      if (!exportsDir.existsSync()) {
        await exportsDir.create(recursive: true);
      }
      final file = File('${exportsDir.path}/$filename');
      await file.writeAsString(jsonText, encoding: utf8);
      return (path: file.path, error: null);
    } catch (e) {
      return (path: null, error: e.toString());
    }
  }

  Future<({ScreenplayTreeDocument? document, String? error})> importFromFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'rc0'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        return (document: null, error: null);
      }

      final picked = result.files.first;
      String raw;
      if (picked.bytes != null) {
        raw = utf8.decode(picked.bytes!);
      } else if (picked.path != null) {
        raw = await File(picked.path!).readAsString();
      } else {
        return (document: null, error: '无法读取文件');
      }

      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (!isTreeShapedDocument(map)) {
        return (document: null, error: '不是有效的剧本 JSON 格式');
      }

      final source = ScreenplayTreeDocument.fromJson(map);
      final migrated = ScreenplayLocalRepository.instance.migrateDualPaths(source);
      if (!ScreenplayLocalRepository.instance.isValidForImport(
        migrated.toScreenplay(),
      )) {
        return (document: null, error: '剧本没有有效的画格图片');
      }

      final localId = 'script-${DateTime.now().millisecondsSinceEpoch}';
      final tree = deepCopyJson(migrated.tree);
      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      final remoteId = (screenplayMap['id'] as num?)?.toInt();

      final meta = migrated.meta.copyWith(
        localId: localId,
        isLocal: true,
        imagesLocalized: migrated.meta.imagesLocalized ||
            !migrated.toScreenplay().allFrames.any((f) {
              final p = f.effectiveDisplayPath;
              return p.isNotEmpty && !ScreenplayImageResolver.isNetworkUrl(p);
            }),
        forkedFromId: migrated.meta.remoteScreenplayId ?? remoteId,
        forkedFromLocalId: migrated.meta.localId,
        createdAt: DateTime.now(),
        remoteScreenplayId: null,
        visibility: null,
        treeJsonObjectKey: null,
        publishedAt: null,
      );

      final document = ScreenplayTreeDocument(tree: tree, meta: meta);
      final saved = await ScreenplayLocalRepository.instance.importDocument(
        document,
      );
      if (saved.error != null) {
        return (document: null, error: saved.error);
      }
      return (document: saved.document, error: null);
    } catch (e) {
      return (document: null, error: e.toString());
    }
  }

  String _sanitizeFilename(String title) {
    final sanitized = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return sanitized.isEmpty ? 'screenplay' : sanitized;
  }
}
