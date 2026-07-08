import 'package:flutter/material.dart';

import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/template_grid_card.dart';

/// @deprecated Use [TemplateGridCard] directly.
class CommunityTemplateCard extends StatelessWidget {
  const CommunityTemplateCard({
    super.key,
    required this.screenplay,
    this.showHotBadge = false,
  });

  final Screenplay screenplay;
  final bool showHotBadge;

  @override
  Widget build(BuildContext context) {
    return TemplateGridCard(
      screenplay: screenplay,
      compact: true,
      showBadge: showHotBadge ? ContentBadgeType.hot : null,
    );
  }
}
