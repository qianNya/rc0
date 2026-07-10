import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../widgets/discovery_feed_top_tab_bar.dart';
import '../widgets/template_market_body.dart';

/// Discovery shell entry — single-page template market.
class ExplorePage extends StatelessWidget {
  const ExplorePage({
    super.key,
    this.embeddedInHub = false,
    this.showInlineSearchAction = true,
    this.showInlineFeedTabs = true,
    this.mobileFeedTabIndex,
    this.onMobileFeedTabChanged,
    this.initialDiscoverySection,
  });

  final bool embeddedInHub;

  @Deprecated('Discovery is template-only; search is in TemplateMarketBody.')
  final bool showInlineSearchAction;

  @Deprecated('Discovery no longer uses recommendation/template feed tabs.')
  final bool showInlineFeedTabs;

  @Deprecated('Discovery no longer uses recommendation/template feed tabs.')
  final int? mobileFeedTabIndex;

  @Deprecated('Discovery no longer uses recommendation/template feed tabs.')
  final ValueChanged<int>? onMobileFeedTabChanged;

  /// Kept for `/discovery?section=template` deep links; same page either way.
  final String? initialDiscoverySection;

  @override
  Widget build(BuildContext context) {
    final chromeTop = embeddedInHub
        ? (Breakpoints.useSidebarShell(context)
            ? AppDimensions.spacingLg
            : DiscoveryFeedChrome.contentInset(context))
        : 0.0;

    return ResponsiveBuilder(
      mobile: (_) => TemplateMarketBody(
        compact: true,
        embeddedInHub: embeddedInHub,
        topPadding: chromeTop,
      ),
      desktop: (_) => TemplateMarketBody(
        compact: false,
        showDesktopHeader: true,
        embeddedInHub: embeddedInHub,
        topPadding: chromeTop,
      ),
    );
  }
}
