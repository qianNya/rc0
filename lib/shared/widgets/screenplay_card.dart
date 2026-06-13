import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/domain/screenplay/screenplay.dart';
import '../../core/domain/screenplay/screenplay_adapter.dart';
import 'pose_cover_image.dart';

class ScreenplayCard extends StatelessWidget {
  const ScreenplayCard({
    super.key,
    required this.screenplay,
    this.compact = false,
    this.onDelete,
  });

  final Screenplay screenplay;
  final bool compact;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final view = screenplay.toCardView();

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(AppRoutes.script(screenplay.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PoseCoverImage(
                    imagePath: view.coverImagePath,
                    expand: true,
                  ),
                  if (onDelete != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.black.withValues(alpha: 0.55),
                        shape: const CircleBorder(),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: onDelete,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                compact ? 8 : 10,
                compact ? 6 : 8,
                compact ? 8 : 10,
                compact ? 8 : 10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    view.title,
                    style: AppTextStyles.label.copyWith(
                      fontSize: compact ? 13 : 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    view.hierarchySummary,
                    style: AppTextStyles.bodySecondary.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: AppColors.accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (view.tags.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      view.tags.take(3).join(' · '),
                      style: AppTextStyles.bodySecondary.copyWith(
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
