import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../social/data/social_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../../screenplay/data/screenplay_bundle_service.dart';
import '../../../screenplay/data/screenplay_image_localization_service.dart';
import '../../../screenplay/data/screenplay_image_upload_service.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_publish_service.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../screenplay/data/screenplay_tree_document.dart';
import '../../../screenplay/data/shoot_params_draft.dart';
import '../../../screenplay/domain/shoot_params.dart';
import '../utils/screenplay_preview_options.dart';
import '../widgets/frame_thumbnail_grid.dart';
import '../widgets/publish_visibility_dialog.dart';
import '../widgets/screenplay_delete_actions.dart';
import '../widgets/screenplay_detail_hero.dart';
import '../widgets/screenplay_info_header.dart';
import '../widgets/screenplay_structure_tree.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class ScreenplayDetailPage extends ConsumerStatefulWidget {
  const ScreenplayDetailPage({super.key, required this.scriptId});

  final String scriptId;

  @override
  ConsumerState<ScreenplayDetailPage> createState() =>
      _ScreenplayDetailPageState();
}

class _ScreenplayDetailPageState extends ConsumerState<ScreenplayDetailPage> {
  final _localRepository = ScreenplayLocalRepository.instance;
  final _remoteRepository = ScreenplayRemoteRepository.instance;

  Screenplay? _remoteScreenplay;
  bool _loadingRemote = false;
  String? _remoteError;

  @override
  void initState() {
    super.initState();
    _localRepository.addListener(_onDataChanged);
    _loadScreenplay().then((_) => _startImageLocalization());
  }

