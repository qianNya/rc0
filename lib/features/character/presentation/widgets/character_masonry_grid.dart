import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../domain/character_entry.dart';
import 'character_grid_card.dart';

class CharacterMasonryGrid extends StatelessWidget {
  const CharacterMasonryGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.onLongPress,
    this.screenplayCountFor,
    this.favoriteCountFor,
    this.localCoverFor,
    this.crossAxisCount = 2,
    this.spacing = AppDimensions.spacingSm,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppDimensions.spacingMd,
    ),
  });

  final List<CharacterEntry> items;
  final void Function(CharacterEntry entry) onTap;
  final void Function(CharacterEntry entry)? onLongPress;
  final int Function(CharacterEntry entry)? screenplayCountFor;
  final int? Function(CharacterEntry entry)? favoriteCountFor;
  final String? Function(CharacterEntry entry)? localCoverFor;
  final int crossAxisCount;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final columns = List.generate(crossAxisCount, (_) => <Widget>[]);
    for (var i = 0; i < items.length; i++) {
      final entry = items[i];
      columns[i % crossAxisCount].add(
        Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: CharacterGridCard(
            entry: entry,
            screenplayCount: screenplayCountFor?.call(entry),
            favoriteCount: favoriteCountFor?.call(entry),
            localCoverPath: localCoverFor?.call(entry),
            onTap: () => onTap(entry),
            onLongPress:
                onLongPress == null ? null : () => onLongPress!(entry),
          ),
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < crossAxisCount; c++) ...[
            if (c > 0) SizedBox(width: spacing),
            Expanded(child: Column(children: columns[c])),
          ],
        ],
      ),
    );
  }
}
