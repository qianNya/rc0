import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/feed_grid_layout.dart';
import '../../../../shared/widgets/template_grid_card.dart';

/// Inline works grid for the profile「作品」tab (Douyin-style content area).
class ProfileWorksPreview extends StatelessWidget {
  const ProfileWorksPreview({
    super.key,
    required this.screenplays,
    this.maxItems = 6,
    this.onViewAll,
  });

  final List<Screenplay> screenplays;
  final int maxItems;
  final VoidCallback? onViewAll;

  static const _aspectRatio = 0.72;

  @override
  Widget build(BuildContext context) {
    if (screenplays.isEmpty) {
      return _ProfileWorksEmpty(onCreate: () => context.go(AppRoutes.studioCreate));
    }

    final preview = screenplays.take(maxItems).toList(growable: false);

    return FeedGridScope(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = AppDimensions.spacingXs;
          final cols = FeedGridLayout.columnsForWidth(constraints.maxWidth);
          final itemWidth = (constraints.maxWidth - gap * (cols - 1)) / cols;
          final itemHeight = itemWidth / _aspectRatio;

          return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final script in preview)
                  SizedBox(
                    width: itemWidth,
                    height: itemHeight,
                    child: TemplateGridCard(
                      screenplay: script,
                      compact: true,
                      onDelete: null,
                    ),
                  ),
              ],
            ),
            if (screenplays.length > maxItems || onViewAll != null) ...[
              const SizedBox(height: AppDimensions.spacingSm),
              Center(
                child: TextButton(
                  onPressed:
                      onViewAll ?? () => context.push(AppRoutes.profileWorks),
                  child: const Text('查看全部作品'),
                ),
              ),
            ],
          ],
        );
        },
      ),
    );
  }
}

class _ProfileWorksEmpty extends StatelessWidget {
  const _ProfileWorksEmpty({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.movie_creation_outlined, size: 40, color: tertiary),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          '暂无作品',
          style: AppTextStyles.label,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          '开始创作你的第一个剧本',
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Center(
          child: TextButton(
            onPressed: onCreate,
            child: const Text('开始创作'),
          ),
        ),
      ],
    );
  }
}
