import 'package:flutter/foundation.dart';

import '../../../api/image/api/image-api.dart' as image_api;
import '../../../api/work/api/work-api.dart' as work_api;
import '../../../api/work/data/work-api.dart';
import '../../../core/network/api_callback.dart';
import '../../../core/auth/auth_bridge.dart';
import '../domain/ip_entry.dart';

class IpRepository extends ChangeNotifier {
  IpRepository._();

  static final IpRepository instance = IpRepository._();

  final List<IpEntry> _items = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  int _pageSize = 20;
  num _total = 0;

  List<IpEntry> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  String? get error => _error;
  num get total => _total;
  bool get hasMore => _items.length < _total.toInt();

  Future<void> initialize() async {
    AuthBridge.addListener(_onAuthChanged);
  }

  void _onAuthChanged() {
    if (!AuthBridge.isLoggedIn) {
      // IP list is public; only clear on logout if needed for user-owned data later.
    }
  }

  IpEntry _fromDto(WorkItem dto) {
    return IpEntry(
      id: dto.id.toInt(),
      title: dto.title,
      workType: dto.workType.toInt(),
      releaseYear: dto.releaseYear.toInt(),
      summary: dto.summary,
    );
  }

  WorkWriteBody _toBody({
    required String title,
    required int workType,
    required int releaseYear,
    required String summary,
  }) {
    return WorkWriteBody(
      title: title,
      workType: workType,
      releaseYear: releaseYear,
      summary: summary,
    );
  }

  Future<void> loadFirstPage({int pageSize = 20}) async {
    _loading = true;
    _error = null;
    _page = 1;
    _pageSize = pageSize;
    notifyListeners();

    final result = await _fetchPage(page: 1, pageSize: pageSize);
    _loading = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items
        ..clear()
        ..addAll(result.items);
      _total = result.total;
      _page = 1;
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !hasMore) return;

    _loadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final result = await _fetchPage(page: nextPage, pageSize: _pageSize);
    _loadingMore = false;
    if (result.error != null) {
      _error = result.error;
    } else {
      _items.addAll(result.items);
      _total = result.total;
      _page = nextPage;
    }
    notifyListeners();
  }

  Future<({IpEntry? ip, String? error})> fetchDetail(int id) async {
    final (resp, error) = await apiCallback<WorkItem>(
      ({ok, fail, eventually}) => work_api.getWork(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    if (error != null) return (ip: null, error: error);
    if (resp == null) return (ip: null, error: 'IP 不存在');
    return (ip: _fromDto(resp), error: null);
  }

  Future<({IpEntry? ip, String? error})> create({
    required String title,
    required int workType,
    required int releaseYear,
    required String summary,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (ip: null, error: '请先登录');
    }

    final (resp, error) = await apiCallback<WorkItem>(
      ({ok, fail, eventually}) => work_api.createWork(
        body: _toBody(
          title: title,
          workType: workType,
          releaseYear: releaseYear,
          summary: summary,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (ip: null, error: error);
    if (resp == null) return (ip: null, error: '创建失败');

    final entry = _fromDto(resp);
    _items.insert(0, entry);
    _total = _total + 1;
    notifyListeners();
    return (ip: entry, error: null);
  }

  Future<({IpEntry? ip, String? error})> update({
    required int id,
    required String title,
    required int workType,
    required int releaseYear,
    required String summary,
  }) async {
    if (!AuthBridge.isLoggedIn) {
      return (ip: null, error: '请先登录');
    }

    final (resp, error) = await apiCallback<WorkItem>(
      ({ok, fail, eventually}) => work_api.updateWork(
        id,
        body: _toBody(
          title: title,
          workType: workType,
          releaseYear: releaseYear,
          summary: summary,
        ),
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return (ip: null, error: error);
    if (resp == null) return (ip: null, error: '更新失败');

    final entry = _fromDto(resp);
    final index = _items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      _items[index] = entry;
      notifyListeners();
    }
    return (ip: entry, error: null);
  }

  Future<String?> delete(int id) async {
    if (!AuthBridge.isLoggedIn) {
      return '请先登录';
    }

    final (_, error) = await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => work_api.deleteWork(
        id,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) return error;

    _items.removeWhere((e) => e.id == id);
    _total = (_total - 1).clamp(0, double.infinity);
    notifyListeners();
    return null;
  }

  Future<({List<IpEntry> items, num total, String? error})> _fetchPage({
    required int page,
    required int pageSize,
  }) async {
    final (resp, error) = await apiCallback<ListWorksResp>(
      ({ok, fail, eventually}) => work_api.listWorks(
        page: page,
        pageSize: pageSize,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    if (error != null) {
      return (items: <IpEntry>[], total: 0, error: error);
    }

    final items = (resp?.list ?? []).map(_fromDto).toList();
    return (items: items, total: resp?.total ?? 0, error: null);
  }

  Future<String?> linkToImage({
    required int imageId,
    required int workId,
  }) async {
    final (_, error) = await apiCallback<Map<String, dynamic>>(
      ({ok, fail, eventually}) => image_api.linkImageWork(
        imageId,
        workId: workId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );
    return error;
  }
}
