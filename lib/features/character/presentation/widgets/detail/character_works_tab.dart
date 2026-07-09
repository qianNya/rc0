import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../shared/widgets/empty_state_view.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../domain/character_detail_data.dart';
import '../../../domain/character_utils.dart';

enum CharacterWorksFilter { hot, latest, featured }

class CharacterWorksTab extends StatefulWidget {
  const CharacterWorksTab({super.key, required this.works});

  final List<CharacterWorkItem> works;

  @override
  State<CharacterWorksTab> createState() => _CharacterWorksTabState();
}

class _CharacterWorksTabState extends State<CharacterWorksTab> {
  CharacterWorksFilter _filter = CharacterWorksFilter.hot;

  List<CharacterWorkItem> get _filtered {
    final items = List<CharacterWorkItem>.from(widget.works);
    switch (_filter) {
      case CharacterWorksFilter.hot:
        items.sort((a, b) => b.likes.compareTo(a.likes));
      case CharacterWorksFilter.latest:
        items.sort((a, b) => b.id.compareTo(a.id));
      case CharacterWorksFilter.featured:
        return items.where((w) => w.featured).toList(growable: false);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    if (widget.works.isEmpty) {
      return const EmptyStateView(
        icon: Icons.movie_creation_outlined,
        title: '暂无关联作品',
        subtitle: '使用该角色的剧本将展示在这里',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
            AppDimensions.spacingMd,
            AppDimensions.spacingSm,
          ),
          child: Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: '热门',
                selected: _filter == CharacterWorksFilter.hot,
                onTap: () =>
                    setState(() => _filter = CharacterWorksFilter.hot),
              ),
              _FilterChip(
                label: '最新',
                selected: _filter == CharacterWorksFilter.latest,
                onTap: () =>
                    setState(() => _filter = CharacterWorksFilter.latest),
              ),
              _FilterChip(
                label: '官方精选',
                selected: _filter == CharacterWorksFilter.featured,
                onTap: () =>
                    setState(() => _filter = CharacterWorksFilter.featured),
              ),
            ],
          ),
        ),
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    '该分类暂无作品',
                    style: AppTextStyles.bodySecondary,
                  ),
                )
              : _WorksMasonry(
                  works: filtered,
                  onTap: (work) => context.push(AppRoutes.script(work.id)),
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.accentLight,
      checkmarkColor: AppColors.accent,
      labelStyle: TextStyle(
        color: selected ? AppColors.accent : AppColors.textSecondary,
        fontSize: 13,
      ),
    );
  }
}

class _WorksMasonry extends StatelessWidget {
  const _WorksMasonry({required this.works, required this.onTap});

  final List<CharacterWorkItem> works;
  final ValueChanged<CharacterWorkItem> onTap;

  @override
  Widget build(BuildContext context) {
    final left = <Widget>[];
    final right = <Widget>[];
    for (var i = 0; i < works.length; i++) {
      final card = Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
        child: _WorkCard(work: works[i], onTap: () => onTap(works[i])),
      );
      if (i.isEven) {
        left.add(card);
      } else {
        right.add(card);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Column(children: left)),
          const SizedBox(width: AppDimensions.spacingSm),
          Expanded(child: Column(children: right)),
        ],
      ),
    );
  }
}

class _WorkCard extends StatelessWidget {
  const _WorkCard({required this.work, required this.onTap});

  final CharacterWorkItem work;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heights = [168.0, 196.0, 152.0];

    return Material(
      color: isDark ? AppColors.characterCardDark : AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: heights[work.id.hashCode.abs() % heights.length],
              child: PoseCoverImage(
                imagePath: work.coverPath,
                expand: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      work.title.isNotEmpty
                          ? work.title
                          : (work.author.isNotEmpty ? work.author : '未命名剧本'),
                      style: AppTextStyles.label.copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (work.likes > 0) ...[
                    Icon(
                      Icons.favorite_border,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      formatCharacterCount(work.likes),
                      style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
