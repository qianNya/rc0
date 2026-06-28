import 'dart:convert';

import 'api_headers.dart';

enum ApiErrorCategory {
  none,
  business,
  unauthorized,
  forbidden,
  notFound,
  server,
  badResponse,
  network,
}

class ApiInterceptResult {
  const ApiInterceptResult({
    required this.isSuccess,
    this.data,
    this.message,
    this.category = ApiErrorCategory.none,
  });

  final bool isSuccess;
  final Map<String, dynamic>? data;
  final String? message;
  final ApiErrorCategory category;

  bool get shouldPresentGlobally =>
      category == ApiErrorCategory.unauthorized ||
      category == ApiErrorCategory.server ||
      category == ApiErrorCategory.network;

  bool get isUnauthorized => category == ApiErrorCategory.unauthorized;
}

abstract final class ApiResponseInterceptor {
  static const _unauthorizedMessage = '登录已过期，请先登录';
  static const _serverMessage = '服务器异常，请稍后重试';
  static const _maintenanceMessage = '系统维护中，请稍后再试';
  static const _badResponseMessage = '服务响应异常，请稍后重试';

  static ApiInterceptResult intercept(int statusCode, String body) {
    if (statusCode == 401) {
      return _failure(_unauthorizedMessage, ApiErrorCategory.unauthorized);
    }

    if (statusCode == 403) {
      return _failure('无权访问此资源', ApiErrorCategory.business);
    }
    if (statusCode == 404) {
      return _failure('请求的资源不存在', ApiErrorCategory.business);
    }
    if (statusCode == 429) {
      return _failure('请求过于频繁，请稍后再试', ApiErrorCategory.business);
    }
    if (statusCode == 503) {
      return _failure(_maintenanceMessage, ApiErrorCategory.server);
    }

    if (statusCode >= 500) {
      return _failure(_serverMessage, ApiErrorCategory.server);
    }

    Map<String, dynamic>? base;
    try {
      base = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return _failure(_badResponseMessage, ApiErrorCategory.badResponse);
    }

    final code = base['code'];

    if (code == 401) {
      return _failure(_unauthorizedMessage, ApiErrorCategory.unauthorized);
    }
    if (code == 503) {
      return _failure(_maintenanceMessage, ApiErrorCategory.server);
    }

    final envelopeMessage = apiErrorMessage(base);
    if (_isMaintenanceText(envelopeMessage)) {
      return _failure(_maintenanceMessage, ApiErrorCategory.server);
    }

    if (statusCode == 200 && code == 0) {
      final data = base['data'];
      if (data is Map<String, dynamic>) {
        return ApiInterceptResult(isSuccess: true, data: data);
      }
      if (data is List) {
        return ApiInterceptResult(
          isSuccess: true,
          data: {'items': data},
        );
      }
      return ApiInterceptResult(isSuccess: true, data: const {});
    }

    return _failure(envelopeMessage, ApiErrorCategory.business);
  }

  static bool _isMaintenanceText(String message) {
    final lower = message.toLowerCase();
    return message.contains('维护') ||
        lower.contains('maintenance') ||
        message.contains('系统维护中');
  }

  static ApiInterceptResult network(String message) {
    return _failure(message, ApiErrorCategory.network);
  }

  static ApiInterceptResult _failure(String message, ApiErrorCategory category) {
    return ApiInterceptResult(
      isSuccess: false,
      message: message,
      category: category,
    );
  }
}
