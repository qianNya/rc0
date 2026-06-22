import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/utils/image_url_utils.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../upload/data/image_pick_service.dart';
import '../../data/image_gallery_repository.dart';
import '../../domain/gallery_image.dart';
import '../widgets/gallery_image_tile.dart';

class MyGalleryPage extends StatefulWidget {
  const MyGalleryPage({super.key});

  @override
  State<MyGalleryPage> createState() => _MyGalleryPageState();
}

class _MyGalleryPageState extends State<MyGalleryPage> {
  final _auth = AuthRepository.instance;
  final _gallery = ImageGalleryRepository.instance;
  final _picker = ImagePickService();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onDataChanged);
    _gallery.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _auth.removeListener(_onDataChanged);
    _gallery.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Future<void> _load() async {
    if (!_auth.isLoggedIn) return;
    await _gallery.loadFirstPage();
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
        syncInfos: items
            .map((e) => ImagePreviewSyncInfo.uploaded(serverImageId: e.id))
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的图库')),
        body: EmptyStateView(
          icon: Icons.photo_library_outlined,
          title: '登录后查看图库',
          subtitle: '上传与管理你的参考图片',
          actionLabel: '去登录',
          onAction: () =>
              context.go(AppRoutes.loginWithRedirect(AppRoutes.library)),
        ),
      );
    }

    final isDesktop = Breakpoints.isDesktop(context);
    final items = _gallery.items;
    final loading = _gallery.loading;
    final error = _gallery.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的图库'),
        actions: [
          if (_uploading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _pickAndUpload,
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('上传图片'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(
          isDesktop: isDesktop,
          items: items,
          loading: loading,
          error: error,
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isDesktop,
    required List<GalleryImage> items,
    required bool loading,
    required String? error,
  }) {
    if (loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.5,
            child: EmptyStateView(
              icon: Icons.photo_library_outlined,
              title: '图库还是空的',
              subtitle: error ?? '点击右下角上传你的第一张图片',
              actionLabel: '上传图片',
              onAction: _pickAndUpload,
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 240 &&
            _gallery.hasMore &&
            !_gallery.loadingMore) {
          _gallery.loadMore();
        }
        return false;
      },
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(isDesktop ? 32 : 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isDesktop ? 6 : 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: items.length + (_gallery.loadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= items.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          return GalleryImageTile(
            image: items[index],
            onTap: () => _openPreview(items, index),
          );
        },
      ),
    );
  }
}