  @override
  void dispose() {
    ScreenplayImageLocalizationService.instance.stopTracking();
    _localRepository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Screenplay? _resolveLocalScreenplay() {
    final direct = _localRepository.findById(widget.scriptId);
    if (direct != null) return direct;

    final remoteId = int.tryParse(widget.scriptId);
    if (remoteId != null) {
      return _localRepository.findByRemoteId(remoteId);
    }
    return null;
  }

  Future<void> _loadScreenplay() async {
    if (_resolveLocalScreenplay() != null) return;

    final id = int.tryParse(widget.scriptId);
    if (id == null) return;

    setState(() {
      _loadingRemote = true;
      _remoteError = null;
    });

    final result = await _remoteRepository.fetchScreenplayTree(id);
    if (!mounted) return;

    setState(() {
      _loadingRemote = false;
      _remoteScreenplay = result.screenplay;
      _remoteError = result.error;
    });
    if (result.screenplay != null) {
      await _enrichCreatorProfile(result.screenplay!);
    }
  }

  Future<void> _enrichCreatorProfile(Screenplay script) async {
    final ownerId = script.ownerUserId;
    if (ownerId == null || ownerId <= 0) return;
    final needsProfile = script.author.isEmpty ||
        script.author == '创作者' ||
        script.author.startsWith('用户 ');
    if (!needsProfile) return;

    final profile =
        await UserProfileRepository.instance.fetchPublicProfile(ownerId);
    if (!mounted || profile == null) return;

    final name = profile.nickname.isNotEmpty
        ? profile.nickname
        : profile.username;
    setState(() {
      if (_remoteScreenplay?.remoteScreenplayId == script.remoteScreenplayId ||
          _remoteScreenplay?.id == script.id) {
        _remoteScreenplay = script.copyWith(
          author: name,
          authorAvatar: profile.avatar.isNotEmpty ? profile.avatar : null,
        );
      }
    });
  }

  Future<void> _startImageLocalization() async {
    if (!mounted) return;

    final local = _resolveLocalScreenplay();
    if (local != null) {
      final localId = _localRepository.resolveLocalId(local) ?? local.id;
      await ScreenplayImageLocalizationService.instance
          .trackLocalScreenplay(localId);
      return;
    }

    final remoteId = int.tryParse(widget.scriptId);
    if (remoteId != null) {
      await ScreenplayImageLocalizationService.instance
          .trackRemoteScreenplay(remoteId);
    }
  }

  Screenplay? get _screenplay => _resolveLocalScreenplay() ?? _remoteScreenplay;

  bool _forking = false;
  bool _likeBusy = false;
  bool _followBusy = false;
  bool _downloading = false;
  bool _publishing = false;
  bool _uploadingFrame = false;
  bool _exporting = false;
  bool _importing = false;

  Future<void> _refreshScreenplay() async {
    final local = _resolveLocalScreenplay();
    if (local != null) {
      setState(() {});
      await _startImageLocalization();
      return;
    }

    final id = int.tryParse(widget.scriptId);
    if (id == null) return;

    _remoteRepository.clearTreeCache(id);
    setState(() {
      _loadingRemote = true;
      _remoteError = null;
    });

    final result =
        await _remoteRepository.fetchScreenplayTree(id, useCache: false);
    if (!mounted) return;

    setState(() {
      _loadingRemote = false;
      _remoteScreenplay = result.screenplay;
      _remoteError = result.error;
    });
    if (result.screenplay != null) {
      await _enrichCreatorProfile(result.screenplay!);
      await _startImageLocalization();
    }
  }

  Future<void> _onEdit(BuildContext context, Screenplay script) async {
    final remoteId = script.remoteScreenplayId ?? int.tryParse(script.id);
    final localDoc = remoteId != null
        ? _localRepository.documentByRemoteId(remoteId)
        : _localRepository.documentById(script.id);

    if (localDoc != null) {
      if (!context.mounted) return;
      context.go(AppRoutes.studioEdit(localDoc.meta.localId));
      return;
    }

    if (remoteId == null) {
      context.go(AppRoutes.studioEdit(script.id));
      return;
    }

    if (!SocialRepository.instance.isCurrentUserOwner(script)) {
      context.go(AppRoutes.studioEdit(script.id));
      return;
    }

    showGlassProgressSheet<void>(
      context,
      title: '正在打开',
      isDismissible: false,
      child: const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );

    final result = await _localRepository.openRemoteForEdit(remoteId);
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pop();

    if (result.error != null || result.screenplay == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error ?? '无法打开编辑')));
      return;
    }

    context.go(AppRoutes.studioEdit(result.screenplay!.id));
  }

  Future<void> _onLike(Screenplay script) async {
    if (_likeBusy || script.isLocal) return;

    if (!ref.read(isLoggedInProvider)) {
      context.go(
        AppRoutes.loginWithRedirect(AppRoutes.script(widget.scriptId)),
      );
      return;
    }

    setState(() => _likeBusy = true);
    final updated = await SocialRepository.instance.toggleLikeScreenplay(script);
    if (!mounted) return;
    setState(() {
      _likeBusy = false;
      if (updated != null) _remoteScreenplay = updated;
    });
  }

  Future<void> _onFollow(Screenplay script) async {
    final ownerId = script.ownerUserId;
    if (_followBusy || ownerId == null || ownerId <= 0) return;

    if (!ref.read(isLoggedInProvider)) {
      context.go(
        AppRoutes.loginWithRedirect(AppRoutes.script(widget.scriptId)),
      );
      return;
    }

    setState(() => _followBusy = true);
    final err = await SocialRepository.instance.followUser(ownerId);
    if (!mounted) return;
    setState(() => _followBusy = false);
    if (err != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(err)));
    }
  }

  Future<void> _onFork(Screenplay script) async {
    if (_forking) return;
    setState(() => _forking = true);

    final result = await _localRepository.fork(script);
    if (!mounted) return;
    setState(() => _forking = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    final forked = result.screenplay!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已保存副本到本地')));
    context.go(AppRoutes.script(forked.id));
  }

  Future<void> _onDownloadCopy(Screenplay script) async {
    if (_downloading) return;
    setState(() => _downloading = true);

    final result = await _localRepository.downloadLocalCopy(script.id);
    if (!mounted) return;
    setState(() => _downloading = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('图片已下载到本地')));
    setState(() {});
  }

  Future<void> _onPublish(Screenplay script) async {
    if (_publishing) return;

    if (!ref.read(isLoggedInProvider)) {
      context.go(
        AppRoutes.loginWithRedirect(AppRoutes.script(widget.scriptId)),
      );
      return;
    }

    final doc = _localRepository.documentById(script.id);
    if (doc == null) return;

    final isSync = doc.meta.remoteScreenplayId != null;

    int visibility;
    int kind = doc.meta.kind;
    if (isSync) {
      visibility = doc.meta.visibility ?? 0;
    } else {
      final picked = await PublishVisibilityDialog.show(context);
      if (picked == null || !mounted) return;
      visibility = picked.visibility;
      kind = picked.kind;
    }

    final progress = ValueNotifier<(String, int, int)>(('准备', 0, 1));
    if (!mounted) return;
    showPublishProgressSheet(context, progress: progress);

    setState(() => _publishing = true);

    final result = isSync
        ? await ScreenplayPublishService.instance.syncToServer(
            document: doc,
            visibility: visibility,
            onProgress: (stage, done, total) {
              progress.value = (stage, done, total);
            },
          )
        : await ScreenplayPublishService.instance.publish(
            document: doc,
            visibility: visibility,
            kind: kind,
            onProgress: (stage, done, total) {
              progress.value = (stage, done, total);
            },
          );

    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    setState(() => _publishing = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    await _localRepository.updateDocument(result.result!.document);
    if (!mounted) return;

    if (isSync) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('同步成功')));
    } else {
      final visibilityLabel = visibility == 1 ? '公开' : '非公开';
      final kindLabel =
          kind == Screenplay.kindTemplate ? '模板' : '作品';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('发布成功（$kindLabel · $visibilityLabel）')),
        );
    }
    setState(() {});
  }

  Future<void> _onPromoteToTemplate(Screenplay script) async {
    final remoteId = script.remoteScreenplayId;
    if (remoteId == null || _publishing) return;
    if (!ref.read(isLoggedInProvider)) {
      context.go(
        AppRoutes.loginWithRedirect(AppRoutes.script(widget.scriptId)),
      );
      return;
    }

    setState(() => _publishing = true);
    final result =
        await ScreenplayPublishService.instance.promoteToTemplate(remoteId);
    if (!mounted) return;
    setState(() => _publishing = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }

    final localId = _localRepository.resolveLocalId(script) ?? script.id;
    final doc = _localRepository.documentById(localId);
    if (doc != null) {
      final tree = deepCopyJson(doc.tree);
      final screenplayMap = tree['screenplay'] as Map<String, dynamic>;
      screenplayMap['kind'] = Screenplay.kindTemplate;
      screenplayMap['visibility'] = 1;
      await _localRepository.updateDocument(
        ScreenplayTreeDocument(
          tree: tree,
          meta: doc.meta.copyWith(
            kind: Screenplay.kindTemplate,
            visibility: 1,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }

    if (!mounted) return;
    if (_remoteScreenplay != null &&
        (_remoteScreenplay!.remoteScreenplayId == remoteId ||
            _remoteScreenplay!.id == script.id)) {
      _remoteScreenplay = _remoteScreenplay!.copyWith(
        kind: Screenplay.kindTemplate,
        visibility: 1,
      );
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('已设为模板')));
    setState(() {});
  }

  Future<void> _onExport(Screenplay script) async {
    if (_exporting) return;
    final doc = _localRepository.documentById(script.id);
    if (doc == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('仅本地剧本可导出')));
      return;
    }

    setState(() => _exporting = true);
    final result = await ScreenplayBundleService.instance.exportToFile(doc);
    if (!mounted) return;
    setState(() => _exporting = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    if (result.path != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('已导出: ${result.path}')));
    }
  }

  Future<void> _onImport() async {
    if (_importing) return;
    setState(() => _importing = true);
    final result = await ScreenplayBundleService.instance.importFromFile();
    if (!mounted) return;
    setState(() => _importing = false);

    if (result.error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(result.error!)));
      return;
    }
    if (result.document != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('导入成功')));
      context.go(AppRoutes.script(result.document!.meta.localId));
    }
  }

  void _showMoreMenu(
    BuildContext context,
    Screenplay script, {
    required bool isOwner,
    VoidCallback? onPublish,
    VoidCallback? onSync,
    VoidCallback? onExport,
    VoidCallback? onDownloadCopy,
    VoidCallback? onPromoteToTemplate,
    bool publishing = false,
    bool exporting = false,
    bool downloading = false,
  }) {
    showGlassSheet<void>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onPublish != null)
            GlassListRow(
              leading: const Icon(Icons.publish_outlined),
              title: '发布',
              onTap: publishing
                  ? null
                  : () {
                      Navigator.pop(context);
                      onPublish();
                    },
            ),
          if (onSync != null)
            GlassListRow(
              leading: const Icon(Icons.cloud_upload_outlined),
              title: '同步到服务器',
              onTap: publishing
                  ? null
                  : () {
                      Navigator.pop(context);
                      onSync();
                    },
            ),
          if (onPromoteToTemplate != null)
            GlassListRow(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: '设为模板',
              onTap: publishing
                  ? null
                  : () {
                      Navigator.pop(context);
                      onPromoteToTemplate();
                    },
            ),
          if (onDownloadCopy != null)
            GlassListRow(
              leading: const Icon(Icons.download_outlined),
              title: '下载副本',
              onTap: downloading
                  ? null
                  : () {
                      Navigator.pop(context);
                      onDownloadCopy();
                    },
            ),
          if (onExport != null)
            GlassListRow(
              leading: const Icon(Icons.upload_outlined),
              title: '导出 JSON',
              onTap: exporting
                  ? null
                  : () {
                      Navigator.pop(context);
                      onExport();
                    },
            ),
          GlassListRow(
            leading: const Icon(Icons.download_outlined),
            title: '导入剧本 JSON',
            onTap: _importing
                ? null
                : () {
                    Navigator.pop(context);
                    _onImport();
                  },
          ),
          if (isOwner)
            GlassListRow(
              leading: const Icon(Icons.delete_outline),
              iconColor: AppColors.error,
              title: '删除剧本',
              onTap: () {
                Navigator.pop(context);
                deleteScreenplayAndPop(
                  context,
                  script: script,
                );
              },
            ),
        ],
      ),
    );
  }

  void _showDeleteMessage(String? error, {String success = '已删除'}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(error ?? success)),
      );
  }

  Future<void> _onDeleteAct(Screenplay script, int actIndex) async {
    final act = script.acts[actIndex];
    final confirmed = await confirmDeleteNode(
      context,
      title: '删除幕',
      message: '确定删除「${act.title}」？关联的场与画格将一并删除。',
    );
    if (!confirmed || !mounted) return;

    final result = await _localRepository.deleteAct(script.id, actIndex);
    _showDeleteMessage(result.error);
  }

  Future<void> _onDeleteScene(
    Screenplay script,
    int actIndex,
    int sceneIndex,
  ) async {
    final scene = script.acts[actIndex].scenes[sceneIndex];
    final confirmed = await confirmDeleteNode(
      context,
      title: '删除场',
      message: '确定删除「${scene.title}」？关联的画格将一并删除。',
    );
    if (!confirmed || !mounted) return;

    final result = await _localRepository.deleteScene(
      script.id,
      actIndex,
      sceneIndex,
    );
    _showDeleteMessage(result.error);
  }

  Future<void> _onDeleteFrame(
    Screenplay script,
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    final confirmed = await confirmDeleteNode(
      context,
      title: '删除画格',
      message: '确定删除该画格？',
    );
    if (!confirmed || !mounted) return;

    final result = await _localRepository.deleteFrame(
      script.id,
      actIndex,
      sceneIndex,
      frameIndex,
    );
    _showDeleteMessage(result.error);
  }

  Future<bool> _onUploadFrame(
    Screenplay script,
    int actIndex,
    int sceneIndex,
    int frameIndex,
  ) async {
    if (_uploadingFrame) return false;
    final doc = _localRepository.documentById(script.id);
    if (doc == null) {
      _showDeleteMessage('本地剧本不存在');
      return false;
    }

    setState(() => _uploadingFrame = true);
    try {
      final result =
          await ScreenplayImageUploadService.instance.uploadFrameImage(
        document: doc,
        actIdx: actIndex,
        sceneIdx: sceneIndex,
        frameIdx: frameIndex,
      );
      if (!mounted) return result.error == null;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(result.error ?? '图片已上传')),
        );
      return result.error == null;
    } finally {
      if (mounted) setState(() => _uploadingFrame = false);
    }
  }

  ImagePreviewOptions _previewOptions(Screenplay script) {
    final doc = _localRepository.documentById(script.id);
    final isOwner = SocialRepository.instance.isCurrentUserOwner(script);
    return buildScreenplayPreviewOptions(
      screenplay: script,
      document: doc,
      onUploadFrame: isOwner
          ? (actIdx, sceneIdx, frameIdx) => _onUploadFrame(
                script,
                actIdx,
                sceneIdx,
                frameIdx,
              )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final script = _screenplay;

    if (script == null && _loadingRemote) {
      return DesktopStackScaffold(
        title: const Text('剧本详情'),
        onBack: () => popOrGoDiscovery(context),
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: AspectRatio(
                aspectRatio: 2.35,
                child: PlaceholderImage(
                  aspectRatio: 2.35,
                  borderRadius: 0,
                  iconSize: 48,
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              sliver: FeedGridSkeleton(sliver: true, tileCount: 4),
            ),
          ],
        ),
      );
    }

    if (script == null) {
      final needsLogin = isUnauthorizedError(_remoteError);
      return DesktopStackScaffold(
        title: const Text('剧本详情'),
        onBack: () => popOrGoDiscovery(context),
        body: Center(
          child: GlassEmptyState(
            icon: Icons.search_off_outlined,
            title: needsLogin ? '请先登录' : '剧本不存在',
            subtitle: needsLogin
                ? '登录后查看远程剧本详情'
                : (_remoteError ?? '可能已被删除，或链接无效'),
            actionLabel: needsLogin ? '去登录' : '重试',
            onAction: needsLogin
                ? () => context.go(
                      AppRoutes.loginWithRedirect(
                        AppRoutes.script(widget.scriptId),
                      ),
                    )
                : _loadScreenplay,
          ),
        ),
      );
    }

    final isOwner = SocialRepository.instance.isCurrentUserOwner(script);
    final previewOptions = _previewOptions(script);
    final shootDefaults = shootDefaultsFromLocalDocument(
      _localRepository.documentById(script.id),
    );

    return ResponsiveBuilder(
      mobile: (_) => _ScreenplayDetailMobile(
        screenplay: script,
        previewOptions: previewOptions,
        shootDefaults: shootDefaults,
        isOwner: isOwner,
        onEdit: isOwner ? () => _onEdit(context, script) : null,
        onFork: () => _onFork(script),
        onDownloadCopy: script.needsImageDownload
            ? () => _onDownloadCopy(script)
            : null,
        onPublish: isOwner && !script.isPublished
            ? () => _onPublish(script)
            : null,
        onSync: isOwner && script.isPublished
            ? () => _onPublish(script)
            : null,
        onExport: isOwner && script.isPublished
            ? () => _onExport(script)
            : null,
        onMore: () => _showMoreMenu(
          context,
          script,
          isOwner: isOwner,
          onPublish: isOwner && !script.isPublished
              ? () => _onPublish(script)
              : null,
          onSync: isOwner && script.isPublished
              ? () => _onPublish(script)
              : null,
          onPromoteToTemplate: isOwner &&
                  script.isPublished &&
                  !script.isTemplate
              ? () => _onPromoteToTemplate(script)
              : null,
          onExport: isOwner && script.isPublished
              ? () => _onExport(script)
              : null,
          onDownloadCopy: script.needsImageDownload
              ? () => _onDownloadCopy(script)
              : null,
          publishing: _publishing,
          exporting: _exporting,
          downloading: _downloading,
        ),
        onDeleteAct: isOwner ? (i) => _onDeleteAct(script, i) : null,
        onDeleteScene: isOwner
            ? (actIndex, sceneIndex) =>
                _onDeleteScene(script, actIndex, sceneIndex)
            : null,
        onDeleteFrame: isOwner
            ? (actIndex, sceneIndex, frameIndex) => _onDeleteFrame(
                  script,
                  actIndex,
                  sceneIndex,
                  frameIndex,
                )
            : null,
        onUploadFrame: isOwner
            ? (actIndex, sceneIndex, frameIndex) => _onUploadFrame(
                  script,
                  actIndex,
                  sceneIndex,
                  frameIndex,
                )
            : null,
        onLike: () => _onLike(script),
        onFollow: () => _onFollow(script),
        likeBusy: _likeBusy,
        followBusy: _followBusy,
        forking: _forking,
        downloading: _downloading,
        publishing: _publishing,
        exporting: _exporting,
        onRefresh: _refreshScreenplay,
      ),
      desktop: (_) => _ScreenplayDetailDesktop(
        screenplay: script,
        previewOptions: previewOptions,
        shootDefaults: shootDefaults,
        isOwner: isOwner,
        onEdit: isOwner ? () => _onEdit(context, script) : null,
        onFork: () => _onFork(script),
        onDownloadCopy: script.needsImageDownload
            ? () => _onDownloadCopy(script)
            : null,
        onPublish: isOwner && !script.isPublished
            ? () => _onPublish(script)
            : null,
        onSync: isOwner && script.isPublished
            ? () => _onPublish(script)
            : null,
        onPromoteToTemplate: isOwner &&
                script.isPublished &&
                !script.isTemplate
            ? () => _onPromoteToTemplate(script)
            : null,
        onExport: isOwner && script.isPublished
            ? () => _onExport(script)
            : null,
        onImport: _onImport,
        onDeleteAct: isOwner ? (i) => _onDeleteAct(script, i) : null,
        onDeleteScene: isOwner
            ? (actIndex, sceneIndex) =>
                _onDeleteScene(script, actIndex, sceneIndex)
            : null,
        onDeleteFrame: isOwner
            ? (actIndex, sceneIndex, frameIndex) => _onDeleteFrame(
                  script,
                  actIndex,
                  sceneIndex,
                  frameIndex,
                )
            : null,
        onUploadFrame: isOwner
            ? (actIndex, sceneIndex, frameIndex) => _onUploadFrame(
                  script,
                  actIndex,
                  sceneIndex,
                  frameIndex,
                )
            : null,
        onLike: () => _onLike(script),
        onFollow: () => _onFollow(script),
        likeBusy: _likeBusy,
        followBusy: _followBusy,
        forking: _forking,
        downloading: _downloading,
        publishing: _publishing,
        exporting: _exporting,
        importing: _importing,
        onRefresh: _refreshScreenplay,
      ),
    );
  }
}

