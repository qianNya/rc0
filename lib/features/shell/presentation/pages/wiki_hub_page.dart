import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/status_bar_spacer.dart';
import '../../../character/presentation/widgets/wiki/wiki_character_library_tab.dart';
import '../widgets/wiki_ip_tab.dart';
import '../widgets/wiki_related_tab.dart';

/// Wiki 入口：IP 参考、角色库与关联 Wiki 导航。
class WikiHubPage extends StatefulWidget {
  const WikiHubPage({super.key, this.initialTabIndex = 0});

  final int initialTabIndex;

  @override
  State<WikiHubPage> createState() => _WikiHubPageState();
}

class _WikiHubPageState extends State<WikiHubPage> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex =
        widget.initialTabIndex.clamp(0, AppCatalog.wikiHubTabs.length - 1);
  }

  @override
  void didUpdateWidget(covariant WikiHubPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      _tabIndex =
          widget.initialTabIndex.clamp(0, AppCatalog.wikiHubTabs.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final useTabs = !Breakpoints.useSidebarShell(context);

    if (!useTabs) {
      return const _WikiHubDesktopLayout();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StatusBarSpacer(),
        Padding(
          padding: const EdgeInsets.only(
            top: 4,
            left: AppDimensions.spacingMd,
            right: AppDimensions.spacingMd,
          ),
          child: FeedTabBar(
            tabs: AppCatalog.wikiHubTabs,
            selectedIndex: _tabIndex,
            onChanged: (index) => setState(() => _tabIndex = index),
            underlineStyle: true,
          ),
        ),
        Expanded(
          child: FadeSlideIndexedStack(
            index: _tabIndex,
            children: const [
              WikiIpTab(),
              WikiCharacterLibraryTab(),
              WikiRelatedTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _WikiHubDesktopLayout extends StatelessWidget {
  const _WikiHubDesktopLayout();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(flex: 5, child: WikiIpTab()),
        const VerticalDivider(width: 1),
        const Expanded(flex: 5, child: WikiCharacterLibraryTab()),
        const VerticalDivider(width: 1),
        const Expanded(flex: 4, child: WikiRelatedTab()),
      ],
    );
  }
}
