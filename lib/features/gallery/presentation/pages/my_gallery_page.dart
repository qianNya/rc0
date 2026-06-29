import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../upload/data/image_pick_service.dart';
import '../../data/image_gallery_repository.dart';
import '../../data/image_tags_repository.dart';
import '../../domain/gallery_image.dart';
import '../../domain/image_tag.dart';
import '../widgets/gallery_category_chips.dart';
import '../widgets/gallery_masonry_grid.dart';
import '../widgets/gallery_page_header.dart';
import '../widgets/gallery_tags_tab.dart';
import '../widgets/gallery_works_tab.dart';
import '../../../ip/presentation/widgets/ip_tab.dart';

class MyGalleryPage extends StatefulWidget {
  const MyGalleryPage({super.key});

  @override
  State<MyGalleryPage> createState() => _MyGalleryPageState();
}

class _MyGalleryPageState extends State<MyGalleryPage> {
  final _auth = AuthRepository.instance;
  final _gallery = ImageGalleryRepository.instance;
  final _tags = ImageTagsRepository.instance;
  final _picker = ImagePickService();
  final _ipTabKey = GlobalKey<IpTabState>();
  final _worksTabKey = GlobalKey<GalleryWorksTabState>();

  bool _uploading = false;
  int _mainTabIndex = 0;
  int _categoryIndex = 0;
  bool _ipTabVisited = false;
  bool _worksTabVisited = false;
  bool _tagsTabVisited = false;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onDataChanged);
    _gallery.addListener(_onDataChanged);
    _tags.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _auth.removeListener(_onDataChanged);
    _gallery.removeListener(_onDataChanged);
    _tags.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Future<void> _load() async {
    if (!_auth.isLoggedIn) return;
    await Future.wait([
      _gallery.loadFirstPage(),
      _tags.loadTags(),
    ]);
  }

  Future<void> _refresh() async {
    if (!_auth.isLoggedIn) return;
    await _load();
    if (_mainTabIndex == 1) {
      await _ipTabKey.currentState?.load();
    } else if (_mainTabIndex == 2) {
      await _worksTabKey.currentState?.load();
    } else if (_mainTabIndex == 3) {
      await _tags.loadTags();
    }
  }

  List<String> get _categoryLabels => [
        '全部',
        ..._tags.tags.map((t) => t.name).where((n) => n.isNotEmpty),
      ];

  List<GalleryImage> get _filteredImages {
    final items = _gallery.items;
    if (_categoryIndex == 0 || _tags.tags.isEmpty) return items;
    final tagIndex = _categoryIndex - 1;
    if (tagIndex < 0 || tagIndex >= _tags.tags.length) return items;
    final tag = _tags.tags[tagIndex];
    return items.where((image) => image.matchesTag(tag)).toList();
  }

  int get _masonryColumns {
    if (Breakpoints.isDesktop(context)) return 4;
    return 3;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickAndUpload() async {
    if (!_auth.isLoggedIn) {
      context.go(AppRoutes.loginWithRedirect(AppRoutes.library));
      return;
    }
    if (_uploading) return;

    final picked = await _picker.pickImages();
    if (!mounted || picked.added.isEmpty) return;

    setState(() => _uploading = true);
    var success = 0;
    String? lastError;

    for (final file in picked.added) {
      final result = await _gallery.uploadStandalone(File(file.path));
      if (result.error != null) {
        lastError = result.error;
      } else {
        success += 1;
      }
    }

    if (!mounted) return;
    setState(() => _uploading = false);

    if (success > 0) {
      _showSnack('已上传 $success 张图片');
    } else {
      _showSnack(lastError ?? '上传失败');
    }
  }

  void _openPreview(List<GalleryImage> items, int index) {
    final paths = items
        .map((e) => resolveNetworkImageUrl(e.displayUrl) ?? e.displayUrl)
        .where((p) => p.isNotEmpty)
        .toList(growable: false);

    if (paths.isEmpty) {
      _showSnack('暂无可用预览地址');
      return;
    }

    final item = items[index];
    final path = resolveNetworkImageUrl(item.displayUrl) ?? item.displayUrl;
    var previewIndex = paths.indexOf(path);
    if (previewIndex < 0) previewIndex = 0;

    showImagePreview(
      context,
      imagePaths: paths,
      initialIndex: previewIndex,
      captions: items.map((e) => e.title).toList(),
      options: ImagePreviewOptions(
        sourceLabel: '我的图库',
        enableTagEditing: true,
        tagStates: items
            .map(
              (e) => ImagePreviewTagState(
                serverImageId: e.id,
                tags: e.tags,
                tagIds: e.tagIds,
              ),
            )
            .toList(),
        onLoadSuggestedTags: () async {
          if (_tags.tags.isEmpty) await _tags.loadTags();
          return _tags.suggestedNames;
        },
        onSaveImageTags: (previewIndex, desired, currentIds) async {
          final item = items[previewIndex];
          final error = await _tags.applyTagsToImage(
            imageId: item.id,
            currentTagIds: currentIds,
            desiredNames: desired,
          );
          if (error != null) {
            return (tags: item.tags, tagIds: item.tagIds, error: error);
          }
          final detail = await _gallery.fetchDetail(item.id);
          final image = detail.image ?? item;
          return (tags: image.tags, tagIds: image.tagIds, error: null);
        },
        syncInfos: items
            .map((e) => ImagePreviewSyncInfo.uploaded(serverImageId: e.id))
            .toList(),
      ),
    );
  }

  void _onTagSelectedFromList(ImageTag tag) {
    final tagIndex = _tags.tags.indexWhere((t) => t.id == tag.id);
    setState(() {
      _mainTabIndex = 0;
      _categoryIndex = tagIndex >= 0 ? tagIndex + 1 : 0;
    });
  }

  void _onMainTabChanged(int index) {
    setState(() {
      _mainTabIndex = index;
      if (index == 1) _ipTabVisited = true;
      if (index == 2) _worksTabVisited = true;
      if (index == 3) _tagsTabVisited = true;
    });
    if (index == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ipTabKey.currentState?.load();
      });
    } else if (index == 2) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _worksTabKey.currentState?.load();
      });
    } else if (index == 3) {
      _tags.loadTags();
    }
  }

  String _formatTotal(num total) {
    final value = total.toInt();
    if (value >= 1000) {
      final s = value.toString();
      final buf = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return '$value';
  }

  Widget _buildImagesTabScroll({
    required List<GalleryImage> filtered,
    required bool loading,
    required String? error,
    required Color? secondary,
  }) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollEndNotification) return false;
          if (notification.metrics.extentAfter >= 240) return false;
          if (_gallery.hasMore && !_gallery.loadingMore) {
            _gallery.loadMore();
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ..._buildImagesTab(
              filtered: filtered,
              loading: loading,
              error: error,
              secondary: secondary,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppDimensions.spacingLg),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryBody({
    required bool includeHeader,
    required List<GalleryImage> filtered,
    required bool loading,
    required String? error,
    required Color? secondary,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeHeader)
          GalleryPageHeader(
            onUpload: _pickAndUpload,
            uploading: _uploading,
          ),
        FeedTabBar(
          tabs: AppCatalog.galleryTabs,
          selectedIndex: _mainTabIndex,
          onChanged: _onMainTabChanged,
          underlineStyle: true,
          embedded: true,
        ),
        Expanded(
          child: FadeSlideIndexedStack(
            index: _mainTabIndex,
            children: [
              _buildImagesTabScroll(
                filtered: filtered,
                loading: loading,
                error: error,
                secondary: secondary,
              ),
              if (_ipTabVisited)
                IpTab(key: _ipTabKey)
              else
                const SizedBox.shrink(),
              if (_worksTabVisited)
                GalleryWorksTab(key: _worksTabKey)
              else
                const SizedBox.shrink(),
              if (_tagsTabVisited)
                GalleryTagsTab(onTagSelected: _onTagSelectedFromList)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(context);

    if (!_auth.isLoggedIn) {
      final body = EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: '登录后查看图库',
        subtitle: '上传与管理你的参考图片',
        actionLabel: '去登录',
        onAction: () =>
            context.go(AppRoutes.loginWithRedirect(AppRoutes.library)),
      );

      if (isDesktop) {
        return DesktopShellTabScaffold(
          appBar: const GalleryPageHeader(),
          body: body,
        );
      }

      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const GalleryPageHeader(),
              Expanded(child: body),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredImages;
    final loading = _gallery.loading;
    final error = _gallery.error;
    final theme = Theme.of(context);
    final secondary =
        theme.textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    final body = _buildGalleryBody(
      includeHeader: !isDesktop,
      filtered: filtered,
      loading: loading,
      error: error,
      secondary: secondary,
    );

    if (isDesktop) {
      return DesktopShellTabScaffold(
        appBar: GalleryPageHeader(
          onUpload: _pickAndUpload,
          uploading: _uploading,
        ),
        body: body,
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: body,
      ),
    );
  }

  List<Widget> _buildImagesTab({
    required List<GalleryImage> filtered,
    required bool loading,
    required String? error,
    required Color? secondary,
  }) {
    if (loading && _gallery.items.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (_gallery.items.isEmpty) {
      if (error != null) {
        return [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyStateView(
              icon: Icons.cloud_off_outlined,
              title: '加载失败',
              subtitle: error,
              actionLabel: '重试',
              onAction: _load,
            ),
          ),
        ];
      }
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.photo_library_outlined,
            title: '图库还是空的',
            subtitle: '点击右上角上传你的第一张图片',
            actionLabel: '上传图片',
            onAction: _pickAndUpload,
          ),
        ),
      ];
    }

    return [
      if (error != null)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
              AppDimensions.spacingMd,
              0,
            ),
            child: InlineErrorBanner(
              message: error,
              onRetry: () => _gallery.loadFirstPage(),
            ),
          ),
        ),
      SliverToBoxAdapter(
        child: GalleryCategoryChips(
          labels: _categoryLabels,
          selectedIndex: _categoryIndex.clamp(0, _categoryLabels.length - 1),
          onChanged: (index) => setState(() => _categoryIndex = index),
        ),
      ),
      if (filtered.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: EmptyStateView(
              icon: Icons.filter_alt_off_outlined,
              title: '该分类暂无图片',
              subtitle: '试试选择其他标签',
              actionLabel: '查看全部',
              onAction: () => setState(() => _categoryIndex = 0),
            ),
          ),
        )
      else ...[
        SliverToBoxAdapter(
          child: GalleryMasonryGrid(
            items: filtered,
            crossAxisCount: _masonryColumns,
            onTap: (index) => _openPreview(filtered, index),
          ),
        ),
        if (_gallery.loadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.spacingMd),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              top: AppDimensions.spacingMd,
              bottom: AppDimensions.spacingSm,
            ),
            child: Center(
              child: Text(
                '共 ${_formatTotal(_gallery.total)} 张',
                style: TextStyle(fontSize: 13, color: secondary),
              ),
            ),
          ),
        ),
      ],
    ];
  }
}