class _ScreenplayDetailMobile extends StatefulWidget {
  const _ScreenplayDetailMobile({
    required this.screenplay,
    required this.previewOptions,
    required this.isOwner,
    this.shootDefaults,
    this.onEdit,
    this.onFork,
    this.onDownloadCopy,
    this.onPublish,
    this.onSync,
    this.onExport,
    this.onMore,
    this.onDeleteAct,
    this.onDeleteScene,
    this.onDeleteFrame,
    this.onUploadFrame,
    this.onLike,
    this.onFollow,
    this.forking = false,
    this.likeBusy = false,
    this.followBusy = false,
    this.downloading = false,
    this.publishing = false,
    this.exporting = false,
    this.onRefresh,
  });

  final Screenplay screenplay;
  final ImagePreviewOptions previewOptions;
  final ShootParams? shootDefaults;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onFork;
  final VoidCallback? onDownloadCopy;
  final VoidCallback? onPublish;
  final VoidCallback? onSync;
  final VoidCallback? onExport;
  final VoidCallback? onMore;
  final Future<void> Function(int actIndex)? onDeleteAct;
  final Future<void> Function(int actIndex, int sceneIndex)? onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onDeleteFrame;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onUploadFrame;
  final VoidCallback? onLike;
  final VoidCallback? onFollow;
  final bool forking;
  final bool likeBusy;
  final bool followBusy;
  final bool downloading;
  final bool publishing;
  final bool exporting;
  final Future<void> Function()? onRefresh;

