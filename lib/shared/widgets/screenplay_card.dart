import 'package:flutter/material.dart';

import '../../core/domain/screenplay/screenplay.dart';
import 'profile_widgets.dart';
import 'template_grid_card.dart';

/// Delegates to [TemplateGridCard] for backward compatibility.
class ScreenplayCard extends StatelessWidget {
  const ScreenplayCard({
    super.key,
    required this.screenplay,
    this.compact = false,
    this.onDelete,
    this.showBadge,
  });

  final Screenplay screenplay;
  final bool compact;
  final VoidCallback? onDelete;
  final ContentBadgeType? showBadge;

  @override
  Widget build(BuildContext context) {
    return TemplateGridCard(
      screenplay: screenplay,
      compact: compact,
      showBadge: showBadge,
      onDelete: onDelete,
    );
  }
}
