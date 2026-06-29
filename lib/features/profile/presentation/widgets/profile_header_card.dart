import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_button.dart';
import '../../../../shared/widgets/liquid_glass_surface.dart';
import '../../../../shared/widgets/rc0_image.dart';

/// Douyin-style profile header: gradient hero, no app bar, stats + action pills.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.bio,
    this.username,
    this.level,
    this.avatarUrl,
    this.backgroundUrl,
    this.isLoggedIn = false,
    this.loadingProfile = false,
    this.works = 0,
    this.following = 0,
    this.followers = 0,
    this.likes = 0,
    this.onLogin,
    this.onEdit,
    this.onMembership,
    this.onScan,
    this.onSettings,
    this.onWorksTap,
    this.onFollowingTap,
    this.onFollowersTap,
    this.onLikesTap,
  });

  final String name;
  final String bio;
  final String? username;
  final int? level;
  final String? avatarUrl;
  final String? backgroundUrl;
  final bool isLoggedIn;
  final bool loadingProfile;
  final int works;
  final int following;
  final int followers;
  final int likes;
  final VoidCallback? onLogin;
  final VoidCallback? onEdit;
  final VoidCallback? onMembership;
  final VoidCallback? onScan;
  final VoidCallback? onSettings;
  final VoidCallback? onWorksTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onLikesTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradientColors = isDark
        ? [
            const Color(0xFF1A1528),
            AppColors.profileGradientEnd.withValues(alpha: 0.92),
          ]
        : [
            AppColors.profileGradientStart,
            AppColors.profileGradientEnd,
          ];

    final hasBackground =
        backgroundUrl != null && backgroundUrl!.trim().isNotEmpty;

    return ClipRect(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: _ProfileBackground(
              backgroundUrl: backgroundUrl,
              gradientColors: gradientColors,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: hasBackground
                      ? [
                          Colors.black.withValues(alpha: 0.12),
                          Colors.black.withValues(alpha: 0.58),
                        ]
                      : [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.18),
                        ],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingXs,
                AppDimensions.spacingMd,
                AppDimensions.spacingLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      _TopIconButton(
                        icon: Icons.qr_code_scanner_outlined,
                        onPressed: onScan,
                      ),
                      const SizedBox(width: AppDimensions.spacingSm),
                      _TopIconButton(
                        icon: Icons.settings_outlined,
                        onPressed: onSettings,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Avatar(
                        avatarUrl: avatarUrl,
                        loading: loadingProfile,
                        onTap: isLoggedIn && !loadingProfile ? onEdit : null,
                      ),
                      const SizedBox(width: AppDimensions.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.title.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (level != null) ...[
                                  Text(
                                    'LV.$level',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (username != null && username!.isNotEmpty)
                                    const Text(
                                      ' · ',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                ],
                                if (username != null && username!.isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      '@$username',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              bio,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.35,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  _ProfileStatsRow(
                    likes: likes,
                    following: following,
                    followers: followers,
                    works: works,
                    onLikesTap: onLikesTap,
                    onFollowingTap: onFollowingTap,
                    onFollowersTap: onFollowersTap,
                    onWorksTap: onWorksTap,
                  ),
                  const SizedBox(height: AppDimensions.spacingMd),
                  if (!isLoggedIn)
                    GlassButton(
                      label: '登录 / 注册',
                      filled: true,
                      expand: true,
                      onPressed: onLogin,
                    )
                  else if (loadingProfile)
                    GlassButton(
                      label: '资料同步中…',
                      expand: true,
                      loading: true,
                      onPressed: null,
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: GlassButton(
                            label: '编辑资料',
                            expand: true,
                            onPressed: onEdit,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          child: GlassButton(
                            label: '开通会员',
                            expand: true,
                            onPressed: onMembership,
                          ),
                        ),
                      ],
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

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground({
    this.backgroundUrl,
    required this.gradientColors,
  });

  final String? backgroundUrl;
  final List<Color> gradientColors;

  @override
  Widget build(BuildContext context) {
    final url = backgroundUrl?.trim() ?? '';
    if (url.isNotEmpty) {
      return Rc0Image(
        path: url,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorWidget: _GradientFallback(colors: gradientColors),
      );
    }

    return _GradientFallback(colors: gradientColors);
  }
}

class _GradientFallback extends StatelessWidget {
  const _GradientFallback({required this.colors});

  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassSurface(
      borderRadius: BorderRadius.circular(999),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 22),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _ProfileStatsRow extends StatelessWidget {
  const _ProfileStatsRow({
    required this.likes,
    required this.following,
    required this.followers,
    required this.works,
    this.onLikesTap,
    this.onFollowingTap,
    this.onFollowersTap,
    this.onWorksTap,
  });

  final int likes;
  final int following;
  final int followers;
  final int works;
  final VoidCallback? onLikesTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onWorksTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCell(
            label: '获赞',
            value: likes,
            onTap: onLikesTap,
          ),
        ),
        Expanded(
          child: _StatCell(
            label: '关注',
            value: following,
            onTap: onFollowingTap,
          ),
        ),
        Expanded(
          child: _StatCell(
            label: '粉丝',
            value: followers,
            onTap: onFollowersTap,
          ),
        ),
        Expanded(
          child: _StatCell(
            label: '作品',
            value: works,
            onTap: onWorksTap,
          ),
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    this.onTap,
  });

  final String label;
  final int value;
  final VoidCallback? onTap;

  String get _display {
    if (value >= 10000) return '${(value / 10000).toStringAsFixed(1)}w';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final child = Column(
      children: [
        Text(
          _display,
          style: AppTextStyles.title.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
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

class _Avatar extends StatelessWidget {
  const _Avatar({
    this.avatarUrl,
    this.loading = false,
    this.onTap,
  });

  final String? avatarUrl;
  final bool loading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    const radius = 40.0;
    const size = radius * 2;
    final border = Border.all(color: Colors.white.withValues(alpha: 0.35), width: 2);

    Widget avatarChild;
    if (loading) {
      avatarChild = const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        ),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      avatarChild = ClipOval(
        child: Rc0Image(
          path: avatarUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: const Icon(
            Icons.person,
            size: 36,
            color: Colors.white70,
          ),
        ),
      );
    } else {
      avatarChild = const Icon(Icons.person, size: 36, color: Colors.white70);
    }

    final avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: border,
        color: AppColors.placeholder,
      ),
      clipBehavior: Clip.antiAlias,
      child: avatarChild,
    );

    if (onTap == null) return avatar;

    return GestureDetector(
      onTap: onTap,
      child: avatar,
    );
  }
}
