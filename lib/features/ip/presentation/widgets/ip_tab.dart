import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../data/ip_repository.dart';
import 'ip_grid_card.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';

class IpTab extends StatefulWidget {
  const IpTab({super.key});

  @override
  State<IpTab> createState() => IpTabState();
}

class IpTabState extends State<IpTab> with AutomaticKeepAliveClientMixin {
  final _repo = IpRepository.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  Future<void> load() async {
    await _repo.loadFirstPage();
  }

  Future<void> loadMore() async {
    await _repo.loadMore();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = _repo.items;
    final loading = _repo.loading;
    final error = _repo.error;
    final secondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;

    if (loading && items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: FeedGridSkeleton(tileCount: 4),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loading && items.isNotEmpty)
          const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            0,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => context.push(AppRoutes.ipCreate),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('新建 IP'),
            ),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: GlassEmptyState(
              icon: Icons.hub_outlined,
              title: error != null ? '加载失败' : '暂无 IP',
              subtitle: error ?? '添加动漫、游戏等 IP 作为参考元数据',
              actionLabel: error != null ? '重试' : '新建 IP',
              onAction: error != null
                  ? load
                  : () => context.push(AppRoutes.ipCreate),
            ),
          )
        else
          FeedGridScope(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
                AppDimensions.spacingMd,
                AppDimensions.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null)
                    InlineErrorBanner(message: error, onRetry: load),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: FeedGridLayout.boxDelegate(
                          constraints.maxWidth,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: items.length + (_repo.loadingMore ? 1 : 0),
                        itemBuilder: (_, index) {
                          if (index >= items.length) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(AppDimensions.spacingMd),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            );
                          }
                          final entry = items[index];
                          return IpGridCard(
                            entry: entry,
                            onTap: () => context.push(AppRoutes.ip(entry.id)),
                          );
                        },
                      );
                    },
                  ),
                if (_repo.total > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: AppDimensions.spacingMd),
                    child: Center(
                      child: Text(
                        '共 ${_repo.total.toInt()} 个 IP',
                        style: TextStyle(fontSize: 13, color: secondary),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
      ],
    );
  }
}
