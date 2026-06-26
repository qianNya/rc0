import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/network/api_auth.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/content_card_shared.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../widgets/explore_feed_grid_card.dart';

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
      ),
    ),
    if (remoteLoadingMore)
      const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
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
    return EmptyStateView(
      icon: Icons.movie_creation_outlined,
      title: '还没有内容',
      subtitle: '上传参考图，按「剧本 → 幕 → 场 → 画」组织你的分镜',
      actionLabel: '去创作',
      onAction: onUpload,
    );
  }

  if (isUnauthorizedError(remoteError)) {
    return EmptyStateView(
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
    return EmptyStateView(
      icon: Icons.build_circle_outlined,
      title: '系统维护中',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isNetworkError(remoteError)) {
    return EmptyStateView(
      icon: Icons.wifi_off_outlined,
      title: '网络不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  if (isServerError(remoteError)) {
    return EmptyStateView(
      icon: Icons.cloud_off_outlined,
      title: '服务暂时不可用',
      subtitle: remoteError,
      actionLabel: '重试',
      onAction: () => onRefreshRemote(),
    );
  }

  return EmptyStateView(
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
}) {
  if (remoteLoading && feedItems.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(child: CircularProgressIndicator()),
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

  final columns =
      crossAxisCount ?? Breakpoints.gridColumns(context, mobile: 2, desktop: 4);
  final aspectRatio = feedGridChildAspectRatio(columns);

  return Column(
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
        padding: EdgeInsets.fromLTRB(16, 8, 16, bottomPadding),
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
          return ExploreFeedGridCard(
            screenplay: item,
            onDelete: isLocal ? () => onDelete(item) : null,
            selectionMode: selectionController.selectionMode && isLocal,
            selected: selectionController.isSelected(item.id),
            onSelectedToggle:
                isLocal ? () => selectionController.toggle(item.id) : null,
            onLongPressEnterSelection: isLocal
                ? () =>
                    selectionController.enterSelection(initialLocalId: item.id)
                : null,
          );
        },
      ),
    ],
  );
}
