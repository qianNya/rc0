import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_app_bar.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_bar.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../../../screenplay/presentation/widgets/screenplay_visibility_sheet.dart';
import '../../../user/data/user_screenplays_repository.dart';

enum _WorksFilter { all, published, drafts }

/// 作品库：内容优先的剧本作品网格。
///
/// Level 0 内容层（封面网格）主导视觉；Level 1 玻璃层（顶部导航 + 浮动筛选胶囊）
/// 悬浮于内容之上；筛选切换走液态动效，符合 Apple Music「资料库」的空间体验。
class ProfileWorksPage extends ConsumerStatefulWidget {
  const ProfileWorksPage({super.key});

  @override
  ConsumerState<ProfileWorksPage> createState() => _ProfileWorksPageState();
}

class _ProfileWorksPageState extends ConsumerState<ProfileWorksPage> {
  final _local = ScreenplayLocalRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  final _selectionController = ScreenplaySelectionController();

  int? _userId;
  _WorksFilter _filter = _WorksFilter.all;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
    _screenplays.addListener(_onChanged);
    _selectionController.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    _screenplays.removeListener(_onChanged);
    _selectionController.removeListener(_onChanged);
    _selectionController.dispose();
    super.dispose();
  }

  void _onChanged() => scheduleSetState(this);

  Future<void> _load() async {
    final session = ref.read(authSessionProvider);
    if (!session.isLoggedIn || session.profile == null) return;
    _userId = session.profile!.id.toInt();
    await _screenplays.loadFirstPage(_userId!);
  }

  Future<void> _loadMore() async {
    final userId = _userId;
    if (userId == null) return;
    await _screenplays.loadMore(userId);
  }

  Future<void> _deleteLocal(Screenplay script) async {
    await confirmAndDeleteScreenplays(context, [script]);
  }

  Future<void> _deleteSelected() async {
    final selected = _selectionController.selectedLocalIds.toList();
    if (selected.isEmpty) return;
    final scripts = _local.localScreenplays
        .where((s) => selected.contains(s.id))
        .toList(growable: false);
    final ok = await confirmAndDeleteScreenplays(context, scripts);
    if (ok && mounted) {
      _selectionController.exitSelection();
    }
  }

  void _openVisibilitySettings(Screenplay script) {
    final userId = _userId ?? ref.read(authSessionProvider).profile?.id.toInt();
    if (userId == null) return;
    ScreenplayVisibilitySheet.show(context, screenplay: script, userId: userId);
  }

  void _createNew() => context.go(AppRoutes.studioCreate);

  List<Screenplay> _sortedDrafts() {
    final drafts = List<Screenplay>.from(_local.localScreenplays);
    drafts.sort((a, b) {
      final aTime =
          a.updatedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime =
          b.updatedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return drafts;
  }

  List<Screenplay> _visibleWorks({
    required List<Screenplay> remote,
    required List<Screenplay> drafts,
  }) {
    switch (_filter) {
      case _WorksFilter.published:
        return remote;
      case _WorksFilter.drafts:
        return drafts;
      case _WorksFilter.all:
        return [...remote, ...drafts];
    }
  }

  void _openWork(Screenplay script) {
    if (_selectionController.selectionMode && script.isLocal) {
      _selectionController.toggle(script.id);
      return;
    }
    if (script.isLocal && !script.isPublished) {
      context.go(AppRoutes.studioEdit(script.id));
      return;
    }
    context.push(AppRoutes.script(script.detailRouteId));
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId ?? ref.read(authSessionProvider).profile?.id.toInt();
    final remote = userId != null
        ? _screenplays.itemsFor(userId)
        : <Screenplay>[];
    final loading = userId != null && _screenplays.loadingFor(userId);
    final error = userId != null ? _screenplays.errorFor(userId) : null;
    final loadingMore = userId != null && _screenplays.loadingMoreFor(userId);
    final hasMore = userId != null && _screenplays.hasMoreFor(userId);

    final drafts = _sortedDrafts();
    final localIds = drafts.map((s) => s.id).toList(growable: false);
    final visibleWorks = _visibleWorks(remote: remote, drafts: drafts);
    final isEmpty = remote.isEmpty && drafts.isEmpty && !loading;

    final filterBar = _WorksFilterTabs(
      filter: _filter,
      allCount: remote.length + drafts.length,
      publishedCount: remote.length,
      draftCount: drafts.length,
      onChanged: (value) => setState(() => _filter = value),
    );

    final grid = _WorksGrid(
      // Key by filter so AnimatedSwitcher plays a fade/slide between filters.
      key: ValueKey(_filter),
      works: visibleWorks,
      filter: _filter,
      loading: loading,
      isEmpty: isEmpty,
      error: error,
      loadingMore: loadingMore,
      hasMore: hasMore && _filter != _WorksFilter.drafts,
      selectionController: _selectionController,
      onRefresh: _load,
      onLoadMore: _loadMore,
      onRetry: _load,
      onCreate: _createNew,
      onOpen: _openWork,
      onDeleteLocal: _deleteLocal,
      onVisibility: _openVisibilitySettings,
    );

    final content = Column(
      children: [
        filterBar,
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.normal,
            switchInCurve: AppMotion.standard,
            switchOutCurve: AppMotion.standard,
            transitionBuilder: _switchTransition,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: grid,
          ),
        ),
        ScreenplaySelectionBottomBar(
          controller: _selectionController,
          onDelete: _deleteSelected,
        ),
      ],
    );

    final actions = <Widget>[
      if (drafts.isNotEmpty)
        ScreenplaySelectionAppBarActions(
          controller: _selectionController,
          localIds: localIds,
          onSelectionChanged: _onChanged,
        ),
      if (!_selectionController.selectionMode)
        IconButton(
          tooltip: '新建剧本',
          icon: const Icon(Icons.add_rounded),
          onPressed: _createNew,
        ),
      const SizedBox(width: AppDimensions.spacingXs),
    ];

    return Breakpoints.isDesktop(context)
        ? DesktopStackScaffold(
            title: const Text('作品库'),
            onBack: () => popOrGoDiscovery(context),
            actions: actions,
            body: content,
          )
        : Scaffold(
            backgroundColor: AppColors.background,
            appBar: Rc0AppBar(
              frosted: false,
              title: const Text('作品库'),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => popOrGoDiscovery(context),
              ),
              actions: actions,
            ),
            body: content,
          );
  }

  Widget _switchTransition(Widget child, Animation<double> animation) {
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.02),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// 浮动液态胶囊筛选条（全部 / 已发布 / 草稿，带计数）。
class _WorksFilterTabs extends StatelessWidget {
  const _WorksFilterTabs({
    required this.filter,
    required this.allCount,
    required this.publishedCount,
    required this.draftCount,
    required this.onChanged,
  });

