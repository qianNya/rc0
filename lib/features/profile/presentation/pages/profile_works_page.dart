import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/screenplay_card.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_bar.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../../../screenplay/presentation/widgets/screenplay_visibility_sheet.dart';
import '../../../user/data/user_screenplays_repository.dart';

class ProfileWorksPage extends StatefulWidget {
  const ProfileWorksPage({super.key});

  @override
  State<ProfileWorksPage> createState() => _ProfileWorksPageState();
}

class _ProfileWorksPageState extends State<ProfileWorksPage> {
  final _local = ScreenplayLocalRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  final _auth = AuthRepository.instance;
  final _selectionController = ScreenplaySelectionController();

  int? _userId;

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
    final profile = _auth.profile;
    if (!_auth.isLoggedIn || profile == null) return;
    _userId = profile.id.toInt();
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
    final userId = _userId ?? _auth.profile?.id.toInt();
    if (userId == null) return;
    ScreenplayVisibilitySheet.show(
      context,
      screenplay: script,
      userId: userId,
    );
  }

  Widget _buildDraftGrid(List<Screenplay> drafts) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: drafts.length,
      itemBuilder: (_, i) {
        final script = drafts[i];
        return ScreenplayCard(
          screenplay: script,
          compact: true,
          onDelete: () => _deleteLocal(script),
          selectionMode: _selectionController.selectionMode,
          selected: _selectionController.isSelected(script.id),
          onSelectedToggle: () => _selectionController.toggle(script.id),
          onLongPressEnterSelection: () => _selectionController.enterSelection(
            initialLocalId: script.id,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId ?? _auth.profile?.id.toInt();
    final remote = userId != null ? _screenplays.itemsFor(userId) : <Screenplay>[];
    final loading = userId != null && _screenplays.loadingFor(userId);
    final error = userId != null ? _screenplays.errorFor(userId) : null;
    final loadingMore = userId != null && _screenplays.loadingMoreFor(userId);
    final hasMore = userId != null && _screenplays.hasMoreFor(userId);

    final drafts = _local.localScreenplays;
    final localIds = drafts.map((s) => s.id).toList(growable: false);
    final isEmpty = drafts.isEmpty && remote.isEmpty && !loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('作品库'),
        actions: [
          if (drafts.isNotEmpty)
            ScreenplaySelectionAppBarActions(
              controller: _selectionController,
              localIds: localIds,
              onSelectionChanged: _onChanged,
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: loading && isEmpty
            ? const Center(child: CircularProgressIndicator())
            : isEmpty
                ? ListView(
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      EmptyStateView(
                        icon: Icons.folder_open_outlined,
                        title: error != null ? '加载失败' : '暂无作品',
                        subtitle: error ?? '创作后会显示在这里',
                        actionLabel: error != null ? '重试' : '开始创作',
                        onAction: error != null
                            ? _load
                            : () => context.go(AppRoutes.create),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (error != null)
                        InlineErrorBanner(message: error, onRetry: _load),
                      if (remote.isNotEmpty) ...[
                        const Text(
                          '已发布',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: remote.length,
                          itemBuilder: (_, i) {
                            final script = remote[i];
                            return ScreenplayCard(
                              screenplay: script,
                              compact: true,
                              showVisibilityBadge: true,
                              onMore: () => _openVisibilitySettings(script),
                            );
                          },
                        ),
                        if (loadingMore)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                        if (hasMore && !loadingMore)
                          Center(
                            child: TextButton(
                              onPressed: _loadMore,
                              child: const Text('加载更多'),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                      if (drafts.isNotEmpty) ...[
                        const Text(
                          '本地草稿',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildDraftGrid(drafts),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
      bottomNavigationBar: ScreenplaySelectionBottomBar(
        controller: _selectionController,
        onDelete: _deleteSelected,
      ),
    );
  }
}
