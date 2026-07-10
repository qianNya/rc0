import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass_feed_card.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';

List<Widget> buildDiscoverySlivers({
  required BuildContext context,
  required List<Screenplay> feedItems,
  required bool remoteLoading,
  required String? remoteError,
  required bool remoteLoadingMore,
  required Future<void> Function(Screenplay) onDelete,
  required VoidCallback onUpload,
  required Future<void> Function() onRefreshRemote,
  required ScreenplaySelectionController selectionController,
  bool overlayMetrics = false,
}) {
  return [
    SliverToBoxAdapter(
      child: buildDiscoveryFeedBody(
        context: context,
        feedItems: feedItems,
        remoteLoading: remoteLoading,
        remoteError: remoteError,
        remoteLoadingMore: remoteLoadingMore,
        onDelete: onDelete,
        onUpload: onUpload,
        onRefreshRemote: onRefreshRemote,
        bottomPadding: 24,
        selectionController: selectionController,
        overlayMetrics: overlayMetrics,
      ),
    ),
    if (remoteLoadingMore)
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.spacingMd),
          child: FeedGridSkeleton(tileCount: 4),
        ),
      ),
  ];
}

Widget buildRemoteEmptyState({
  required BuildContext context,
  required String? remoteError,
  required Future<void> Function() onRefreshRemote,
  required VoidCallback onUpload,
}) {
  if (remoteError == null) {
    return GlassEmptyState(
      icon: Icons.movie_creation_outlined,
      title: '还没有内容',
      subtitle: '上传参考图，按「剧本 → 幕 → 场 → 画」组织你的分镜',
      actionLabel: '去创作',
      onAction: onUpload,
    );
  }

  if (isUnauthorizedError(remoteError)) {
    return GlassEmptyState(
      icon: Icons.lock_outline,
      title: '登录已过期',
      subtitle: '请重新登录后查看云端内容',
      actionLabel: '去登录',
      onAction: () => context.go(
        AppRoutes.loginWithRedirect(AppRoutes.discovery),
      ),
    );
  }

  if (isMaintenanceError(remoteError)) {
    return GlassEmptyState(
      icon: Icons.build_circle_outlined,
      title: '系统维护中',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isNetworkError(remoteError)) {
    return GlassEmptyState(
      icon: Icons.wifi_off_outlined,
      title: '网络不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isServerError(remoteError)) {
    return GlassEmptyState(
      icon: Icons.cloud_off_outlined,
      title: '服务暂时不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  return GlassEmptyState(
    icon: Icons.cloud_off_outlined,
    title: '加载失败',
    subtitle: remoteError,
    actionLabel: '重试',
    onAction: () => onRefreshRemote(),
  );
}

Widget buildDiscoveryFeedBody({
  required BuildContext context,
  required List<Screenplay> feedItems,
  required bool remoteLoading,
  required String? remoteError,
  required bool remoteLoadingMore,
  required Future<void> Function(Screenplay) onDelete,
  required VoidCallback onUpload,
  required Future<void> Function() onRefreshRemote,
  required ScreenplaySelectionController selectionController,
  double bottomPadding = 32,
  double gridSpacing = 12,
  int? crossAxisCount,
  bool overlayMetrics = false,
}) {
  if (remoteLoading && feedItems.isEmpty) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
      child: FeedGridSkeleton(),
    );
  }

  if (feedItems.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: buildRemoteEmptyState(
        context: context,
        remoteError: remoteError,
        onRefreshRemote: onRefreshRemote,
        onUpload: onUpload,
      ),
    );
  }

  final columns = crossAxisCount ??
      FeedGridLayout.columnsForWidth(MediaQuery.sizeOf(context).width);
  final aspectRatio =
      feedGridChildAspectRatio(columns, overlayMetrics: overlayMetrics);

  return FeedGridScope(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (remoteError != null && !isUnauthorizedError(remoteError))
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: InlineErrorBanner(
              message: remoteError,
              onRetry: () => onRefreshRemote(),
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: FeedGridLayout.padding(bottom: bottomPadding),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: gridSpacing,
            crossAxisSpacing: gridSpacing,
            childAspectRatio: aspectRatio,
          ),
        itemCount: feedItems.length,
        itemBuilder: (_, index) {
          final item = feedItems[index];
          final isLocal = item.isLocal;
          return GlassFeedCard(
            screenplay: item,
            layout: overlayMetrics
                ? GlassFeedCardLayout.overlay
                : GlassFeedCardLayout.library,
            onDelete: isLocal ? () => onDelete(item) : null,
            selectionMode: selectionController.selectionMode && isLocal,
            selected: selectionController.isSelected(item.id),
            onSelectedToggle:
                isLocal ? () => selectionController.toggle(item.id) : null,
            onLongPress: isLocal
                ? () =>
                    selectionController.enterSelection(initialLocalId: item.id)
                : null,
          );
        },
      ),
    ],
    ),
  );
}
