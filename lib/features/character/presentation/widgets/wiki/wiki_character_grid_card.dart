import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/rc0_image.dart';
import '../../../../../shared/widgets/rc0_widgets.dart';
import '../../../domain/character_entry.dart';
import '../../../domain/character_utils.dart';

/// Wiki 角色库双列卡片（封面 + 剧本数 + 收藏 + 来源标签）。
class WikiCharacterGridCard extends StatelessWidget {
  const WikiCharacterGridCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.onLongPress,
    this.screenplayCount = 0,
    this.likeCount,
    this.localCoverPath,
    this.favorited = false,
  });

  final CharacterEntry entry;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final int screenplayCount;
  final int? likeCount;
  final String? localCoverPath;
  final bool favorited;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        isDark ? AppColors.characterCardDark : Theme.of(context).colorScheme.surface;
    final coverPath = (localCoverPath != null && localCoverPath!.isNotEmpty)
        ? localCoverPath!
        : entry.effectiveCoverUrl;
    final sourceTag = wikiCharacterSourceTag(entry);
    final likes = likeCount ?? (entry.sort > 0 ? entry.sort : null);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
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
                    const PlaceholderImage(aspectRatio: 3 / 4, borderRadius: 0),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.heroScrimBottom],
                        stops: [0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: _MetricPill(
                      icon: favorited ? Icons.favorite : Icons.favorite_border,
                      iconColor: favorited ? AppColors.catPink : Colors.white,
                      label: formatCharacterCount(likes),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 8,
                    right: 8,
                    child: Row(
                      children: [
                        _MetricPill(
                          icon: Icons.auto_stories_outlined,
                          label: '$screenplayCount 剧本',
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.accentLightDark
                          : AppColors.accentLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sourceTag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.glassNavIconSelectedDark
                            : AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.label,
    this.icon,
    this.iconColor = Colors.white,
  });

  final String label;
  final IconData? icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scrim,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: iconColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
