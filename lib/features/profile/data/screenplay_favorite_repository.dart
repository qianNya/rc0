import 'package:flutter/foundation.dart';

import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';

class FavoriteScreenplayRef {
  const FavoriteScreenplayRef({
    required this.screenplayId,
    required this.createdAt,
  });

  final int screenplayId;
  final String createdAt;
}

FavoriteScreenplayRef _toFavoriteRef(SpFavorite favorite) {
  return FavoriteScreenplayRef(
    screenplayId: favorite.screenplayId.toInt(),
    createdAt: favorite.createAt,
  );
}

class ScreenplayFavoriteRepository extends ChangeNotifier {
  ScreenplayFavoriteRepository._();

  static final ScreenplayFavoriteRepository instance =
      ScreenplayFavoriteRepository._();

  List<FavoriteScreenplayRef> _items = [];
  int _total = 0;
  bool _loading = false;

  List<FavoriteScreenplayRef> get items => List.unmodifiable(_items);
  int get total => _total;
  bool get loading => _loading;

  Future<({List<FavoriteScreenplayRef> items, String? error})>
      fetchFavorites() async {
    final userId = AuthRepository.instance.profile?.id.toInt();
    if (userId == null) {
      return (items: <FavoriteScreenplayRef>[], error: '请先登录');
    }

    _loading = true;
    notifyListeners();

    final (resp, error) = await apiCallback<ListSpFavoritesResp>(
      ({ok, fail, eventually}) => user_api.listUserFavorites(
        userId,
        ok: ok,
        fail: fail,
        eventually: eventually,
      ),
    );

    _loading = false;
    if (error != null) {
      notifyListeners();
      return (items: <FavoriteScreenplayRef>[], error: error);
    }

    _items = (resp?.list ?? []).map(_toFavoriteRef).toList();
    _total = resp?.total.toInt() ?? _items.length;
    notifyListeners();
    return (items: _items, error: null);
  }
}
