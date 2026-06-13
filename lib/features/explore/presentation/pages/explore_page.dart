import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/screenplay_card.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final _repository = ScreenplayLocalRepository.instance;
  String _selectedTag = '全部';

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  List<Screenplay> get _allScripts => _repository.localScreenplays;

  List<String> get _tagFilters => buildTagFilters(_allScripts);

  List<Screenplay> get _displayScripts {
    if (!_tagFilters.contains(_selectedTag)) {
      _selectedTag = '全部';
    }
    return filterScreenplaysByTag(_allScripts, _selectedTag);
  }

  Future<void> _deleteScript(Screenplay script) async {
    final confirmed = await confirmDeleteScreenplay(
      context,
      title: script.title,
    );
    if (!confirmed || !mounted) return;

    await _repository.delete(script.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('剧本已删除')));
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _ExploreMobileView(
        scripts: _displayScripts,
        tagFilters: _tagFilters,
        selectedTag: _selectedTag,
        onTagChanged: (tag) => setState(() => _selectedTag = tag),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
      desktop: (_) => _ExploreDesktopView(
        scripts: _displayScripts,
        tagFilters: _tagFilters,
        selectedTag: _selectedTag,
        onTagChanged: (tag) => setState(() => _selectedTag = tag),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
    );
  }
}

class _ExploreMobileView extends StatelessWidget {
  const _ExploreMobileView({
    required this.scripts,
    required this.tagFilters,
    required this.selectedTag,
    required this.onTagChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final List<Screenplay> scripts;
  final List<String> tagFilters;
  final String selectedTag;
  final ValueChanged<String> onTagChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

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
                    hint: '搜索剧本、标签',
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
          if (tagFilters.length > 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tagFilters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final tag = tagFilters[index];
                  return TagChip(
                    label: tag,
                    selected: selectedTag == tag,
                    onTap: () => onTagChanged(tag),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              '共 ${scripts.length} 部剧本',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: scripts.isEmpty
                ? EmptyStateView(
                    icon: Icons.movie_creation_outlined,
                    title: '还没有剧本',
                    subtitle: '上传参考图，按「剧本 → 幕 → 场 → 画」组织你的分镜',
                    actionLabel: '去上传',
                    onAction: onUpload,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.68,
                    ),
                    itemCount: scripts.length,
                    itemBuilder: (context, index) {
                      final script = scripts[index];
                      return ScreenplayCard(
                        screenplay: script,
                        compact: true,
                        onDelete: () => onDelete(script),
                      );
                    },
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
    required this.onTagChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final List<Screenplay> scripts;
  final List<String> tagFilters;
  final String selectedTag;
  final ValueChanged<String> onTagChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tagFilters.length > 1)
            _DesktopFilterPanel(
              tags: tagFilters,
              selected: selectedTag,
              onChanged: onTagChanged,
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 32, 32),
              child: AdaptiveContent(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppSearchField(
                            hint: '搜索剧本、标签…',
                            onTap: () {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: onUpload,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('上传剧本'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SectionHeader(title: '我的剧本'),
                    const SizedBox(height: 4),
                    Text(
                      '共 ${scripts.length} 部本地剧本',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (scripts.isEmpty)
                      EmptyStateView(
                        icon: Icons.movie_creation_outlined,
                        title: '还没有剧本',
                        subtitle: '点击右上角上传，创建你的第一部剧本',
                        actionLabel: '上传剧本',
                        onAction: onUpload,
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              Breakpoints.gridColumns(context, desktop: 3),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: scripts.length,
                        itemBuilder: (context, index) {
                          final script = scripts[index];
                          return ScreenplayCard(
                            screenplay: script,
                            compact: true,
                            onDelete: () => onDelete(script),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopFilterPanel extends StatelessWidget {
  const _DesktopFilterPanel({
    required this.tags,
    required this.selected,
    required this.onChanged,
  });

  final List<String> tags;
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(16, 24, 8, 24),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '标签筛选',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tag in tags)
                TagChip(
                  label: tag,
                  selected: selected == tag,
                  onTap: () => onChanged(tag),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
