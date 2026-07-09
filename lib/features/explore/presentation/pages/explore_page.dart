import 'package:flutter/material.dart';

import '../../../../core/responsive/responsive_builder.dart';
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
    return ResponsiveBuilder(
      mobile: (_) => const TemplateMarketBody(
        compact: true,
        showFeaturedBanner: true,
      ),
      desktop: (_) => const TemplateMarketBody(
        compact: false,
        showDesktopHeader: true,
      ),
    );
  }
}