  final _WorksFilter filter;
  final int allCount;
  final int publishedCount;
  final int draftCount;
  final ValueChanged<_WorksFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    const order = [
      _WorksFilter.all,
      _WorksFilter.published,
      _WorksFilter.drafts,
    ];
    final labels = ['全部 $allCount', '已发布 $publishedCount', '草稿 $draftCount'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
        AppDimensions.spacingMd,
        0,
      ),
      child: FeedTabBar(
        tabs: labels,
        selectedIndex: order.indexOf(filter),
        onChanged: (index) => onChanged(order[index]),
        embedded: true,
        underlineStyle: true,
      ),
    );
  }
}

/// 作品网格，内置 加载 / 空 / 错误 三态与分页加载。
class _WorksGrid extends StatelessWidget {
  const _WorksGrid({
    super.key,
    required this.works,
    required this.filter,
    required this.loading,
    required this.isEmpty,
    required this.error,
    required this.loadingMore,
    required this.hasMore,
    required this.selectionController,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onRetry,
    required this.onCreate,
    required this.onOpen,
    required this.onDeleteLocal,
    required this.onVisibility,
  });

  final List<Screenplay> works;
  final _WorksFilter filter;
  final bool loading;
  final bool isEmpty;
  final String? error;
  final bool loadingMore;
  final bool hasMore;
  final ScreenplaySelectionController selectionController;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLoadMore;
  final VoidCallback onRetry;
  final VoidCallback onCreate;
  final ValueChanged<Screenplay> onOpen;
  final ValueChanged<Screenplay> onDeleteLocal;
  final ValueChanged<Screenplay> onVisibility;

