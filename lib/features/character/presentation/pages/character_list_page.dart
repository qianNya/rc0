import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/character_repository.dart';
import '../../domain/character_entry.dart';

class CharacterListPage extends StatefulWidget {
  const CharacterListPage({super.key, this.workId});

  final int? workId;

  @override
  State<CharacterListPage> createState() => _CharacterListPageState();
}

class _CharacterListPageState extends State<CharacterListPage> {
  final _repo = CharacterRepository.instance;
  final _auth = AuthRepository.instance;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _repo.loadMore();
    }
  }

  Future<void> _load() async {
    await _repo.loadFirstPage(
      workId: widget.workId,
      q: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_repo, _auth]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.workId != null ? 'IP 角色' : '角色库'),
            actions: [
              if (_auth.isLoggedIn)
                IconButton(
                  tooltip: '新建角色',
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    await context.push(AppRoutes.characterCreate);
                    if (mounted) _load();
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索角色名或别名',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _load();
                      },
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _load(),
                ),
              ),
              Expanded(
                child: _repo.loading && _repo.items.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : _repo.items.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.sizeOf(context).height * 0.15,
                              ),
                              EmptyStateView(
                                icon: Icons.person_outline,
                                title: _repo.error ?? '暂无角色',
                                subtitle: _repo.error != null ? null : '创建第一个角色',
                                actionLabel: _auth.isLoggedIn ? '新建角色' : null,
                                onAction: _auth.isLoggedIn
                                    ? () async {
                                        await context
                                            .push(AppRoutes.characterCreate);
                                        if (mounted) _load();
                                      }
                                    : null,
                              ),
                            ],
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppDimensions.spacingMd,
                              ),
                              itemCount: _repo.items.length +
                                  (_repo.loadingMore ? 1 : 0),
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                if (index >= _repo.items.length) {
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }
                                return _CharacterListTile(
                                  entry: _repo.items[index],
                                  onTap: () => context.push(
                                    AppRoutes.character(_repo.items[index].id),
                                  ),
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CharacterListTile extends StatelessWidget {
  const _CharacterListTile({required this.entry, required this.onTap});

  final CharacterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        side: const BorderSide(color: AppColors.border),
      ),
      leading: CircleAvatar(
        backgroundColor: AppColors.surfaceSecondary,
        child: Text(
          entry.name.isNotEmpty ? entry.name.characters.first : '?',
          style: AppTextStyles.label,
        ),
      ),
      title: Text(entry.name, style: AppTextStyles.body),
      subtitle: Text(
        [
          if (entry.displaySubtitle.isNotEmpty) entry.displaySubtitle,
          if (entry.summary.isNotEmpty) entry.summary,
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(entry.genderLabel, style: AppTextStyles.bodySecondary),
    );
  }
}
