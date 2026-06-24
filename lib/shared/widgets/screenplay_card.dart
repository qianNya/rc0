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
    this.onMore,
    this.showBadge,
    this.showVisibilityBadge = false,
    this.selectionMode = false,
    this.selected = false,
    this.onSelectedToggle,
    this.onLongPressEnterSelection,
  });

  final Screenplay screenplay;
  final bool compact;
  final VoidCallback? onDelete;
  final VoidCallback? onMore;
  final ContentBadgeType? showBadge;
  final bool showVisibilityBadge;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onSelectedToggle;
  final VoidCallback? onLongPressEnterSelection;

  @override
  Widget build(BuildContext context) {
    return TemplateGridCard(
      screenplay: screenplay,
      compact: compact,
      showBadge: showBadge,
      showVisibilityBadge: showVisibilityBadge,
      onDelete: onDelete,
      onMore: onMore,
      selectionMode: selectionMode,
      selected: selected,
      onSelectedToggle: onSelectedToggle,
      onLongPressEnterSelection: onLongPressEnterSelection,
    );
  }
}
