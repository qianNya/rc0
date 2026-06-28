/// Central route paths — shared across mobile & desktop shells.
abstract final class AppRoutes {
  // Primary shell routes (L1)
  static const String discovery = '/discovery';
  static const String library = '/library';
  static const String studio = '/studio';
  static const String studioCreate = '/studio/create';
  static const String create = '/create';
  static const String createSettingsPath = '/create/settings';
  static const String createAiHubPath = '/create/ai';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Home sub-routes (alias → discovery; in-page tabs not URL-driven yet)
  static const String follow = '/follow';
  static const String recommend = '/recommend';

  /// @deprecated Use [discovery] instead.
  static const String explore = '/';

  // Utility / stack routes
  static const String community = '/community';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String tasks = '/tasks';

  /// @deprecated Use [create] instead.
  static const String upload = '/upload';

  // Wiki domain routes (剧本 + 角色 + IP)
  static const String wikiScript = '/wiki/script';
  static const String wikiCharacter = '/wiki/character';
  static const String scriptList = '/script';
  static const String scriptDetail = '/script/:id';
  static const String scriptSceneDetail = '/script/:id/scene/:sid';
  static const String scriptShotDetail = '/script/:id/scene/:sid/shot/:kid';
  static const String scriptExport = '/script/:id/export';

  static const String imageDetail = '/image/:id';
  static const String imageAnalysis = '/image/:id/analysis';
  static const String ipCreate = '/ip/create';
  static const String ipDetail = '/ip/:id';
  static const String ipEdit = '/ip/:id/edit';

  static const String character = '/character';
  static const String characterDetail = '/character/:id';
  static const String characterCreate = '/character/create';
  static const String characterEdit = '/character/:id/edit';
  static const String characterAi = '/character/ai';
  static const String myCharacters = '/my-characters';

  static const String scenes = '/scenes';
  static const String sceneDetail = '/scenes/:id';
  static const String sceneCreate = '/scenes/create';
  static const String sceneEdit = '/scenes/:id/edit';
  static const String sceneAi = '/scenes/ai';
  static const String myScenes = '/my-scenes';

  /// @deprecated Use [character] instead.
  static const String characters = '/characters';

  // Photo flow routes (场景摄影流程)
  static const String preset = '/preset';
  static const String presetDetail = '/preset/:id';
  static const String studioEditScript = '/studio/edit/:scriptId';
  static const String studioEditScene = '/studio/edit/:scriptId/scene/:sceneId';
  static const String studioEditFrame =
      '/studio/edit/:scriptId/scene/:sceneId/frame/:frameId';
  static const String studioSettingsPath = '/studio/edit/:scriptId/settings';

  static String shootPresetPicker({
    String mode = 'select',
    String scope = 'screenplay',
    int? actIndex,
    int? sceneIndex,
    int? frameIndex,
  }) {
    final query = <String, String>{'mode': mode, 'scope': scope};
    if (actIndex != null) query['act'] = '$actIndex';
    if (sceneIndex != null) query['scene'] = '$sceneIndex';
    if (frameIndex != null) query['frame'] = '$frameIndex';
    return Uri(path: preset, queryParameters: query).toString();
  }

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
  static String wikiScriptPath() => wikiScript;
  static String wikiCharacterPath() => wikiCharacter;
  static String scriptScene(String scriptId, String sceneId) =>
      '/script/$scriptId/scene/$sceneId';
  static String scriptShot(String scriptId, String sceneId, String shotId) =>
      '/script/$scriptId/scene/$sceneId/shot/$shotId';
  static String scriptExportPath(String id) => '/script/$id/export';
  static String image(String id) => '/image/$id';
  static String imageAnalysisPath(String id) => '/image/$id/analysis';
  static String ip(int id) => '/ip/$id';
  static String ipEditPath(int id) => '/ip/$id/edit';
  static String characterDetailPath(int id) => '/character/$id';
  static String characterEditPath(int id) => '/character/$id/edit';
  static String sceneDetailPath(String id) => '/scenes/$id';
  static String sceneEditPath(String id) => '/scenes/$id/edit';
  static String charactersForWork(int workId) =>
      '$character?work_id=$workId';

  static String presetItem(String id) => '/preset/$id';
  static String user(int id) => '/user/$id';
  static String pose(String id) => '/pose/$id';
  static String createEdit(String id) => studioEdit(id);
  static String studioEdit(String id) => '$studio?edit=${Uri.encodeComponent(id)}';
  static String studioEditScriptPath(String scriptId) =>
      '/studio/edit/${Uri.encodeComponent(scriptId)}';
  static String studioEditScenePath(String scriptId, String sceneId) =>
      '/studio/edit/${Uri.encodeComponent(scriptId)}/scene/${Uri.encodeComponent(sceneId)}';
  static String studioEditFramePath(
    String scriptId,
    String sceneId,
    String frameId,
  ) =>
      '/studio/edit/${Uri.encodeComponent(scriptId)}/scene/${Uri.encodeComponent(sceneId)}/frame/${Uri.encodeComponent(frameId)}';
  static String studioSettings(String scriptId) =>
      '/studio/edit/${Uri.encodeComponent(scriptId)}/settings';
  static String createSettings(String id) =>
      '$createSettingsPath?edit=${Uri.encodeComponent(id)}';
  static String createAiHub(String id) =>
      '$createAiHubPath?edit=${Uri.encodeComponent(id)}';

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
