/// Central route paths — shared across mobile & desktop shells.
abstract final class AppRoutes {
  // Primary tab routes
  static const String discovery = '/discovery';
  static const String library = '/library';
  static const String create = '/create';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Home sub-routes (alias → discovery; in-page tabs not URL-driven yet)
  static const String follow = '/follow';
  static const String recommend = '/recommend';

  /// @deprecated Use [discovery] instead.
  static const String explore = '/';

  // Stack routes
  static const String community = '/community';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String tasks = '/tasks';

  /// @deprecated Use [create] instead.
  static const String upload = '/upload';

  static const String scriptList = '/script';
  static const String scriptDetail = '/script/:id';
  static const String scriptSceneDetail = '/script/:id/scene/:sid';
  static const String scriptShotDetail = '/script/:id/scene/:sid/shot/:kid';
  static const String scriptExport = '/script/:id/export';

  static const String imageDetail = '/image/:id';
  static const String imageAnalysis = '/image/:id/analysis';

  static const String preset = '/preset';
  static const String presetDetail = '/preset/:id';

  static const String profileWorks = '/profile/works';
  static const String profileLikes = '/profile/likes';
  static const String profileEdit = '/profile/edit';
  static const String profileAbout = '/profile/about';
  static const String profileComingSoon = '/profile/coming-soon';

  static const String login = '/login';
  static const String register = '/register';
  static const String userProfile = '/user/:id';
  static const String poseDetail = '/pose/:id';

  static String script(String id) => '/script/$id';
  static String scriptScene(String scriptId, String sceneId) =>
      '/script/$scriptId/scene/$sceneId';
  static String scriptShot(String scriptId, String sceneId, String shotId) =>
      '/script/$scriptId/scene/$sceneId/shot/$shotId';
  static String scriptExportPath(String id) => '/script/$id/export';
  static String image(String id) => '/image/$id';
  static String imageAnalysisPath(String id) => '/image/$id/analysis';
  static String presetItem(String id) => '/preset/$id';
  static String user(int id) => '/user/$id';
  static String pose(String id) => '/pose/$id';
  static String createEdit(String id) => '$create?edit=$id';

  /// @deprecated Use [createEdit] instead.
  static String uploadEdit(String id) => createEdit(id);

  static String favoritesTab(int tab) => '$favorites?tab=$tab';
  static String comingSoon(String title) =>
      '$profileComingSoon?title=${Uri.encodeComponent(title)}';
  static String loginWithRedirect(String from) =>
      '$login?from=${Uri.encodeComponent(from)}';
  static String registerWithRedirect(String from) =>
      '$register?from=${Uri.encodeComponent(from)}';
}
