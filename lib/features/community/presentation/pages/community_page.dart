import 'package:flutter/material.dart';

/// @deprecated `/community` redirects to [AppRoutes.discoveryTemplate].
/// Reserved for a future social/publish feed (Phase 5).
class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
