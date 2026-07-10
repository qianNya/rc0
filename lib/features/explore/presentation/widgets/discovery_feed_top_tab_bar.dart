import 'package:flutter/material.dart';

import '../../../../core/data/app_catalog.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/template_market_repository.dart';
import '../../domain/template_feed_query.dart';

/// Discovery feed tabs — lives in floating top chrome (not in scroll body).
///
/// Uses [WikiModeTagTabBar] (same wiki chrome as Script Studio / Gallery hubs)
/// instead of [FeedTabBar] so the top row has no floating capsule shadow.
class DiscoveryFeedTopTabBar extends StatefulWidget {
  const DiscoveryFeedTopTabBar({super.key});

  @override
  State<DiscoveryFeedTopTabBar> createState() => _DiscoveryFeedTopTabBarState();
}

class _DiscoveryFeedTopTabBarState extends State<DiscoveryFeedTopTabBar> {
  final _repository = TemplateMarketRepository.instance;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => scheduleSetState(this);

  void _onTabChanged(int index) {
    if (index == _repository.query.sortTabIndex) return;
    _repository.updateFilters(sortTabIndex: index);
    if (index == TemplateFeedQuery.tabFollowing &&
        !AuthRepository.instance.isLoggedIn) {
      return;
    }
    _repository.loadFirstPage(
      query: _repository.query.copyWith(sortTabIndex: index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WikiModeTagTabBar(
      tabs: AppCatalog.discoveryFeedTabs,
      selectedIndex: _repository.query.sortTabIndex,
      onChanged: _onTabChanged,
    );
  }
}

/// Chrome height for discovery feed tabs in the floating app bar.
abstract final class DiscoveryFeedChrome {
  static double contentInset(BuildContext context) {
    return wikiModeTagContentInsetHeight(context);
  }
}
