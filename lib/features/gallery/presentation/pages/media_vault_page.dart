import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../data/media_vault_repository.dart';
import '../../domain/media_vault_image.dart';
import '../../domain/media_vault_types.dart';
import '../actions/gallery_preview_actions.dart';
import '../actions/gallery_upload_actions.dart';
import '../media_vault/media_vault_albums_grid.dart';
import '../media_vault/media_vault_category_tabs.dart';
import '../media_vault/media_vault_colors.dart';
import '../media_vault/media_vault_detail_panel.dart';
import '../media_vault/media_vault_masonry_grid.dart';
import '../media_vault/media_vault_search_sheet.dart';
import '../media_vault/media_vault_sidebar.dart';
import '../media_vault/media_vault_tags_panel.dart';
import '../media_vault/media_vault_top_bar.dart';

/// Light-tone image library — masonry browsing.
class MediaVaultPage extends StatefulWidget {
  const MediaVaultPage({super.key});

  @override
  State<MediaVaultPage> createState() => _MediaVaultPageState();
}

class _MediaVaultPageState extends State<MediaVaultPage> {
  final _repo = MediaVaultRepository.instance;

  MediaVaultSection _section = MediaVaultSection.library;
  MediaVaultCategory _category = MediaVaultCategory.all;
  String? _selectedId;
  String? _albumFilterId;
  String? _tagFilter;
  int? _columnCount;
  bool _loading = true;
  bool _uploading = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  int _resolvedColumnCount(BuildContext context) =>
      _columnCount ?? FeedGridLayout.columnsFor(context).clamp(2, 6);

  List<MediaVaultImage> get _filtered => _repo.filtered(
        section: _section,
        category: _category,
        tagFilter: _tagFilter,
        albumId: _albumFilterId,
      );

  MediaVaultImage? get _selected =>
      _selectedId != null ? _repo.imageById(_selectedId!) : null;

  List<MediaVaultImage> _relatedFor(MediaVaultImage image) {
    return _repo.images
        .where((e) => e.id != image.id && e.category == image.category)
        .take(6)
        .toList(growable: false);
  }

