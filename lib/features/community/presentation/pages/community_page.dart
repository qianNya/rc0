import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../api/http/api_auth_error.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/screenplay_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final _repository = ScreenplayRemoteRepository.instance;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
    _repository.loadFirstPage();
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Future<void> _refresh() => _repository.loadFirstPage();

  @override
  Widget build(BuildContext context) {
    final scripts = _repository.screenplays;
    final loading = _repository.loading;
    final error = _repository.error;

    return ResponsiveBuilder(
      mobile: (_) => _CommunityMobileView(
        scripts: scripts,
        loading: loading,
        error: error,
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
        onRefresh: _refresh,
      ),
      desktop: (_) => _CommunityDesktopView(
        scripts: scripts,
        loading: loading,
        error: error,
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
        onRefresh: _refresh,
      ),
    );
  }
}

class _CommunityMobileView extends StatelessWidget {
  const _CommunityMobileView({
    required this.scripts,
    required this.loading,
    required this.error,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onRefresh,
  });

  final List<Screenplay> scripts;
  final bool loading;
  final String? error;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      hint: '搜索模板、标签',
                      onTap: () {},
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            FeedTabBar(
              tabs: AppCatalog.marketTabs,
              selectedIndex: selectedTab,
              onChanged: onTabChanged,
            ),
            const SizedBox(height: 12),
            const FeaturedBanner(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < AppCatalog.marketQuickActions.length; i++)
                    QuickActionCircle(
                      label: AppCatalog.marketQuickActions[i],
                      icon: [
                        Icons.grid_view,
                        Icons.local_fire_department_outlined,
                        Icons.schedule,
                        Icons.card_giftcard_outlined,
                      ][i],
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('热门模板', style: AppTextStyles.label),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (loading && scripts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && scripts.isEmpty) {
      final needsLogin = !AuthRepository.instance.isLoggedIn ||
          isUnauthorizedError(error);
      if (needsLogin) {
        return EmptyStateView(
          icon: Icons.lock_outline,
          title: '请先登录',
          subtitle: '登录后查看社区内容',
          actionLabel: '去登录',
          onAction: () => context.go(
            AppRoutes.loginWithRedirect(AppRoutes.community),
          ),
        );
      }
      return EmptyStateView(
        icon: Icons.cloud_off_outlined,
        title: '加载失败',
        subtitle: error,
        actionLabel: '重试',
        onAction: () => onRefresh(),
      );
    }
    if (scripts.isEmpty) {
      return const EmptyStateView(
        icon: Icons.storefront_outlined,
        title: '暂无模板',
        subtitle: '稍后再来看看',
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: scripts.length,
        itemBuilder: (_, index) {
          final script = scripts[index];
          return ScreenplayCard(
            screenplay: script,
            compact: true,
            showBadge: index == 0
                ? ContentBadgeType.hot
                : index == 1
                    ? ContentBadgeType.now
                    : null,
          );
        },
      ),
    );
  }
}

class _CommunityDesktopView extends StatelessWidget {
  const _CommunityDesktopView({
    required this.scripts,
    required this.loading,
    required this.error,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onRefresh,
  });

  final List<Screenplay> scripts;
  final bool loading;
  final String? error;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('模板市场', style: AppTextStyles.display),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(hint: '搜索模板…', onTap: () {}),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FeedTabBar(
                tabs: AppCatalog.marketTabs,
                selectedIndex: selectedTab,
                onChanged: onTabChanged,
                underlineStyle: true,
              ),
              const SizedBox(height: 20),
              const FeaturedBanner(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < AppCatalog.marketQuickActions.length; i++)
                    QuickActionCircle(
                      label: AppCatalog.marketQuickActions[i],
                      icon: [
                        Icons.grid_view,
                        Icons.local_fire_department_outlined,
                        Icons.schedule,
                        Icons.card_giftcard_outlined,
                      ][i],
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const Text('热门模板', style: AppTextStyles.label),
              const SizedBox(height: 16),
              if (loading && scripts.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(48),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (error != null && scripts.isEmpty)
                Builder(
                  builder: (context) {
                    final needsLogin = !AuthRepository.instance.isLoggedIn ||
                        isUnauthorizedError(error);
                    if (needsLogin) {
                      return EmptyStateView(
                        icon: Icons.lock_outline,
                        title: '请先登录',
                        subtitle: '登录后查看社区内容',
                        actionLabel: '去登录',
                        onAction: () => context.go(
                          AppRoutes.loginWithRedirect(AppRoutes.community),
                        ),
                      );
                    }
                    return EmptyStateView(
                      icon: Icons.cloud_off_outlined,
                      title: '加载失败',
                      subtitle: error,
                      actionLabel: '重试',
                      onAction: () => onRefresh(),
                    );
                  },
                )
              else if (scripts.isEmpty)
                const EmptyStateView(
                  icon: Icons.storefront_outlined,
                  title: '暂无模板',
                  subtitle: '稍后再来看看',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: Breakpoints.gridColumns(context, desktop: 4),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: scripts.length,
                  itemBuilder: (_, index) {
                    final script = scripts[index];
                    return ScreenplayCard(
                      screenplay: script,
                      compact: true,
                      showBadge: index == 0
                          ? ContentBadgeType.hot
                          : index == 1
                              ? ContentBadgeType.now
                              : null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
