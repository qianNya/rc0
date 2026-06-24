import 'package:flutter/foundation.dart';

import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../auth/data/auth_repository.dart';
import '../../screenplay/data/screenplay_enrichment.dart';

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
  Map<int, Screenplay> _screenplays = {};
  int _total = 0;
  bool _loading = false;

  List<FavoriteScreenplayRef> get items => List.unmodifiable(_items);
  Map<int, Screenplay> get screenplays => Map.unmodifiable(_screenplays);
  int get total => _total;
  bool get loading => _loading;

  Screenplay? screenplayFor(int screenplayId) => _screenplays[screenplayId];

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
    _screenplays = await enrichScreenplayIds(
      _items.map((e) => e.screenplayId),
    );
    notifyListeners();
    return (items: _items, error: null);
  }
}
