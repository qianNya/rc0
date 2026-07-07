import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/scene/data/scene_repository.dart';
import '../../features/scene/domain/scene_entry.dart';
import 'auth_providers.dart';
import 'repository_providers.dart';

@immutable
class SceneListState {
  const SceneListState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.total = 0,
  });

  final List<SceneEntry> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final num total;

  bool get hasMore => items.length < total.toInt();
}

/// Riverpod Notifier pilot — wraps legacy [SceneRepository].
class SceneListNotifier extends Notifier<SceneListState> {
  SceneRepository get _repo => ref.read(sceneRepositoryProvider);

  @override
  SceneListState build() {
    ref.watch(authSessionProvider);
    _repo.addListener(_syncFromRepo);
    ref.onDispose(() => _repo.removeListener(_syncFromRepo));
    return _stateFromRepo(_repo);
  }

  void _syncFromRepo() {
    state = _stateFromRepo(_repo);
  }

  SceneListState _stateFromRepo(SceneRepository repo) {
    return SceneListState(
      items: repo.items,
      loading: repo.loading,
      loadingMore: repo.loadingMore,
      error: repo.error,
      total: repo.total,
    );
  }

  Future<void> loadFirstPage() async {
    await _repo.loadFirstPage();
    _syncFromRepo();
  }

  Future<void> loadMore() async {
    await _repo.loadMore();
    _syncFromRepo();
  }
}

final sceneListNotifierProvider =
    NotifierProvider<SceneListNotifier, SceneListState>(
  SceneListNotifier.new,
);
