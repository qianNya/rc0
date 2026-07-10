import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass_feed_card.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/data/screenplay_delete_options.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_bar.dart';
import '../../../screenplay/presentation/widgets/screenplay_selection_controller.dart';
import '../../../screenplay/presentation/widgets/screenplay_visibility_sheet.dart';
import '../../../user/data/user_screenplays_repository.dart';

class GalleryWorksTab extends ConsumerStatefulWidget {
  const GalleryWorksTab({super.key, this.onSelectionChanged});

  final VoidCallback? onSelectionChanged;

  @override
  ConsumerState<GalleryWorksTab> createState() => GalleryWorksTabState();
}

class GalleryWorksTabState extends ConsumerState<GalleryWorksTab>
    with AutomaticKeepAliveClientMixin {
  final _local = ScreenplayLocalRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  final _selectionController = ScreenplaySelectionController();

  int? _userId;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _local.addListener(_onChanged);
    _screenplays.addListener(_onChanged);
    _selectionController.addListener(_onChanged);
  }

  @override
  void dispose() {
    _local.removeListener(_onChanged);
    _screenplays.removeListener(_onChanged);
    _selectionController.removeListener(_onChanged);
    _selectionController.dispose();
    super.dispose();
  }

  void _onChanged() {
    scheduleSetState(this);
    widget.onSelectionChanged?.call();
  }

  ScreenplaySelectionController get selectionController => _selectionController;

  Future<void> deleteSelected() => _deleteSelected();

  Future<void> load() async {
    final session = ref.read(authSessionProvider);
    if (!session.isLoggedIn || session.profile == null) return;
    _userId = session.profile!.id.toInt();
    await _screenplays.loadFirstPage(_userId!);
  }

  Future<void> loadMore() async {
    final userId = _userId;
    if (userId == null) return;
    await _screenplays.loadMore(userId);
  }

  Future<void> _deleteLocal(Screenplay script) async {
    await confirmAndDeleteScreenplays(context, [script]);
  }

  Future<void> _deleteRemote(Screenplay script) async {
    final userId = _userId;
    if (userId == null) return;
    await confirmAndDeleteRemoteScreenplays(
      context,
      [script],
      userId: userId,
    );
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
    ScreenplayVisibilitySheet.show(
      context,
      screenplay: script,
      userId: userId,
    );
  }

  bool _canEditVisibility(Screenplay script) =>
      !script.isLocal && script.remoteScreenplayId != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userId = _userId ?? ref.read(authSessionProvider).profile?.id.toInt();
    final remote = userId != null ? _screenplays.itemsFor(userId) : <Screenplay>[];
    final loading = userId != null && _screenplays.loadingFor(userId);
    final error = userId != null ? _screenplays.errorFor(userId) : null;
    final loadingMore = userId != null && _screenplays.loadingMoreFor(userId);
    final hasMore = userId != null && _screenplays.hasMoreFor(userId);

    final drafts = _local.localScreenplays;
    final localIds = drafts.map((s) => s.id).toList(growable: false);
    final works = [...remote, ...drafts];
    final isEmpty = works.isEmpty && !loading;

    if (loading && works.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMd),
        child: FeedGridSkeleton(tileCount: 6),
      );
    }

    if (isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXl),
        child: GlassEmptyState(
          icon: Icons.folder_open_outlined,
          title: '暂无作品',
          subtitle: error ?? '创作后会显示在这里',
          actionLabel: error != null ? '重试' : '开始创作',
          onAction:
              error != null ? load : () => context.go(AppRoutes.studioCreate),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (localIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingMd,
              0,
              AppDimensions.spacingMd,
              AppDimensions.spacingSm,
            ),
            child: Align(
              alignment: Alignment.centerRight,
              child: ScreenplaySelectionAppBarActions(
                controller: _selectionController,
                localIds: localIds,
                onSelectionChanged: _onChanged,
              ),
            ),
          ),
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
              mainAxisSize: MainAxisSize.min,
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
                      ),
                      itemCount: works.length,
                      itemBuilder: (_, index) {
                        final script = works[index];
                        final isLocal = script.isLocal;
                        final canDeleteRemote =
                            !isLocal && screenplayCanDeleteRemote(script);
                        return GlassFeedCard(
                          layout: GlassFeedCardLayout.library,
                          screenplay: script,
                          onDelete: isLocal
                              ? () => _deleteLocal(script)
                              : canDeleteRemote
                                  ? () => _deleteRemote(script)
                                  : null,
                          onMore: _canEditVisibility(script)
                              ? () => _openVisibilitySettings(script)
                              : null,
                          selectionMode:
                              _selectionController.selectionMode && isLocal,
                          selected: _selectionController.isSelected(script.id),
                          onSelectedToggle: isLocal
                              ? () => _selectionController.toggle(script.id)
                              : null,
                          onLongPress: isLocal
                              ? () => _selectionController.enterSelection(
                                    initialLocalId: script.id,
                                  )
                              : null,
                        );
                      },
                    );
                  },
                ),
                if (loadingMore)
                  const Padding(
                    padding: EdgeInsets.all(AppDimensions.spacingMd),
                    child: FeedGridSkeleton(tileCount: 4),
                  ),
                if (hasMore && !loadingMore)
                  Center(
                    child: TextButton(
                      onPressed: loadMore,
                      child: const Text('加载更多'),
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
