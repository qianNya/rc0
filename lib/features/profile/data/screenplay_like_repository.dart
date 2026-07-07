import 'package:flutter/foundation.dart';

import '../../../api/user/api/user-api.dart' as user_api;
import '../../../api/user/data/user-api.dart';
import '../../../core/domain/screenplay/screenplay.dart';
import '../../../core/network/api_callback.dart';
import '../../../core/auth/auth_bridge.dart';
import '../../screenplay/data/screenplay_enrichment.dart';

class ScreenplayLikeRepository extends ChangeNotifier {
  ScreenplayLikeRepository._();

  static final ScreenplayLikeRepository instance = ScreenplayLikeRepository._();

  List<SpLike> _items = [];
  Map<int, Screenplay> _screenplays = {};
  int _total = 0;
  bool _loading = false;

  List<SpLike> get items => List.unmodifiable(_items);
  Map<int, Screenplay> get screenplays => Map.unmodifiable(_screenplays);
  int get total => _total;
  bool get loading => _loading;

  Screenplay? screenplayFor(int screenplayId) => _screenplays[screenplayId];

  Future<({List<SpLike> items, String? error})> fetchLikes() async {
    final userId = AuthBridge.profile?.id.toInt();
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
    _screenplays = await enrichScreenplayIds(
      _items.map((e) => e.screenplayId.toInt()),
    );
    notifyListeners();
    return (items: _items, error: null);
  }
}
