import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_adapter.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_remote_repository.dart';
import '../../../screenplay/data/screenplay_display.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/explore_feed_tile.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/screenplay_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _localRepository = ScreenplayLocalRepository.instance;
  final _remoteRepository = ScreenplayRemoteRepository.instance;
  String _selectedTag = '全部';
  int _feedTabIndex = 0;
  bool _forking = false;
  String? _forkingId;

  @override
  void initState() {
    super.initState();
    _localRepository.addListener(_onDataChanged);
    _remoteRepository.addListener(_onDataChanged);
    _remoteRepository.loadFirstPage();
  }

  @override
  void dispose() {
    _localRepository.removeListener(_onDataChanged);
    _remoteRepository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  List<Screenplay> get _allScripts => _localRepository.localScreenplays;

  List<Screenplay> get _remoteTemplates => _remoteRepository.screenplays;

  List<Screenplay> get _feedItems {
    final local = filterScreenplaysByTag(_allScripts, _selectedTag);
    final remote = _remoteTemplates;
    return [...local, ...remote];
  }

  List<String> get _tagFilters => buildTagFilters(_allScripts);

  List<Screenplay> get _displayScripts {
    if (!_tagFilters.contains(_selectedTag)) {
      _selectedTag = '全部';
    }
    return _feedItems;
  }

  Future<void> _forkTemplate(Screenplay script) async {
    if (_forking) return;
    setState(() {
      _forking = true;
      _forkingId = script.id;
    });

    final result = await _localRepository.fork(script);
    if (!mounted) return;
    setState(() {
      _forking = false;
      _forkingId = null;
    });

    if (result.screenplay == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(result.error ?? 'Fork 失败')),
        );
      return;
    }

    context.go(AppRoutes.script(result.screenplay!.id));
  }

  Future<void> _deleteScript(Screenplay script) async {
    final confirmed = await confirmDeleteScreenplay(
      context,
      title: script.title,
    );
    if (!confirmed || !mounted) return;

    final result = await _localRepository.deleteScreenplay(script.id);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('剧本已删除')));
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(result.error ?? '删除失败，请重试')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _ExploreMobileView(
        feedItems: _displayScripts,
        suggestions: _allScripts.take(8).toList(),
        feedTabIndex: _feedTabIndex,
        remoteLoading: _remoteRepository.loading,
        forking: _forking,
        forkingId: _forkingId,
        onFeedTabChanged: (i) => setState(() => _feedTabIndex = i),
        onDelete: _deleteScript,
        onFork: _forkTemplate,
        onUpload: () => context.go(AppRoutes.upload),
        onRefreshRemote: () => _remoteRepository.loadFirstPage(),
      ),
      desktop: (_) => _ExploreDesktopView(
        scripts: _displayScripts,
        tagFilters: _tagFilters,
        selectedTag: _selectedTag,
        feedTabIndex: _feedTabIndex,
        onFeedTabChanged: (i) => setState(() => _feedTabIndex = i),
        onTagChanged: (tag) => setState(() => _selectedTag = tag),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
    );
  }
}

class _ExploreMobileView extends StatelessWidget {
  const _ExploreMobileView({
    required this.feedItems,
    required this.suggestions,
    required this.feedTabIndex,
    required this.remoteLoading,
    required this.forking,
    required this.forkingId,
    required this.onFeedTabChanged,
    required this.onDelete,
    required this.onFork,
    required this.onUpload,
    required this.onRefreshRemote,
  });

