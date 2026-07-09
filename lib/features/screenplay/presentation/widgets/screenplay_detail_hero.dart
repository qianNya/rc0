import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../core/domain/screenplay/script_frame_display.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/image_preview.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../domain/shoot_params.dart';
import 'screenplay_shoot_params_chips.dart';

class ScreenplayDetailHero extends StatefulWidget {
  const ScreenplayDetailHero({
    super.key,
    required this.screenplay,
    required this.previewOptions,
    required this.isOwner,
    required this.onBack,
    this.onMore,
    this.onFork,
    this.onEdit,
    this.onFollow,
    this.onLike,
    this.shootDefaults,
    this.forking = false,
    this.followBusy = false,
    this.likeBusy = false,
  });

  final Screenplay screenplay;
  final ImagePreviewOptions previewOptions;
  final ShootParams? shootDefaults;
  final bool isOwner;
  final VoidCallback onBack;
  final VoidCallback? onMore;
  final VoidCallback? onFork;
  final VoidCallback? onEdit;
  final VoidCallback? onFollow;
  final VoidCallback? onLike;
  final bool forking;
  final bool followBusy;
  final bool likeBusy;

  @override
  State<ScreenplayDetailHero> createState() => _ScreenplayDetailHeroState();
}

class _ScreenplayDetailHeroState extends State<ScreenplayDetailHero> {
  int _carouselIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screenplay = widget.screenplay;
    final frames = screenplay.allFrames;
    final framePaths = frames.map((f) => f.effectiveDisplayPath).toList();
    final frameCaptions = frames.map((f) => f.caption).toList();
    final hasExplicitCover = (screenplay.localCoverPath != null &&
            screenplay.localCoverPath!.isNotEmpty) ||
        (screenplay.coverUrl != null && screenplay.coverUrl!.isNotEmpty);
    final coverPath = screenplay.effectiveCoverImagePath;
    const heroHeight = 300.0;
    const cardOverlap = 40.0;

    return Column(
      children: [
        SizedBox(
          height: heroHeight,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasExplicitCover && coverPath != null && coverPath.isNotEmpty)
                PoseCoverImage(
                  imagePath: coverPath,
                  expand: true,
                  borderRadius: 0,
                  enablePreview: true,
                  previewOptions: widget.previewOptions,
                  isUploaded: screenplay.coverIsRemoteUploaded,
                )
              else if (frames.isNotEmpty)
                PageView.builder(
                  itemCount: frames.length,
                  onPageChanged: (i) => setState(() => _carouselIndex = i),
                  itemBuilder: (_, index) => PoseCoverImage(
                    imagePath: frames[index].effectiveDisplayPath,
                    expand: true,
                    borderRadius: 0,
                    enablePreview: true,
                    previewGallery: framePaths,
                    previewIndex: index,
                    previewCaptions: frameCaptions,
                    previewOptions: widget.previewOptions,
                    isUploaded: frames[index].isRemoteUploaded,
                  ),
                )
              else
                const PoseCoverImage(expand: true, borderRadius: 0),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.heroScrimMid,
                      Colors.transparent,
                      AppColors.heroScrimBottom,
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        _HeroIconButton(
                          icon: Icons.arrow_back,
                          onPressed: widget.onBack,
                        ),
                        const Spacer(),
                        if (widget.onMore != null)
                          _HeroIconButton(
                            icon: Icons.more_horiz,
                            onPressed: widget.onMore,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!hasExplicitCover && frames.isNotEmpty)
                Positioned(
                  right: 12,
                  bottom: cardOverlap + 12,
                  child: LiquidGlassSurface(
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: Text(
                      '${_carouselIndex + 1}/${frames.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -cardOverlap),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
            ),
            child: ScreenplayDetailInfoCard(
              screenplay: screenplay,
              shootDefaults: widget.shootDefaults,
              isOwner: widget.isOwner,
              onFork: widget.onFork,
              onEdit: widget.onEdit,
              onFollow: widget.onFollow,
              onLike: widget.onLike,
              forking: widget.forking,
              followBusy: widget.followBusy,
              likeBusy: widget.likeBusy,
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingSm),
      ],
    );
  }
}

class _HeroIconButton extends StatelessWidget {
  const _HeroIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(999),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
        tooltip: icon == Icons.arrow_back ? '返回' : '更多',
      ),
    );
  }
}

