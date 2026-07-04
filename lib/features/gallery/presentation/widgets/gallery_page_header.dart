import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../studio/presentation/widgets/script_studio_header_components.dart';

/// Gallery top bar — leading actions, horizontally scrollable tabs, trailing actions.
class GalleryHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GalleryHubAppBar({
    super.key,
    this.leading,
    this.actions,
    this.leadingWidth,
    this.onUpload,
    this.uploading = false,
    this.tabs = const [],
    this.selectedTabIndex = 0,
    this.onTabChanged,
    this.showTabs = true,
  });

  final Widget? leading;
  final List<Widget>? actions;
  final double? leadingWidth;
  final VoidCallback? onUpload;
  final bool uploading;
  final List<String> tabs;
  final int selectedTabIndex;
  final ValueChanged<int>? onTabChanged;
  final bool showTabs;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget? _resolveLeading(BuildContext context) {
    if (leading != null) return leading;
    if (Navigator.of(context).canPop()) {
      return WikiModeTagIconButton(
        icon: Icons.arrow_back,
        tooltip: '返回',
        onPressed: () => popOrGoDiscovery(context),
      );
    }
    return WikiModeTagIconButton(
      icon: Icons.menu,
      tooltip: '菜单',
      onPressed: () {},
    );
  }

  List<Widget> _resolveActions() {
    if (actions != null) return actions!;
    return [
      if (uploading)
        const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        )
      else if (onUpload != null)
        WikiModeTagIconButton(
          icon: Icons.add_photo_alternate_outlined,
          tooltip: '上传图片',
          onPressed: onUpload,
        ),
      const ScriptStudioHeaderActionButtons(trailingSpacing: 8),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final resolvedLeading = _resolveLeading(context);
    final resolvedActions = _resolveActions();
    final showTabRow =
        showTabs && tabs.isNotEmpty && onTabChanged != null;

    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs),
          child: Row(
            children: [
              if (resolvedLeading != null) resolvedLeading,
              if (resolvedLeading != null && showTabRow)
                const SizedBox(width: AppDimensions.spacingXs),
              if (showTabRow)
                Expanded(
                  child: WikiModeTagTabBar(
                    tabs: tabs,
                    selectedIndex: selectedTabIndex.clamp(0, tabs.length - 1),
                    onChanged: onTabChanged!,
                  ),
                )
              else
                const Spacer(),
              ...resolvedActions,
            ],
          ),
        ),
      ),
    );
  }
}

/// @deprecated Use [GalleryHubAppBar]
typedef GalleryPageHeader = GalleryHubAppBar;

/// Top spacing below floating wiki app bars on gallery pages.
typedef GalleryHubToolbarContentInset = WikiModeTagToolbarInset;

/// Gallery hub shell — wiki floating chrome, transparent app bar.
class GalleryHubScaffold extends StatelessWidget {
  const GalleryHubScaffold({
    super.key,
    required this.appBar,
    required this.body,
  });

  final PreferredSizeWidget appBar;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return WikiModeTagPageScaffold(
      appBar: appBar,
      body: body,
    );
  }
}
