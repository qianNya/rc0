import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// 详情等根路由页返回：有栈则 pop，否则回到探索首页。
void popOrGoExplore(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go(AppRoutes.explore);
  }
}
