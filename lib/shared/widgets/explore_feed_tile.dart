import 'package:flutter/material.dart';

import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import 'script_feed_card.dart';
import 'template_feed_card.dart';

class ExploreFeedTile extends StatelessWidget {
  const ExploreFeedTile({
    super.key,
    required this.screenplay,
    this.onFork,
    this.onDelete,
    this.forkLoading = false,
  });

  final Screenplay screenplay;
  final VoidCallback? onFork;
  final VoidCallback? onDelete;
  final bool forkLoading;

  @override
  Widget build(BuildContext context) {
    return switch (screenplay.exploreFeedType) {
      ExploreFeedType.script => ScriptFeedCard(
          screenplay: screenplay,
          onDelete: onDelete,
          onFork: onFork,
        ),
      ExploreFeedType.template => TemplateFeedCard(
          screenplay: screenplay,
          onFork: onFork,
          forkLoading: forkLoading,
        ),
    };
  }
}
