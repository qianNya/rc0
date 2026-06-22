import 'package:flutter/foundation.dart';

import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';

class ScreenplayLikeRepository extends ChangeNotifier {
  ScreenplayLikeRepository._();

  static final ScreenplayLikeRepository instance = ScreenplayLikeRepository._();

  List<SpLike> _items = [];
  int _total = 0;
  bool _loading = false;

  List<SpLike> get items => List.unmodifiable(_items);
  int get total => _total;
  bool get loading => _loading;

  Future<({List<SpLike> items, String? error})> fetchLikes() async {
    final userId = AuthRepository.instance.profile?.id.toInt();
    if (userId == null) {
      return (items: <SpLike>[], error: '请先登录');
    }

    _loading = true;
    notifyListeners();

    final (resp, error) = await apiCallback<ListSpLikesResp>(
      ({ok, fail, eventually}) => user_api.listUserLikes(
        userId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    _loading = false;
    if (error != null) {
      notifyListeners();
      return (items: <SpLike>[], error: error);
    }

    _items = resp?.list ?? [];
    _total = resp?.total.toInt() ?? _items.length;
    notifyListeners();
    return (items: _items, error: null);
  }
}
