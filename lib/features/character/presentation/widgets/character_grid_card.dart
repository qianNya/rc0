import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/rc0_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../domain/character_entry.dart';
import '../../domain/character_utils.dart';

class CharacterGridCard extends StatelessWidget {
  const CharacterGridCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.screenplayCount,
    this.favoriteCount,
    this.localCoverPath,
  });

  final CharacterEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int? screenplayCount;
  final int? favoriteCount;
  final String? localCoverPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.characterCardDark : theme.colorScheme.surface;
    final coverPath = (localCoverPath != null && localCoverPath!.isNotEmpty)
        ? localCoverPath!
        : entry.effectiveCoverUrl;
    final tags = entry.displayTags.take(3).toList();
    final scripts = screenplayCount ?? 0;
    final favorites = favoriteCount;

    return Material(
      color: cardColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: isDark ? null : AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (coverPath.isNotEmpty)
                      Rc0Image(path: coverPath, fit: BoxFit.cover)
                    else
                      const PlaceholderImage(
                        aspectRatio: 3 / 4,
                        borderRadius: 0,
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.scrim,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              formatCharacterCount(favorites),
                              style: AppTextStyles.label.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: [
                          for (final tag in tags)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.accentLightDark
                                    : AppColors.accentLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 10,
                                  color: AppColors.accent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      '$scripts个剧本 · ${formatCharacterCount(favorites)}收藏',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