  final List<Screenplay> feedItems;
  final List<Screenplay> suggestions;
  final int feedTabIndex;
  final bool remoteLoading;
  final bool forking;
  final String? forkingId;
  final ValueChanged<int> onFeedTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final Future<void> Function(Screenplay) onFork;
  final VoidCallback onUpload;
  final Future<void> Function() onRefreshRemote;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              12 + MediaQuery.paddingOf(context).top,
              16,
              8,
            ),
            child: Row(
              children: [
                const Rc0Logo(),
                const SizedBox(width: 12),
                Expanded(
                  child: AppSearchField(
                    hint: '搜索剧本、模板、标签',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  color: AppColors.textPrimary,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          DefaultFeedTabBar(
            selectedIndex: feedTabIndex,
            onChanged: onFeedTabChanged,
            underlineStyle: true,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: feedItems.isEmpty && !remoteLoading
                ? EmptyStateView(
                    icon: Icons.movie_creation_outlined,
                    title: '还没有内容',
                    subtitle: '上传参考图，按「剧本 → 幕 → 场 → 画」组织你的分镜',
                    actionLabel: '去创作',
                    onAction: onUpload,
                  )
                : RefreshIndicator(
                    onRefresh: onRefreshRemote,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        if (remoteLoading && feedItems.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        for (final item in feedItems)
                          ExploreFeedTile(
                            screenplay: item,
                            onDelete: item.isLocal
                                ? () => onDelete(item)
                                : null,
                            onFork: item.exploreFeedType ==
                                    ExploreFeedType.template
                                ? () => onFork(item)
                                : null,
                            forkLoading:
                                forking && forkingId == item.id,
                          ),
                        if (suggestions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  '你可能喜欢',
                                  style: AppTextStyles.label,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text('查看更多'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 88,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: suggestions.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, index) {
                                final script = suggestions[index];
                                return GestureDetector(
                                  onTap: () => context.push(
                                    AppRoutes.script(script.detailRouteId),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radiusSm,
                                    ),
                                    child: SizedBox(
                                      width: 88,
                                      child: PoseCoverImage(
                                        imagePath: script.effectiveCoverImagePath,
                                        aspectRatio: 1,
                                        iconSize: 24,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ExploreDesktopView extends StatelessWidget {
  const _ExploreDesktopView({
    required this.scripts,
    required this.tagFilters,
    required this.selectedTag,
    required this.feedTabIndex,
    required this.onFeedTabChanged,
    required this.onTagChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final List<Screenplay> scripts;
  final List<String> tagFilters;
  final String selectedTag;
  final int feedTabIndex;
  final ValueChanged<int> onFeedTabChanged;
  final ValueChanged<String> onTagChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final featured = scripts.take(3).toList();
    final rest = scripts.length > 3 ? scripts.sublist(3) : <Screenplay>[];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 32, 32),
        child: AdaptiveContent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('探索', style: AppTextStyles.display),
                  const Spacer(),
                  if (tagFilters.length > 1)
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final tag in tagFilters.take(6))
                          TagChip(
                            label: tag,
                            selected: selectedTag == tag,
                            onTap: () => onTagChanged(tag),
                          ),
                      ],
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('创作'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FeedTabBar(
                tabs: AppCatalog.feedTabs,
                selectedIndex: feedTabIndex,
                onChanged: onFeedTabChanged,
                underlineStyle: true,
              ),
              const SizedBox(height: 24),
              if (scripts.isEmpty)
                EmptyStateView(
                  icon: Icons.movie_creation_outlined,
                  title: '还没有剧本',
                  subtitle: '点击右上角创作，创建你的第一部剧本',
                  actionLabel: '去创作',
                  onAction: onUpload,
                )
              else ...[
                if (featured.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: featured.length,
                    itemBuilder: (_, index) => ScreenplayCard(
                      screenplay: featured[index],
                      onDelete: () => onDelete(featured[index]),
                    ),
                  ),
                if (rest.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const SectionHeader(title: '更多推荐'),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          Breakpoints.gridColumns(context, desktop: 4),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: rest.length,
                    itemBuilder: (_, index) {
                      final script = rest[index];
                      return ScreenplayCard(
                        screenplay: script,
                        compact: true,
                        onDelete: () => onDelete(script),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 24),
                const Text('常用电影画幅比', style: AppTextStyles.label),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final ratio in AppCatalog.aspectRatioPresets)
                      TagChip(label: ratio, selected: false, onTap: () {}),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
