import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// GoRouter wired to [authSessionProvider] redirect + [authRepositoryProvider] refresh.
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter.buildRouter(ref);
});
