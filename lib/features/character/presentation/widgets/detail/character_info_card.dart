import 'package:flutter/material.dart';

import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/glass/glass_card.dart';
import '../../../../../shared/widgets/rc0_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../domain/character_utils.dart';

class CharacterInfoCard extends StatefulWidget {
  const CharacterInfoCard({
    super.key,
    required this.snapshot,
    required this.isFavorite,
    required this.onFavorite,
  });

  final CharacterDetailSnapshot snapshot;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  State<CharacterInfoCard> createState() => _CharacterInfoCardState();
}

class _CharacterInfoCardState extends State<CharacterInfoCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.snapshot;
    final entry = snapshot.entry;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final description = snapshot.description;

    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(path: snapshot.avatarPath),
              const SizedBox(width: AppDimensions.spacingSm),
              Expanded(
                child: Text(
                  entry.name,
                  style: AppTextStyles.title.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              OutlinedButton(
                onPressed: widget.onFavorite,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  visualDensity: VisualDensity.compact,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(widget.isFavorite ? '已收藏' : '收藏'),
                  ],
                ),
              ),
            ],
          ),
          if (snapshot.tags.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in snapshot.tags)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: tag.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: tag.color.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      tag.name,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 12,
                        color: tag.color,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Text(
                snapshot.rating.toStringAsFixed(1),
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.badgeHot,
                ),
              ),
              const SizedBox(width: 4),
              ...List.generate(
                5,
                (i) => Icon(
                  i < snapshot.rating.round()
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 16,
                  color: AppColors.badgeHot,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              Text(
                '${formatCharacterCount(snapshot.favoriteCount)} 人收藏',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          _StatsGrid(stats: snapshot.stats),
          if (description.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              description,
              style: AppTextStyles.body.copyWith(height: 1.5),
              maxLines: _expanded ? null : 3,
              overflow: _expanded ? null : TextOverflow.ellipsis,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? '收起' : '展开'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: path.isNotEmpty
          ? Rc0Image(path: path, fit: BoxFit.cover)
          : ColoredBox(
              color: AppColors.accentLight,
              child: Icon(Icons.person, color: AppColors.accent.withValues(alpha: 0.8)),
            ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats});

  final CharacterDetailStats stats;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;

    Widget cell(String value, String label) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            children: [
              Text(
                value,
                style: AppTextStyles.label.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    String refLabel(int count) {
      if (count >= 1000) return '${formatCharacterCount(count)}+';
      return '$count';
    }

    return Row(
      children: [
        cell('${stats.scriptCount}', '脚本'),
        const SizedBox(width: 8),
        cell(refLabel(stats.referenceCount), '参考图'),
        const SizedBox(width: 8),
        cell('${stats.sceneCount}', '场景'),
        const SizedBox(width: 8),
        cell('${stats.costumeCount}', '服装'),
      ],
    );
  }
}