class ScreenplayDetailInfoCard extends StatelessWidget {
  const ScreenplayDetailInfoCard({
    super.key,
    required this.screenplay,
    required this.isOwner,
    this.shootDefaults,
    this.onFork,
    this.onEdit,
    this.onFollow,
    this.onLike,
    this.forking = false,
    this.followBusy = false,
    this.likeBusy = false,
  });

  final Screenplay screenplay;
  final ShootParams? shootDefaults;
  final bool isOwner;
  final VoidCallback? onFork;
  final VoidCallback? onEdit;
  final VoidCallback? onFollow;
  final VoidCallback? onLike;
  final bool forking;
  final bool followBusy;
  final bool likeBusy;

  @override
  Widget build(BuildContext context) {
    final showInlineFork = !isOwner || screenplay.isForkCopy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            screenplay.title,
            style: AppTextStyles.display.copyWith(
              fontSize: 22,
              color: primary,
            ),
          ),
          if (screenplay.isForkCopy ||
              screenplay.effectiveForkSourceId != null) ...[
            const SizedBox(height: 6),
            _ForkSourceLink(sourceId: screenplay.effectiveForkSourceId),
          ],
          const SizedBox(height: 6),
          Text(
            screenplay.hierarchySummary,
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          if (shootDefaults != null && shootDefaults!.hasAnyValue) ...[
            const SizedBox(height: 10),
            ScreenplayShootParamsChips(
              params: shootDefaults!,
              compact: true,
            ),
          ],
          if (screenplay.isPublished && screenplay.isPrivate) ...[
            const SizedBox(height: 10),
            LiquidGlassSurface(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: Text(
                '非公开 · 可通过 JSON 分享',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
            ),
          ],
          const SizedBox(height: 14),
          AuthorRow(
            authorName: screenplay.author,
            showFollow: !isOwner && screenplay.ownerUserId != null,
            onFollow: followBusy ? null : onFollow,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DetailEngagementRow(
                  likes: screenplay.likes,
                  favorites: screenplay.favorites,
                  views: screenplay.views,
                  isLiked: screenplay.isLiked,
                  onLike: likeBusy ? null : onLike,
                ),
              ),
              if (isOwner && onEdit != null)
                GlassButton(
                  label: '编辑剧本',
                  onPressed: onEdit,
                )
              else if (showInlineFork && onFork != null)
                GlassButton(
                  label: forking ? 'Fork 中…' : 'Fork 模板',
                  loading: forking,
                  onPressed: forking ? null : onFork,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailEngagementRow extends StatelessWidget {
  const _DetailEngagementRow({
    required this.likes,
    required this.favorites,
    required this.views,
    this.isLiked = false,
    this.onLike,
  });

  final int likes;
  final int favorites;
  final int views;
  final bool isLiked;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: _StatItem(
              icon: isLiked ? Icons.favorite : Icons.favorite_border,
              value: _formatCount(likes),
              active: isLiked,
            ),
          ),
        ),
        const SizedBox(width: 14),
        _StatItem(icon: Icons.bookmark_border, value: _formatCount(favorites)),
        const SizedBox(width: 14),
        _StatItem(icon: Icons.visibility_outlined, value: _formatCount(views)),
      ],
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    this.active = false,
  });

  final IconData icon;
  final String value;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: active ? AppColors.accent : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _ForkSourceLink extends StatelessWidget {
  const _ForkSourceLink({this.sourceId});

  final int? sourceId;

  @override
  Widget build(BuildContext context) {
    final canOpen = sourceId != null && sourceId! > 0;
    final label = canOpen ? '翻拍自 #$sourceId' : '翻拍自已失效模板';
    final style = AppTextStyles.bodySecondary.copyWith(
      fontSize: 13,
      color: canOpen ? AppColors.accent : null,
      decoration: canOpen ? TextDecoration.underline : null,
      decorationColor: AppColors.accent,
    );
    if (!canOpen) {
      return Text(label, style: style);
    }
    return GestureDetector(
      onTap: () => context.push(AppRoutes.script('$sourceId')),
      child: Text(label, style: style),
    );
  }
}
