import '../../../api/user/data/user-api.dart';
import '../../../core/data/app_catalog.dart';
import '../../../core/utils/image_url_utils.dart';

/// Display helpers for the current user's [Profile] from the API.
abstract final class ProfileDisplay {
  static String displayName(Profile? profile, {bool loading = false}) {
    if (loading) return '加载中…';
    if (profile == null) return 'rc0用户';

    final nickname = profile.nickname.trim();
    if (nickname.isNotEmpty) return nickname;

    final username = profile.username.trim();
    if (username.isNotEmpty) return username;

    return AppCatalog.placeholderAuthor;
  }

  /// Username handle shown under the display name, e.g. `@foo`.
  static String? handle(Profile? profile) {
    if (profile == null) return null;

    final username = profile.username.trim();
    if (username.isEmpty) return null;

    final nickname = profile.nickname.trim();
    if (nickname.isEmpty) return null;

    return username;
  }

  static String displayBio(Profile? profile, {required bool hasSession}) {
    if (!hasSession) return '登录后查看个人资料与作品';
    if (profile == null) return '正在同步资料…';

    final bio = profile.bio.trim();
    if (bio.isNotEmpty) return bio;

    return '用镜头记录美好，分享创意灵感';
  }

  static String? avatarPath(Profile? profile) {
    if (profile == null) return null;
    return imagePathFromRaw(profile.avatar);
  }

  static String? backgroundPath(Profile? profile) {
    if (profile == null) return null;
    return imagePathFromRaw(profile.backgroundUrl);
  }

  static String? imagePathFromRaw(String? raw) {
    final text = raw?.trim() ?? '';
    if (text.isEmpty) return null;
    return resolveNetworkImageUrl(text) ?? text;
  }

  static String? avatarPathFromRaw(String? raw) => imagePathFromRaw(raw);

  static int? level(Profile? profile) {
    if (profile == null) return null;
    final value = profile.level.toInt();
    return value > 0 ? value : null;
  }
}
