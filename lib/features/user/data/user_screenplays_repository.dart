import 'package:flutter/foundation.dart';

import '../../../core/domain/screenplay/screenplay.dart';
import 'user_screenplays_fetch.dart';

class UserScreenplaysRepository extends ChangeNotifier {
  UserScreenplaysRepository._();

  static final UserScreenplaysRepository instance = UserScreenplaysRepository._();

  final Map<int, List<Screenplay>> _itemsByUser = {};
  final Map<int, bool> _loadingByUser = {};
  final Map<int, bool> _loadingMoreByUser = {};
  final Map<int, String?> _errorByUser = {};
  final Map<int, int> _pageByUser = {};
  final Map<int, int> _pageSizeByUser = {};
  final Map<int, num> _totalByUser = {};

  List<Screenplay> itemsFor(int userId) =>
      List.unmodifiable(_itemsByUser[userId] ?? const []);

  bool loadingFor(int userId) => _loadingByUser[userId] ?? false;

  bool loadingMoreFor(int userId) => _loadingMoreByUser[userId] ?? false;

  String? errorFor(int userId) => _errorByUser[userId];

  num totalFor(int userId) => _totalByUser[userId] ?? 0;

  bool hasMoreFor(int userId) =>
      itemsFor(userId).length < totalFor(userId).toInt();

  Future<void> loadFirstPage(int userId, {int pageSize = 20}) async {
    _loadingByUser[userId] = true;
    _errorByUser[userId] = null;
    _pageByUser[userId] = 1;
    _pageSizeByUser[userId] = pageSize;
    notifyListeners();

    final result = await _fetchPage(
      userId: userId,
      page: 1,
      pageSize: pageSize,
    );
    _loadingByUser[userId] = false;
    if (result.error != null) {
      _errorByUser[userId] = result.error;
    } else {
      _itemsByUser[userId] = result.items;
      _totalByUser[userId] = result.total;
      _pageByUser[userId] = 1;
      _errorByUser[userId] = null;
    }
    notifyListeners();
  }

  Future<void> loadMore(int userId) async {
    if (loadingFor(userId) || loadingMoreFor(userId) || !hasMoreFor(userId)) {
      return;
    }

    _loadingMoreByUser[userId] = true;
    notifyListeners();

    final pageSize = _pageSizeByUser[userId] ?? 20;
    final nextPage = (_pageByUser[userId] ?? 1) + 1;
    final result = await _fetchPage(
      userId: userId,
      page: nextPage,
      pageSize: pageSize,
    );
    _loadingMoreByUser[userId] = false;
    if (result.error != null) {
      _errorByUser[userId] = result.error;
    } else {
      final existing = _itemsByUser[userId] ?? [];
      _itemsByUser[userId] = [...existing, ...result.items];
      _totalByUser[userId] = result.total;
      _pageByUser[userId] = nextPage;
    }
    notifyListeners();
  }

  Future<({List<Screenplay> items, num total, String? error})> _fetchPage({
    required int userId,
    required int page,
    required int pageSize,
  }) {
    return fetchUserScreenplaysPage(
      userId: userId,
      page: page,
      pageSize: pageSize,
    );
  }

  void updateItemVisibility(int userId, int remoteId, int visibility) {
    final items = _itemsByUser[userId];
    if (items == null) return;
    final index = items.indexWhere((s) => s.remoteScreenplayId == remoteId);
    if (index < 0) return;
    final updated = [...items];
    updated[index] = updated[index].copyWith(visibility: visibility);
    _itemsByUser[userId] = updated;
    notifyListeners();
  }

  void removeItem(int userId, int remoteId) {
    final items = _itemsByUser[userId];
    if (items == null) return;
    final next = items
        .where((s) => s.remoteScreenplayId != remoteId)
        .toList(growable: false);
    if (next.length == items.length) return;
    _itemsByUser[userId] = next;
    final total = _totalByUser[userId] ?? next.length;
    _totalByUser[userId] = total > 0 ? total - 1 : 0;
    notifyListeners();
  }

  @visibleForTesting
  void debugSetItems(int userId, List<Screenplay> items) {
    _itemsByUser[userId] = items;
  }
}
