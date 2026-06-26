import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';

/// PC 桌面导航约定（与 [DesktopSidebar] 一致）：
///
/// - **Shell Tab**（discovery / library / studio / messages / profile）：
///   侧栏使用 [GoRouter.go]，保持分支状态。
/// - **侧栏非 Tab 入口**（community、favorites、search、profileWorks 等）：
///   使用 [GoRouter.push] 压入根栈。
/// - **Shell Tab 内**：不显示返回钮，通过侧栏切换。
/// - **栈页返回**：优先 [GoRouter.canPop] → pop；否则按场景 fallback：
///   [popOrGoDiscovery] 或 [popOrGoStudio]。

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
