import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import 'rc0_app_bar.dart';
import 'rc0_page_scaffold.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.actions,
    this.floatingActionButton,
    this.bottom,
    this.showBackButton = false,
  });

  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    final hasAppBar = title != null;

    if (!hasAppBar) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.pagePadding,
            ),
            child: body,
          ),
        ),
        floatingActionButton: floatingActionButton,
      );
    }

    return Rc0PageScaffold(
      appBar: Rc0AppBar(
        title: Text(title!),
        actions: actions,
        bottom: bottom,
        automaticallyImplyLeading: showBackButton,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.pagePadding,
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppDimensions.spacingMd),
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: card,
      ),
    );
  }
}