  bool get _showDetailPanel {
    if (!Breakpoints.isDesktop(context)) return false;
    return _selected != null && _section == MediaVaultSection.library;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _selectImage(MediaVaultImage image) {
    if (Breakpoints.isDesktop(context)) {
      setState(() => _selectedId = image.id);
    }

    final galleryItems = _repo.galleryImagesFor(_filtered);
    final galleryImage = _repo.galleryImageFor(image);
    if (galleryImage == null || !image.hasNetworkImage) {
      _showSnack('暂无可用预览地址');
      return;
    }

    final index = _repo.galleryIndexFor(galleryItems, image);
    openGalleryPreview(
      context,
      items: galleryItems,
      index: index,
      showSnack: _showSnack,
    );
  }

  Future<void> _pickAndUpload() async {
    await pickAndUploadGalleryImages(
      context,
      onUploadingChanged: (v) => setState(() => _uploading = v),
      showSnack: _showSnack,
    );
    if (mounted) setState(() {});
  }

  Future<void> _openSearch() async {
    final result = await showMediaVaultSearchSheet(context);
    if (result != null && mounted) _selectImage(result);
  }

  void _showComingSoon(String feature) {
    _showSnack('$feature — 即将推出');
  }

  @override
  Widget build(BuildContext context) {
    final isWide = Breakpoints.useSidebarShell(context);
    final quickTags = _repo.tags.map((t) => t.name).toList(growable: false);
    final columnCount = _resolvedColumnCount(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: MediaVaultColors.background,
      drawer: isWide
          ? null
          : Drawer(
              backgroundColor: MediaVaultColors.surface,
              child: MediaVaultSidebar(
                section: _section,
                onSectionChanged: (s) {
                  Navigator.pop(context);
                  setState(() {
                    _section = s;
                    _albumFilterId = null;
                    _tagFilter = null;
                  });
                },
                storageFraction: _repo.storageFraction,
                storageLabel:
                    '${_repo.storageUsedGb.toStringAsFixed(1)} GB / '
                    '${_repo.storageTotalGb.toInt()} TB',
                quickTags: quickTags,
                onTagTap: (tag) {
                  Navigator.pop(context);
                  setState(() => _tagFilter = tag);
                },
              ),
            ),
      body: Row(
        children: [
          if (isWide)
            MediaVaultSidebar(
              section: _section,
              onSectionChanged: (s) => setState(() {
                _section = s;
                _albumFilterId = null;
                _tagFilter = null;
              }),
              storageFraction: _repo.storageFraction,
              storageLabel:
                  '${_repo.storageUsedGb.toStringAsFixed(1)} GB / '
                  '${_repo.storageTotalGb.toInt()} TB',
              quickTags: quickTags,
              onTagTap: (tag) => setState(() => _tagFilter = tag),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                MediaVaultTopBar(
                  onSearch: _openSearch,
                  onFilter: () => _showComingSoon('高级筛选'),
                  onUpload: _repo.isLoggedIn ? _pickAndUpload : null,
                  uploading: _uploading,
                ),
                if (_section == MediaVaultSection.library) ...[
                  MediaVaultCategoryTabs(
                    selected: _category,
                    onChanged: (c) => setState(() => _category = c),
                  ),
                  const SizedBox(height: 4),
                ],
                if (_tagFilter != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Row(
                      children: [
                        Chip(
                          label: Text(_tagFilter!),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () => setState(() => _tagFilter = null),
                          backgroundColor: MediaVaultColors.accentGlow,
                          labelStyle: const TextStyle(
                            color: MediaVaultColors.accent,
                            fontSize: 12,
                          ),
                          side: BorderSide.none,
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildBody(columnCount)),
              ],
            ),
          ),
          if (_showDetailPanel && _selected != null)
            AnimatedSwitcher(
              duration: AppMotion.normal,
              child: MediaVaultDetailPanel(
                key: ValueKey(_selected!.id),
                image: _selected!,
                related: _relatedFor(_selected!),
                onClose: () => setState(() => _selectedId = null),
                onFavorite: () => _repo.toggleFavorite(_selected!.id),
                onRelatedTap: (img) => setState(() => _selectedId = img.id),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(int columnCount) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: MediaVaultColors.accent),
      );
    }

    if (!_repo.isLoggedIn) {
      return EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: '登录后查看图库',
        subtitle: '上传与管理你的参考图片',
        actionLabel: '去登录',
        onAction: () =>
            context.go(AppRoutes.loginWithRedirect(AppRoutes.gallery)),
      );
    }

    if (_repo.error != null && _filtered.isEmpty) {
      return EmptyStateView(
        icon: Icons.photo_library_outlined,
        title: '加载失败',
        subtitle: _repo.error,
        actionLabel: '重试',
        onAction: () {
          setState(() => _loading = true);
          _repo.refresh().then((_) {
            if (mounted) setState(() => _loading = false);
          });
        },
      );
    }

    return switch (_section) {
      MediaVaultSection.albums => MediaVaultAlbumsGrid(
          albums: _repo.albums,
          onAlbumTap: (album) => setState(() {
            _section = MediaVaultSection.library;
            _albumFilterId = album.id;
          }),
          onCreate: () => _showComingSoon('新建专辑'),
        ),
      MediaVaultSection.tags => MediaVaultTagsPanel(
          tags: _repo.tags,
          onTagTap: (tag) => setState(() {
            _section = MediaVaultSection.library;
            _tagFilter = tag;
          }),
        ),
      MediaVaultSection.trash => const EmptyStateView(
          icon: Icons.delete_outline_rounded,
          title: '回收站为空',
          subtitle: '删除的图片会在这里保留 30 天',
        ),
      MediaVaultSection.favorites ||
      MediaVaultSection.library =>
        _filtered.isEmpty
            ? EmptyStateView(
                icon: Icons.photo_library_outlined,
                title: _section == MediaVaultSection.favorites
                    ? '暂无收藏'
                    : '暂无图片',
                subtitle: '上传或导入视觉资产',
                actionLabel: '上传',
                onAction: _pickAndUpload,
              )
            : MediaVaultMasonryGrid(
                items: _filtered,
                selectedId: _selectedId,
                columnCount: columnCount,
                onColumnCountChanged: (c) =>
                    setState(() => _columnCount = c),
                onTap: _selectImage,
              ),
    };
  }
}