  @override
  State<_ScreenplayDetailMobile> createState() =>
      _ScreenplayDetailMobileState();
}

class _ScreenplayDetailMobileState extends State<_ScreenplayDetailMobile> {
  int _tabIndex = 0;

  static const _detailTabs = ['结构预览', '模板介绍', '相关模板'];

  @override
  Widget build(BuildContext context) {
    final screenplay = widget.screenplay;
    final frames = screenplay.allFrames;
    final framePaths = frames.map((f) => f.effectiveDisplayPath).toList();
    final frameCaptions = frames.map((f) => f.caption).toList();
    final showFork = !widget.isOwner || screenplay.isForkCopy;

    String primaryLabel;
    VoidCallback? primaryAction;
    bool primaryLoading = false;

    if (widget.isOwner && widget.onEdit != null) {
      primaryLabel = '编辑剧本';
      primaryAction = widget.onEdit;
    } else if (showFork) {
      primaryLabel = widget.forking ? 'Fork 中…' : 'Fork 这个模板';
      primaryAction = widget.forking ? null : widget.onFork;
      primaryLoading = widget.forking;
    } else {
      primaryLabel = '编辑剧本';
      primaryAction = widget.onEdit;
    }

    return GlassHeroPage(
      onBack: () => popOrGoExplore(context),
      onRefresh: widget.onRefresh,
      actions: widget.onMore != null
          ? [
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: widget.onMore,
              ),
            ]
          : null,
      hero: ScreenplayDetailCover(
        screenplay: screenplay,
        previewOptions: widget.previewOptions,
      ),
      heroHeight: 300,
      infoCard: ScreenplayDetailInfoCard(
        screenplay: screenplay,
        shootDefaults: widget.shootDefaults,
        isOwner: widget.isOwner,
        onFollow: widget.onFollow,
        onLike: widget.onLike,
        followBusy: widget.followBusy,
        likeBusy: widget.likeBusy,
        bare: true,
        showInlineActions: false,
      ),
      tabBar: PreferredSize(
        preferredSize: const Size.fromHeight(AppDimensions.feedTabBarHeight),
        child: ColoredBox(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: FeedTabBar(
            tabs: _detailTabs,
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
            underlineStyle: true,
            embedded: true,
            margin: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          AppDimensions.spacingMd,
          AppDimensions.spacingMd,
          AppDimensions.spacingLg,
        ),
        child: GlassCard(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: FadeSlideIndexedStack(
            index: _tabIndex,
            children: [
              ScreenplayStructureTree(
                screenplay: screenplay,
                galleryPaths: framePaths,
                galleryCaptions: frameCaptions,
                previewOptions: widget.previewOptions,
                onDeleteAct: widget.onDeleteAct,
                onDeleteScene: widget.onDeleteScene,
                onDeleteFrame: widget.onDeleteFrame,
                onUploadFrame: widget.onUploadFrame,
              ),
              ScreenplayInfoHeader(
                screenplay: screenplay,
                shootDefaults: widget.shootDefaults,
                showTitle: false,
                showHierarchySummary: false,
                showShootParams: false,
              ),
              const GlassEmptyState(
                icon: Icons.construction_outlined,
                title: '即将上线',
                subtitle: '相关模板推荐正在建设中',
              ),
            ],
          ),
        ),
      ),
      bottomBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
          ),
          child: GlassButton(
            label: primaryLabel,
            filled: true,
            loading: primaryLoading,
            expand: true,
            onPressed: primaryAction,
          ),
        ),
      ),
    );
  }
}

