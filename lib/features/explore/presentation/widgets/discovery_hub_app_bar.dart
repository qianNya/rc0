import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import 'discovery_feed_top_tab_bar.dart';

/// Floating top chrome for WikiHub discovery — feed tabs including 编辑精选.
///
/// Layout matches [GalleryHubAppBar] / Script Studio wiki headers: transparent
/// bar, no outer capsule shadow, tabs via [WikiModeTagTabBar].
class DiscoveryHubAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DiscoveryHubAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: const Row(
            children: [
              Expanded(child: DiscoveryFeedTopTabBar()),
            ],
          ),
        ),
      ),
    );
  }
}