  @override
  Widget build(BuildContext context) {
    if (loading && works.isEmpty && error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is! ScrollEndNotification) return false;
          if (notification.metrics.extentAfter >= 280) return false;
          if (hasMore && !loadingMore) onLoadMore();
          return false;
        },
        child: FeedGridScope(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: _buildSlivers(context),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    if (isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: GlassEmptyState(
            margin: const EdgeInsets.all(AppDimensions.spacingMd),
            icon: error != null
                ? Icons.cloud_off_outlined
                : Icons.auto_stories_outlined,
            title: error != null ? '加载失败' : '还没有作品',
            subtitle: error ?? '创作完成后会显示在这里',
            actionLabel: error != null ? '重试' : '开始创作',
            onAction: error != null ? onRetry : onCreate,
          ),
        ),
      ];
    }

    if (works.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: _FilteredEmptyState(filter: filter, onCreate: onCreate),
        ),
      ];
    }

    return [
      if (error != null)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
            AppDimensions.spacingMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: InlineErrorBanner(message: error!, onRetry: onRetry),
          ),
        ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          AppDimensions.spacingMd,
          AppDimensions.spacingMd,
          AppDimensions.spacingLg,
        ),
        sliver: SliverLayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = FeedGridLayout.columnsForWidth(
              FeedGridLayout.layoutWidth(constraints.crossAxisExtent),
            );
            return SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: AppDimensions.spacingMd,
                crossAxisSpacing: AppDimensions.spacingMd,
                childAspectRatio: 0.72,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final script = works[index];
                final canEditVisibility =
                    !script.isLocal && script.remoteScreenplayId != null;
                return _WorkLibraryCard(
                  screenplay: script,
                  selectionMode:
                      selectionController.selectionMode && script.isLocal,
                  selected: selectionController.isSelected(script.id),
                  onTap: () => onOpen(script),
                  onDelete: script.isLocal ? () => onDeleteLocal(script) : null,
                  onMore: canEditVisibility ? () => onVisibility(script) : null,
                  onSelectedToggle: script.isLocal
                      ? () => selectionController.toggle(script.id)
                      : null,
                  onLongPressEnterSelection: script.isLocal
                      ? () => selectionController.enterSelection(
                          initialLocalId: script.id,
                        )
                      : null,
                );
              }, childCount: works.length),
            );
          },
        ),
      ),
      if (loadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.spacingMd),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ),
      const SliverToBoxAdapter(child: ShellBottomSpacer(extra: 24)),
    ];
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState({required this.filter, required this.onCreate});

  final _WorksFilter filter;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final (title, subtitle) = switch (filter) {
      _WorksFilter.published => ('暂无已发布作品', '发布后的剧本会出现在这里'),
      _WorksFilter.drafts => ('暂无草稿', '保存的草稿会出现在这里'),
      _WorksFilter.all => ('暂无匹配作品', '创建新的作品后会显示在这里'),
    };
    return GlassEmptyState(
      icon: Icons.filter_alt_off_outlined,
      title: title,
      subtitle: subtitle,
      actionLabel: '新建剧本',
      onAction: onCreate,
    );
  }
}

/// 单个作品卡：封面占满（内容层），底部玻璃信息区（控制层弱化）。
class _WorkLibraryCard extends StatelessWidget {
  const _WorkLibraryCard({
    required this.screenplay,
    required this.onTap,
    this.onDelete,
    this.onMore,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedToggle,
    this.onLongPressEnterSelection,
  });

  final Screenplay screenplay;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPressEnterSelection;

  String get _title =>
      screenplay.title.trim().isEmpty ? '未命名剧本' : screenplay.title.trim();

  @override
  Widget build(BuildContext context) {
    final badgeLabel = screenplay.isLocal
        ? '草稿'
        : screenplay.visibility == 0
        ? '非公开'
        : '公开';

    return GlassCard(
      padding: EdgeInsets.zero,
      selected: selected,
      onTap: selectionMode ? onSelectedToggle : onTap,
      onLongPress: selectionMode
          ? onSelectedToggle
          : onLongPressEnterSelection ?? onDelete,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PoseCoverImage(
                  imagePath: screenplay.effectiveCoverImagePath,
                  expand: true,
                  borderRadius: AppDimensions.radiusXl,
                ),
                const Positioned.fill(child: _CoverScrim()),
                Positioned(
                  top: AppDimensions.spacingSm,
                  right: AppDimensions.spacingSm,
                  child: _VisibilityBadge(label: badgeLabel),
                ),
                if (selectionMode)
                  Positioned(
                    top: AppDimensions.spacingSm,
                    left: AppDimensions.spacingSm,
                    child: AnimatedScale(
                      duration: AppMotion.fast,
                      scale: selected ? 1 : 0.9,
                      child: Checkbox(
                        value: selected,
                        onChanged: (_) => onSelectedToggle?.call(),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                Positioned(
                  left: AppDimensions.spacingSm,
                  right: AppDimensions.spacingSm,
                  bottom: AppDimensions.spacingSm,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.movie_creation_outlined,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppDimensions.spacingXs),
                      Expanded(
                        child: Text(
                          screenplay.hierarchySummary,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingSm + 2,
              AppDimensions.spacingSm + 2,
              AppDimensions.spacingSm,
              AppDimensions.spacingSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppTextStyles.label.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      screenplay.likes.toString(),
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                    const SizedBox(width: AppDimensions.spacingSm),
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 15,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      screenplay.views.toString(),
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed:
                          onMore ??
                          (onDelete == null
                              ? null
                              : () => _showDraftMenu(context)),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 28,
                      ),
                      icon: const Icon(Icons.more_horiz, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDraftMenu(BuildContext context) async {
    final action = await showGlassSheet<String>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassListRow(
            leading: const Icon(Icons.edit_outlined),
            title: '继续编辑',
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          GlassListRow(
            leading: const Icon(Icons.delete_outline),
            iconColor: AppColors.error,
            title: '删除',
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    if (action == 'edit') {
      onTap();
    } else if (action == 'delete') {
      onDelete?.call();
    }
  }
}

class _CoverScrim extends StatelessWidget {
  const _CoverScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x00000000), Color(0x8A000000)],
          stops: [0, 0.56, 1],
        ),
      ),
    );
  }
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
