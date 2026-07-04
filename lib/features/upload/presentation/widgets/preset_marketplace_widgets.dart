import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/compact_count.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../screenplay/domain/shoot_preset.dart';
import 'preset_cover.dart';

class PresetSectionHeader extends StatelessWidget {
  const PresetSectionHeader({
    super.key,
    required this.title,
    this.trailingLabel,
    this.onTrailingTap,
    this.leadingIcon,
    this.compact = false,
  });

  final String title;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;
  final IconData? leadingIcon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 0 : AppDimensions.spacingMd,
        compact ? AppDimensions.spacingXs : AppDimensions.spacingMd,
        compact ? 0 : AppDimensions.spacingMd,
        compact ? 4 : AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: 16, color: AppColors.accent),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(title, style: AppTextStyles.label),
          ),
          if (trailingLabel != null)
            GestureDetector(
              onTap: onTrailingTap,
              behavior: HitTestBehavior.opaque,
              child: Text(
                trailingLabel!,
                style: AppTextStyles.bodySecondary.copyWith(
                  fontSize: 12,
                  color: AppColors.accent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class PresetMarketSearchBar extends StatelessWidget {
  const PresetMarketSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fill = theme.brightness == Brightness.dark
        ? AppColors.surfaceSecondaryDark
        : AppColors.surfaceSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        0,
        AppDimensions.spacingMd,
        AppDimensions.spacingSm,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppTextStyles.body.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: '搜索预设、设备、风格、作者',
          hintStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: fill,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
      ),
    );
  }
}

class PresetMarketSegmentedTabs extends StatelessWidget {
  const PresetMarketSegmentedTabs({
    super.key,
    required this.selectedIndex,
    required this.myCount,
    required this.onChanged,
  });

  final int selectedIndex;
  final int myCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final track = isDark ? AppColors.surfaceSecondaryDark : AppColors.surfaceSecondary;
    final labels = [
      myCount > 0 ? '我的 $myCount' : '我的',
      '官方',
      '社区',
    ];
    final subtitles = ['', '精选', '热门'];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        decoration: BoxDecoration(
          color: track,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: List.generate(labels.length, (index) {
            final selected = selectedIndex == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? theme.colorScheme.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        labels[index],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          color: selected
                              ? AppColors.accent
                              : (theme.textTheme.bodyMedium?.color ??
                                  AppColors.textSecondary),
                        ),
                      ),
                      if (subtitles[index].isNotEmpty)
                        Text(
                          subtitles[index],
                          style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class PresetCategoryChips extends StatelessWidget {
  const PresetCategoryChips({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<({String id, String label, IconData icon})> categories;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final selected = cat.id == selectedId;
          return FilterChip(
            label: Text(cat.label),
            avatar: Icon(cat.icon, size: 16),
            selected: selected,
            onSelected: (_) => onSelected(cat.id),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          );
        },
      ),
    );
  }
}

class PresetRecentCard extends StatelessWidget {
  const PresetRecentCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.selected = false,
  });

  final ShootPreset preset;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: GlassCard(
        onTap: onTap,
        selected: selected,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PresetCover(preset: preset, expand: true),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber.shade400,
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
                    preset.label,
                    style: AppTextStyles.label.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.deviceLabel,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    preset.aspectLightingLabel,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

class PresetCreateTile extends StatelessWidget {
  const PresetCreateTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(Icons.add, color: AppColors.accent, size: 28),
          ),
          const SizedBox(width: 12),
          Text(
            '创建预设',
            style: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
        ],
      ),
    );
  }
}

