import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/app_router.dart';
import '../../app/router/routes.dart';
import 'api_response_interceptor.dart';

abstract final class ApiErrorPresenter {
  static String? _lastMessage;
  static DateTime? _lastShownAt;
  static const _dedupeWindow = Duration(seconds: 3);

  static void presentIfNeeded(ApiInterceptResult result) {
    if (!result.shouldPresentGlobally) return;

    final message = result.message;
    if (message == null || message.trim().isEmpty) return;

    if (_isDuplicate(message)) return;

    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    _lastMessage = message;
    _lastShownAt = DateTime.now();

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: result.isUnauthorized
              ? SnackBarAction(
                  label: '去登录',
                  onPressed: () => _navigateToLogin(context),
                )
              : null,
        ),
      );
  }

  static bool _isDuplicate(String message) {
    final lastAt = _lastShownAt;
    if (_lastMessage != message || lastAt == null) return false;
    return DateTime.now().difference(lastAt) < _dedupeWindow;
  }

  static void _navigateToLogin(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    if (path == AppRoutes.login || path == AppRoutes.register) return;

    final from = AppRouter.router.routerDelegate.currentConfiguration.uri
        .toString();
    AppRouter.router.go(AppRoutes.loginWithRedirect(from));
  }
}
