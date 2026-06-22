/// Central route paths — shared across mobile & desktop shells.
abstract final class AppRoutes {
  static const String explore = '/';
  static const String community = '/community';
  static const String upload = '/upload';
  static const String profile = '/profile';
  static const String profileWorks = '/profile/works';
  static const String profileLikes = '/profile/likes';
  static const String profileEdit = '/profile/edit';
  static const String profileAbout = '/profile/about';
  static const String profileComingSoon = '/profile/coming-soon';
  static const String tasks = '/tasks';
  static const String favorites = '/favorites';
  static const String login = '/login';
  static const String register = '/register';
  static const String scriptDetail = '/script/:id';
  static const String userProfile = '/user/:id';
  static const String poseDetail = '/pose/:id';

  static String script(String id) => '/script/$id';
  static String user(int id) => '/user/$id';
  static String pose(String id) => '/pose/$id';
  static String uploadEdit(String id) => '/upload?edit=$id';
  static String favoritesTab(int tab) => '$favorites?tab=$tab';
  static String comingSoon(String title) =>
      '$profileComingSoon?title=${Uri.encodeComponent(title)}';
  static String loginWithRedirect(String from) =>
      '$login?from=${Uri.encodeComponent(from)}';
  static String registerWithRedirect(String from) =>
      '$register?from=${Uri.encodeComponent(from)}';
}