class PresetMyRowCard extends StatelessWidget {
  const PresetMyRowCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.onLongPress,
    this.subtitle,
  });

  final ShootPreset preset;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final secondary = subtitle ??
        (preset.updatedAt != null
            ? '最近修改'
            : preset.favoriteCount != null
                ? '收藏 ${preset.favoriteCount} 次'
                : preset.displaySubtitle);

    return GlassCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: const EdgeInsets.all(AppDimensions.spacingSm),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: PresetCover(
                preset: preset,
                expand: true,
                borderRadius: AppDimensions.radiusSm,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        preset.label,
                        style: AppTextStyles.label.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.star_rounded,
                      size: 16,
                      color: AppColors.accent.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  preset.deviceLabel,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                ),
                Text(
                  secondary,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PresetOfficialCard extends StatelessWidget {
  const PresetOfficialCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.compact = false,
    this.selected = false,
  });

  final ShootPreset preset;
  final VoidCallback onTap;
  final bool compact;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 148.0 : 168.0;
    return SizedBox(
      width: width,
      child: GlassCard(
        onTap: onTap,
        selected: selected,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: compact ? 100 : 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PresetCover(preset: preset, expand: true),
                  const Positioned(
                    top: 6,
                    left: 6,
                    child: PresetOfficialBadge(),
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
                    preset.label,
                    style: AppTextStyles.label.copyWith(fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preset.deviceLabel,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                  ),
                  if (preset.aspectLightingLabel.isNotEmpty)
                    Text(
                      preset.aspectLightingLabel,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  const SizedBox(height: 6),
                  _PresetStatsRow(
                    likeCount: preset.likeCount,
                    usageCount: preset.usageCount,
                    rating: preset.rating,
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

class PresetCommunityCard extends StatelessWidget {
  const PresetCommunityCard({
    super.key,
    required this.preset,
    required this.onUse,
    this.onFavorite,
    this.compact = false,
  });

  final ShootPreset preset;
  final VoidCallback onUse;
  final VoidCallback? onFavorite;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _PresetCommunityCompactCard(
        preset: preset,
        onUse: onUse,
        onFavorite: onFavorite,
      );
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 120,
            child: PresetCover(preset: preset, expand: true),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 13)),
                    Expanded(
                      child: Text(
                        preset.label,
                        style: AppTextStyles.label.copyWith(fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                if (preset.authorName != null)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                        child: Text(
                          preset.authorName!.characters.first,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'by ${preset.authorName}',
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (preset.likeCount != null) ...[
                      const Icon(Icons.favorite_border, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        formatCompactCount(preset.likeCount!),
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (preset.downloadCount != null) ...[
                      const Icon(Icons.download_outlined, size: 14),
                      const SizedBox(width: 2),
                      Text(
                        formatCompactCount(preset.downloadCount!),
                        style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onUse,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text('使用', style: TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      onPressed: onFavorite,
                      icon: const Icon(Icons.favorite_border, size: 18),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetCommunityCompactCard extends StatelessWidget {
  const _PresetCommunityCompactCard({
    required this.preset,
    required this.onUse,
    this.onFavorite,
  });

  final ShootPreset preset;
  final VoidCallback onUse;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 168,
      child: GlassCard(
        onTap: onUse,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 96,
              child: PresetCover(preset: preset, expand: true),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingSm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔥 ${preset.label}',
                    style: AppTextStyles.label.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (preset.authorName != null)
                    Text(
                      'by ${preset.authorName}',
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (preset.likeCount != null)
                        Text(
                          '❤ ${formatCompactCount(preset.likeCount!)}',
                          style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                        ),
                      if (preset.downloadCount != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          '↓ ${formatCompactCount(preset.downloadCount!)}',
                          style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
                        ),
                      ],
                    ],
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

class PresetListTileCard extends StatelessWidget {
  const PresetListTileCard({
    super.key,
    required this.preset,
    required this.onTap,
    this.onLongPress,
  });

  final ShootPreset preset;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      onLongPress: onLongPress,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PresetCover(preset: preset, expand: true),
                if (preset.isOfficial)
                  const Positioned(
                    top: 4,
                    left: 4,
                    child: PresetOfficialBadge(),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preset.label, style: AppTextStyles.label),
                  const SizedBox(height: 2),
                  Text(
                    preset.deviceLabel,
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                  ),
                  if (preset.aspectLightingLabel.isNotEmpty)
                    Text(
                      preset.aspectLightingLabel,
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
                    ),
                  const SizedBox(height: 6),
                  _PresetStatsRow(
                    likeCount: preset.likeCount,
                    usageCount: preset.usageCount,
                    downloadCount: preset.downloadCount,
                    rating: preset.rating,
                    authorName: preset.authorName,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PresetStatsRow extends StatelessWidget {
  const _PresetStatsRow({
    this.likeCount,
    this.usageCount,
    this.downloadCount,
    this.rating,
    this.authorName,
  });

  final int? likeCount;
  final int? usageCount;
  final int? downloadCount;
  final double? rating;
  final String? authorName;

  @override
  Widget build(BuildContext context) {
    final parts = <Widget>[];
    if (likeCount != null) {
      parts.add(_stat(Icons.favorite_border, formatCompactCount(likeCount!)));
    }
    if (usageCount != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 10));
      parts.add(_stat(Icons.play_circle_outline, '使用${formatCompactCount(usageCount!)}次'));
    }
    if (downloadCount != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 10));
      parts.add(_stat(Icons.download_outlined, formatCompactCount(downloadCount!)));
    }
    if (rating != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 10));
      parts.add(_stat(Icons.star_rounded, rating!.toStringAsFixed(1)));
    }
    if (authorName != null) {
      if (parts.isNotEmpty) parts.add(const SizedBox(width: 10));
      parts.add(Text(
        'by $authorName',
        style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
      ));
    }

    return Row(children: parts);
  }

  Widget _stat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textSecondary),
        const SizedBox(width: 2),
        Text(
          value,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
