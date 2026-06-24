import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_shadows.dart';
import '../../app/theme/app_text_styles.dart';
import '../../core/data/app_catalog.dart';
import 'primary_button.dart';

class AuthorRow extends StatelessWidget {
  const AuthorRow({
    super.key,
    required this.authorName,
    this.level,
    this.showFollow = true,
    this.onFollow,
  });

  final String authorName;
  final int? level;
  final bool showFollow;
  final VoidCallback? onFollow;

  @override
  Widget build(BuildContext context) {
    final lv = level ?? AppCatalog.placeholderLevel;

    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.placeholder,
          child: Icon(Icons.person, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(authorName, style: AppTextStyles.label),
              Text(
                'LV.$lv',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (showFollow)
          SecondaryButton(
            label: '关注',
            isExpanded: false,
            onPressed: onFollow ?? () {},
          ),
      ],
    );
  }
}

class DetailTabBar extends StatelessWidget {
  const DetailTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final selected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onChanged(index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  width: selected ? 28 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class WizardStepIndicator extends StatelessWidget {
  const WizardStepIndicator({
    super.key,
    required this.steps,
    required this.currentStep,
  });

  final List<String> steps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            if (i > 0)
              Container(
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: i <= currentStep ? AppColors.accent : AppColors.border,
              ),
            Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= currentStep
                        ? AppColors.accent
                        : AppColors.surfaceSecondary,
                    border: Border.all(
                      color: i <= currentStep
                          ? AppColors.accent
                          : AppColors.border,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: i <= currentStep
                          ? Colors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[i],
                  style: TextStyle(
                    fontSize: 10,
                    color: i == currentStep
                        ? AppColors.accent
                        : AppColors.textSecondary,
                    fontWeight:
                        i == currentStep ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileGradientHeader extends StatelessWidget {
  const ProfileGradientHeader({
    super.key,
    this.name = '光影捕手',
    this.bio = '摄影创作者 · 分享光影与构图',
    this.level,
    this.avatarUrl,
    this.footer,
  });

  final String name;
  final String bio;
  final int? level;
  final String? avatarUrl;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final lv = level ?? AppCatalog.placeholderLevel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.profileGradientStart,
            AppColors.profileGradientEnd,
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusLg),
        ),
      ),
      child: Column(
        children: [
          if (avatarUrl != null && avatarUrl!.isNotEmpty)
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              backgroundImage: NetworkImage(avatarUrl!),
            )
          else
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
          const SizedBox(height: 12),
          Text(
            name,
            style: AppTextStyles.title.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'LV.$lv',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          if (footer != null) ...[
            const SizedBox(height: 16),
            footer!,
          ],
        ],
      ),
    );
  }
}

class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.works,
    this.following = 0,
    this.followers = 0,
    this.likes = 0,
    this.onWorksTap,
    this.onFollowingTap,
    this.onFollowersTap,
    this.onLikesTap,
  });

  final int works;
  final int following;
  final int followers;
  final int likes;
  final VoidCallback? onWorksTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onLikesTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: AppShadows.card,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatColumn(label: '作品', value: works, onTap: onWorksTap),
          _StatColumn(label: '关注', value: following, onTap: onFollowingTap),
          _StatColumn(label: '粉丝', value: followers, onTap: onFollowersTap),
          _StatColumn(label: '获赞', value: likes, onTap: onLikesTap),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final int value;
  final VoidCallback? onTap;

  String get _display {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Text(_display, style: AppTextStyles.title),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySecondary),
      ],
    );

    if (onTap == null) return child;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class QuickActionCircle extends StatelessWidget {
  const QuickActionCircle({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = backgroundColor ??
        (isDark ? AppColors.accentLightDark : AppColors.accentLight);
    final fg = iconColor ?? AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: fg, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FeaturedBanner extends StatelessWidget {
  const FeaturedBanner({
    super.key,
    this.title = '电影构图模板合集',
    this.subtitle = '精选电影感构图参考',
    this.buttonLabel = '查看合集',
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.profileGradientEnd],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: onTap,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: Text(buttonLabel),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.movie_filter_outlined,
            size: 48,
            color: Colors.white38,
          ),
        ],
      ),
    );
  }
}

enum ContentBadgeType { hot, now }

class ContentBadge extends StatelessWidget {
  const ContentBadge({super.key, required this.type});

  final ContentBadgeType type;

  @override
  Widget build(BuildContext context) {
    final isHot = type == ContentBadgeType.hot;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHot ? AppColors.badgeHot : AppColors.badgeNew,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isHot ? '热门' : '最新',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