class _ScreenplayDetailDesktop extends StatelessWidget {
  const _ScreenplayDetailDesktop({
    required this.screenplay,
    required this.previewOptions,
    required this.isOwner,
    this.shootDefaults,
    this.onEdit,
    this.onFork,
    this.onDownloadCopy,
    this.onPublish,
    this.onSync,
    this.onPromoteToTemplate,
    this.onExport,
    this.onImport,
    this.onDeleteAct,
    this.onDeleteScene,
    this.onDeleteFrame,
    this.onUploadFrame,
    this.onLike,
    this.onFollow,
    this.forking = false,
    this.likeBusy = false,
    this.followBusy = false,
    this.downloading = false,
    this.publishing = false,
    this.exporting = false,
    this.importing = false,
    this.onRefresh,
  });

  final Screenplay screenplay;
  final ImagePreviewOptions previewOptions;
  final ShootParams? shootDefaults;
  final bool isOwner;
  final VoidCallback? onEdit;
  final VoidCallback? onFork;
  final VoidCallback? onDownloadCopy;
  final VoidCallback? onPublish;
  final VoidCallback? onSync;
  final VoidCallback? onPromoteToTemplate;
  final VoidCallback? onExport;
  final VoidCallback? onImport;
  final Future<void> Function(int actIndex)? onDeleteAct;
  final Future<void> Function(int actIndex, int sceneIndex)? onDeleteScene;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onDeleteFrame;
  final Future<void> Function(int actIndex, int sceneIndex, int frameIndex)?
      onUploadFrame;
  final VoidCallback? onLike;
  final VoidCallback? onFollow;
  final bool forking;
  final bool likeBusy;
  final bool followBusy;
  final bool downloading;
  final bool publishing;
  final bool exporting;
  final bool importing;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final frames = screenplay.allFrames;
    final framePaths = frames.map((f) => f.effectiveDisplayPath).toList();
    final frameCaptions = frames.map((f) => f.caption).toList();
    final ctaLabel = isOwner ? '编辑剧本' : 'Fork 此剧本';
    final showFork = !isOwner || screenplay.isForkCopy;

