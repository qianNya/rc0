import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../ip/data/ip_repository.dart';
import '../../../ip/presentation/widgets/ip_grid_card.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';

/// IP Wiki tab embedded in [WikiHubPage].
class WikiIpTab extends StatefulWidget {
  const WikiIpTab({super.key});

  @override
  State<WikiIpTab> createState() => _WikiIpTabState();
}

class _WikiIpTabState extends State<WikiIpTab> with AutomaticKeepAliveClientMixin {
  final _repo = IpRepository.instance;
  final _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _repo.loadFirstPage());
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  void _onScroll() {
    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 200) {
      return;
    }
    if (_repo.hasMore && !_repo.loadingMore) {
      _repo.loadMore();
    }
  }

  Future<void> _refresh() => _repo.loadFirstPage();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = _repo.items;
    final loading = _repo.loading;
    final error = _repo.error;
    final secondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    return FeedGridScope(
      child: ColoredBox(
        color: Colors.transparent,
        child: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (loading && items.isNotEmpty)
            const SliverToBoxAdapter(
              child: LinearProgressIndicator(minHeight: 2),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                wikiModeTagContentInsetHeight(context) + AppDimensions.spacingSm,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'IP 参考库',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.ipCreate),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新建 IP'),
                  ),
                ],
              ),
            ),
          ),
          if (error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                child: InlineErrorBanner(message: error, onRetry: _refresh),
              ),
            ),
          if (loading && items.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.spacingMd),
                child: FeedGridSkeleton(tileCount: 4),
              ),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: GlassEmptyState(
                icon: Icons.hub_outlined,
                title: error != null ? '加载失败' : '暂无 IP',
                subtitle: error ?? '添加动漫、游戏等 IP 作为拍摄参考',
                actionLabel: error != null ? '重试' : '新建 IP',
                onAction: error != null
                    ? _refresh
                    : () => context.push(AppRoutes.ipCreate),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                0,
                AppDimensions.spacingMd,
                AppDimensions.spacingMd,
              ),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  return SliverGrid(
                    gridDelegate: FeedGridLayout.sliverDelegate(
                      FeedGridLayout.layoutWidth(constraints.crossAxisExtent),
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= items.length) {
                          return const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        }
                        final entry = items[index];
                        return IpGridCard(
                          entry: entry,
                          onTap: () => context.push(AppRoutes.ip(entry.id)),
                        );
                      },
                      childCount: items.length + (_repo.loadingMore ? 1 : 0),
                    ),
                  );
                },
              ),
            ),
          if (items.isNotEmpty && _repo.total > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
                child: Center(
                  child: Text(
                    '共 ${_repo.total.toInt()} 个 IP',
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: ShellInsets.scrollBottom(context)),
          ),
        ],
      ),
        ),
      ),
    );
  }
}
