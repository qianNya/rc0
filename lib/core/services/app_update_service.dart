import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/screenplay/data/data_upload_repository.dart';
import '../config/app_update_config.dart';

typedef UpdateProgressCallback = void Function(int received, int? total);

abstract final class AppUpdateService {
  static Future<({bool success, String? error})> downloadAndInstall({
    UpdateProgressCallback? onProgress,
  }) async {
    if (kIsWeb) {
      return (success: false, error: '仅 Android 支持应用内更新');
    }
    if (!Platform.isAndroid) {
      return (success: false, error: '仅 Android 支持应用内更新');
    }

    final resolved = await _resolveDownloadUrl();
    if (resolved.url == null) {
      return (success: false, error: resolved.error ?? '无法获取下载地址');
    }

    return _downloadAndInstallFromUrl(resolved.url!, onProgress: onProgress);
  }

  static Future<({String? url, String? error})> _resolveDownloadUrl() async {
    final presigned = await DataUploadRepository.instance.presignDownloadUrl(
      bucket: AppUpdateConfig.apkBucket,
      objectKey: AppUpdateConfig.apkObjectKey,
      expireSec: AppUpdateConfig.presignExpireSec,
    );
    if (presigned.downloadUrl != null) {
      return (url: presigned.downloadUrl, error: null);
    }

    return (
      url: null,
      error: presigned.error ?? '无法获取 APK 下载链接，请先登录后重试',
    );
  }

  static Future<({bool success, String? error})> _downloadAndInstallFromUrl(
    String downloadUrl, {
    UpdateProgressCallback? onProgress,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(downloadUrl));
      request.headers.set(
        'User-Agent',
        'rc0-app/1.0 (Android; Flutter)',
      );
      request.headers.set('Accept', '*/*');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        final hint = response.statusCode == HttpStatus.forbidden
            ? '（服务器拒绝访问，请确认已登录或联系管理员配置 APK 下载权限）'
            : '';
        return (
          success: false,
          error: '下载失败: HTTP ${response.statusCode}$hint',
        );
      }

      final total = response.contentLength > 0 ? response.contentLength : null;
      final dir = await getTemporaryDirectory();
      final dest = File('${dir.path}/${AppUpdateConfig.apkFileName}');
      if (dest.existsSync()) {
        await dest.delete();
      }

      var received = 0;
      final sink = dest.openWrite();
      await for (final chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }
      await sink.close();

      final result = await OpenFilex.open(dest.path);
      if (result.type != ResultType.done) {
        return (
          success: false,
          error: result.message.isNotEmpty ? result.message : '无法打开安装程序',
        );
      }

      return (success: true, error: null);
    } on SocketException catch (e) {
      return (success: false, error: '网络错误: ${e.message}');
    } catch (e) {
      return (success: false, error: e.toString());
    } finally {
      client.close();
    }
  }
}