    return DesktopStackScaffold(
      title: Text(screenplay.title),
      onBack: () => popOrGoDiscovery(context),
      centerTitle: false,
      actions: [
        if (onEdit != null)
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑剧本',
            onPressed: onEdit,
          ),
        if (onPromoteToTemplate != null)
          IconButton(
            icon: const Icon(Icons.auto_awesome_outlined),
            tooltip: '设为模板',
            onPressed: publishing ? null : onPromoteToTemplate,
          ),
        if (onExport != null)
          IconButton(
            icon: const Icon(Icons.upload_outlined),
            tooltip: '导出 JSON',
            onPressed: exporting ? null : onExport,
          ),
        if (onImport != null)
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: '导入剧本 JSON',
            onPressed: importing ? null : onImport,
          ),
      ],
      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.spacingXl),
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (frames.isNotEmpty)
                    PoseCoverImage(
                      imagePath: frames.first.effectiveDisplayPath,
                      aspectRatio: 1.1,
                      iconSize: 64,
                      enablePreview: true,
                      previewGallery: framePaths,
                      previewCaptions: frameCaptions,
                      previewOptions: previewOptions,
                      isUploaded: frames.first.isRemoteUploaded,
                    )
                  else
                    const PoseCoverImage(aspectRatio: 1.1, iconSize: 64),
                  const SizedBox(height: 16),
                  FrameThumbnailGrid(
                    frames: frames,
                    galleryPaths: framePaths,
                    galleryCaptions: frameCaptions,
                    previewOptions: previewOptions,
                    crossAxisCount: 4,
                    showCaptions: false,
                    iconSize: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScreenplayInfoHeader(
                    screenplay: screenplay,
                    shootDefaults: shootDefaults,
                  ),
                  const SizedBox(height: 20),
                  const Text('结构预览', style: AppTextStyles.label),
                  const SizedBox(height: 8),
                  ScreenplayStructureTree(
                    screenplay: screenplay,
                    galleryPaths: framePaths,
                    galleryCaptions: frameCaptions,
                    previewOptions: previewOptions,
                    onDeleteAct: onDeleteAct,
                    onDeleteScene: onDeleteScene,
                    onDeleteFrame: onDeleteFrame,
                    onUploadFrame: onUploadFrame,
                  ),
                  const SizedBox(height: 24),
                  if (onDownloadCopy != null)
                    GlassButton(
                      label: downloading ? '下载中…' : '下载副本',
                      loading: downloading,
                      expand: true,
                      onPressed: downloading ? null : onDownloadCopy,
                    ),
                  if (onDownloadCopy != null)
                    const SizedBox(height: AppDimensions.spacingSm),
                  if (onPublish != null) ...[
                    GlassButton(
                      label: publishing ? '发布中…' : '发布',
                      filled: true,
                      loading: publishing,
                      expand: true,
                      onPressed: publishing ? null : onPublish,
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                  ],
                  if (onSync != null) ...[
                    GlassButton(
                      label: publishing ? '同步中…' : '同步到服务器',
                      filled: true,
                      loading: publishing,
                      expand: true,
                      onPressed: publishing ? null : onSync,
                    ),
                    const SizedBox(height: AppDimensions.spacingSm),
                  ],
                  if (isOwner && onEdit != null)
                    GlassButton(
                      label: ctaLabel,
                      filled: true,
                      expand: true,
                      onPressed: onEdit,
                    )
                  else if (showFork)
                    GlassButton(
                      label: forking ? 'Fork 中…' : 'Fork 此剧本',
                      filled: true,
                      loading: forking,
                      expand: true,
                      onPressed: forking ? null : onFork,
                    ),
                  if (screenplay.isPublished && onExport != null) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    GlassButton(
                      label: exporting ? '导出中…' : '导出 JSON',
                      expand: true,
                      onPressed: exporting ? null : onExport,
                    ),
                  ],
                  if (isOwner && showFork && onFork != null) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    GlassButton(
                      label: forking ? 'Fork 中…' : 'Fork 此剧本',
                      loading: forking,
                      expand: true,
                      onPressed: forking ? null : onFork,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
