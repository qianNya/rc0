import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// 详情等根路由页返回：有栈则 pop，否则回到发现首页。
void popOrGoDiscovery(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.discovery);
  }
}

/// 编辑器返回：有栈则 pop，否则回到 Script Studio。
void popOrGoStudio(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.studio);
  }
}

/// @deprecated Use [popOrGoDiscovery] instead.
void popOrGoExplore(BuildContext context) => popOrGoDiscovery(context);

/// Auth pages share the same fallback: return to previous page or discovery.
void popOrGoHome(BuildContext context) => popOrGoDiscovery(context);
