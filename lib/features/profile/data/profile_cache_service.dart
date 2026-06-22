import 'package:shared_preferences/shared_preferences.dart';

/// Clears non-auth local caches (screenplay drafts, image favorites).
class ProfileCacheService {
  ProfileCacheService._();

  static const _screenplayKey = 'rc0_screenplay_trees';
  static const _favoriteImagesKey = 'rc0_favorite_images';

  static Future<({bool success, String message})> clearCaches({
    bool includeScreenplays = true,
    bool includeFavorites = true,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (includeScreenplays) {
        await prefs.remove(_screenplayKey);
      }
      if (includeFavorites) {
        await prefs.remove(_favoriteImagesKey);
      }
      return (success: true, message: '缓存已清理');
    } catch (e) {
      return (success: false, message: e.toString());
    }
  }
}
