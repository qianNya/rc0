/// Central route paths — shared across mobile & desktop shells.
///
/// Layering:
/// - L0 Shell: discovery, studio, scenes, profile, action, community, assets
/// - L1 Wiki tabs: discovery?hubTab=0|1|2 (embedded, no separate routes)
/// - L2 Stack: CRUD, read, inbox, labs, auth
/// - L3 Editor: studio/edit/... with GoRouter `extra` for live controllers
abstract final class AppRoutes {
  // Primary shell routes (L1)
  static const String discovery = '/discovery';
  static const String discoveryCharacterWiki = '/discovery?hubTab=2';
  static const String discoveryAssetsWiki = '/assets';
  static const String assets = '/assets';
  static const String library = '/library';
  static const String gallery = '/gallery';
  static const String mediaVaultImageDetail = '/gallery/media/:id';
  static const String gearDeviceDetail = '/library/device/:id';
  /// @deprecated Redirects to [library] (gear cabinet).
  static const String equipment = '/equipment';
  /// @deprecated Redirects to [library].
  static const String equipmentDetail = '/equipment/:kind/:id';
  /// @deprecated Redirects to [library].
  static const String myEquipment = '/my-equipment';
  /// @deprecated Use [scenes] shell tab instead.
  static const String screenplays = '/screenplays';
  static const String studio = '/studio';
  static const String studioCreate = '/studio/create';
  /// Full-screen editor on root stack (avoids shell route key clashes).
  static const String studioEditorCreate = '/studio-editor/create';
  static const String create = '/create';
  static const String createAiHubPath = '/create/ai';
  static const String inbox = '/inbox';
  static const String labs = '/labs';
  static const String messages = '/messages';
  static const String profile = '/profile';

  // Home sub-routes (alias → discovery; in-page tabs not URL-driven yet)
  static const String follow = '/follow';
  static const String recommend = '/recommend';

  /// @deprecated Use [discovery] instead.
  static const String explore = '/';

  // Utility / stack routes
  /// @deprecated Redirects to [discoveryTemplate]. Reserved for future social feed.
  static const String community = '/community';

  static const String discoverySectionTemplate = 'template';

  /// Discovery hub with template market tab selected.
  static const String discoveryTemplate =
      '$discovery?section=$discoverySectionTemplate';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String tasks = '/tasks';

  /// @deprecated Use [create] instead.
  static const String upload = '/upload';

  // Wiki domain routes (剧本 + 角色 + IP)
  static const String wikiScript = '/wiki/script';
  static const String wikiCharacter = '/wiki/character';
  /// @deprecated List route — redirects to [community]. Use [script] for read detail.
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
  static const String action = '/action';
  static const String lighting = '/lighting';
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
  /// @deprecated Redirects to [labs].
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
  static String mediaVaultImageDetailPath(String id) => '/gallery/media/$id';
  static String gearDeviceDetailPath(String id) => '/library/device/$id';
  static String equipmentDetailPath(String kind, String id) =>
      '/equipment/$kind/$id';
  static String charactersForWork(int workId) =>
      '$character?work_id=$workId';

  static String presetItem(String id) => '/preset/$id';
  static String user(int id) => '/user/$id';
  static String pose(String id) => '/pose/$id';
  static String createEdit(String id) => studioEdit(id);
  static String studioEdit(String id) => '$studio?edit=${Uri.encodeComponent(id)}';
  static String studioCreateWithCharacter(
    int characterId, {
    String? name,
  }) {
    final params = <String, String>{'characterId': '$characterId'};
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params['characterName'] = trimmed;
    }
    return Uri(path: studioCreate, queryParameters: params).toString();
  }

  static String studioEditorCreateWithCharacter(
    int characterId, {
    String? name,
  }) {
    final params = <String, String>{'characterId': '$characterId'};
    final trimmed = name?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      params['characterName'] = trimmed;
    }
    return Uri(path: studioEditorCreate, queryParameters: params).toString();
  }
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
  static String createAiHub(String id) =>
      '$createAiHubPath?edit=${Uri.encodeComponent(id)}';

  /// @deprecated Use [createEdit] instead.
  static String uploadEdit(String id) => createEdit(id);

  static String discoveryHubTab(int tab) => '$discovery?hubTab=$tab';

  static String assetsHubTab(int tab) => '$assets?tab=$tab';

  static String lightingWithContext({
    String? schemeId,
    int? characterId,
    String? sceneId,
    String scope = 'browse',
    int? actIndex,
    int? sceneIndex,
    int? frameIndex,
  }) {
    final query = <String, String>{'scope': scope};
    if (schemeId != null && schemeId.isNotEmpty) {
      query['schemeId'] = schemeId;
    }
    if (characterId != null) query['characterId'] = '$characterId';
    if (sceneId != null && sceneId.isNotEmpty) query['sceneId'] = sceneId;
    if (actIndex != null) query['act'] = '$actIndex';
    if (sceneIndex != null) query['scene'] = '$sceneIndex';
    if (frameIndex != null) query['frame'] = '$frameIndex';
    return Uri(path: lighting, queryParameters: query).toString();
  }

  static String equipmentWithContext({
    String? setupId,
    String scope = 'browse',
    int? actIndex,
    int? sceneIndex,
    int? frameIndex,
  }) {
    // Legacy wiki equipment hub — now routes to gear cabinet.
    return library;
  }

  static String favoritesTab(int tab) => '$favorites?tab=$tab';
  static String inboxTab(int tab) => '$inbox?tab=$tab';
  static String labsFeature(String featureId) => '$labs?feature=$featureId';
  static String comingSoon(String title) {
    final id = _legacyLabsTitleToId(title);
    if (id != null) return labsFeature(id);
    return '$labs?highlight=${Uri.encodeComponent(title)}';
  }

  static String? _legacyLabsTitleToId(String title) {
    return switch (title) {
      'AI 导入剧本' => 'import_script',
      'AI 生成大纲' => 'gen_outline',
      'AI 扩写剧情' => 'gen_plot',
      'AI 生成分镜' => 'gen_storyboard',
      '生成提示词' => 'gen_prompt',
      '生成图片' => 'gen_image',
      '生成视频' => 'gen_video',
      '角色一致性' => 'character_consistency',
      '会员' => 'membership',
      '关注列表' => 'following',
      '粉丝列表' => 'followers',
      '版本历史' => 'version_history',
      '下载' => 'downloads',
      '数据分析' => 'analytics',
      '帮助中心' => 'help_center',
      '帮助与反馈' => 'help_feedback',
      '灯光学院' => 'lighting_academy',
      '关联角色' => 'image_character_link',
      '分镜' => 'storyboard',
      'AI 工具' => 'import_script',
      _ => null,
    };
  }
  static String loginWithRedirect(String from) =>
      '$login?from=${Uri.encodeComponent(from)}';
  static String registerWithRedirect(String from) =>
      '$register?from=${Uri.encodeComponent(from)}';
}
