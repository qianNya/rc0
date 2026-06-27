import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../app/router/routes.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/app_dimensions.dart';
import '../../../../../app/theme/app_shadows.dart';
import '../../../../../app/theme/app_text_styles.dart';
import '../../../../../core/domain/screenplay/screenplay.dart';
import '../../../../../shared/widgets/pose_cover_image.dart';
import '../../../../screenplay/data/screenplay_local_repository.dart';
import '../../../domain/character_utils.dart';

class CharacterScriptListTile extends StatelessWidget {
  const CharacterScriptListTile({
    super.key,
    required this.screenplay,
    required this.onTap,
  });

  final Screenplay screenplay;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
      child: Material(
        color: isDark ? AppColors.characterCardDark : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              boxShadow: isDark ? null : AppShadows.card,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  height: 72,
                  child: PoseCoverImage(
                    imagePath: screenplay.coverImagePath ?? '',
                    expand: true,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingSm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          screenplay.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.label.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          screenplay.synopsis,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${formatCharacterCount(screenplay.favorites)}收藏',
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 11,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CharacterScriptsTab extends StatelessWidget {
  const CharacterScriptsTab({super.key, required this.characterId});

  final int characterId;

  @override
  Widget build(BuildContext context) {
    final repo = ScreenplayLocalRepository.instance;
    final ids = screenplaysForCharacter(characterId);
    final screenplays = ids
        .map((id) => repo.documentById(id)?.toScreenplay())
        .whereType<Screenplay>()
        .toList(growable: false);

    if (screenplays.isEmpty) {
      return Center(
        child: Text(
          '暂无关联剧本',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: screenplays.length,
      itemBuilder: (context, index) {
        final screenplay = screenplays[index];
        return CharacterScriptListTile(
          screenplay: screenplay,
          onTap: () => context.push(AppRoutes.script(screenplay.detailRouteId)),
        );
      },
    );
  }
}
