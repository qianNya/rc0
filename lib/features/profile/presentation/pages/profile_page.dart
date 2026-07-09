import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/desktop/desktop_hub_scaffold.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/theme_mode_selector.dart';
import '../../../favorites/data/image_favorite_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../data/profile_cache_service.dart';
import '../../data/screenplay_favorite_repository.dart';
import '../../domain/profile_display.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_settings_tile.dart';
import '../widgets/profile_shortcut_item.dart';
import '../widgets/profile_works_preview.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _userProfile = UserProfileRepository.instance;
  final _localScripts = ScreenplayLocalRepository.instance;
  final _imageFavorites = ImageFavoriteRepository.instance;
  final _spFavorites = ScreenplayFavoriteRepository.instance;

  String _appVersion = '';
  int _spFavoriteCount = 0;
  int _contentTabIndex = 0;

  static const _contentTabs = ['作品', '收藏', '点赞'];

  @override
  void initState() {
    super.initState();
    _userProfile.addListener(_onDataChanged);
    _localScripts.addListener(_onDataChanged);
    _imageFavorites.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _loadVersion();
  }

  @override
  void dispose() {
    _userProfile.removeListener(_onDataChanged);
    _localScripts.removeListener(_onDataChanged);
    _imageFavorites.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Future<void> _refresh() async {
    if (ref.read(authSessionProvider).isLoggedIn) {
      await _userProfile.refreshMyStats();
      final fav = await _spFavorites.fetchFavorites();
      await _imageFavorites.load();
      if (!mounted) return;
      setState(() => _spFavoriteCount = fav.items.length);
      if (fav.error != null) _showSnack(fav.error!);
      return;
    }
    await _imageFavorites.load();
    if (mounted) setState(() {});
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openLabs(String featureId) {
    context.push(AppRoutes.labsFeature(featureId));
  }

  Future<void> _manualUpdate() async {
    final progress = ValueNotifier<({int received, int? total})>(
      (received: 0, total: null),
    );

    if (!mounted) return;
    showGlassDialog<void>(
      context,
      barrierDismissible: false,
      child: ValueListenableBuilder<({int received, int? total})>(
        valueListenable: progress,
        builder: (_, value, _) {
          final total = value.total;
          final percent = total != null && total > 0
              ? (value.received * 100 / total).clamp(0, 100).toInt()
              : null;
          return GlassDialog(
            title: const Text('版本更新'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(percent != null ? '正在下载… $percent%' : '正在下载…'),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: total != null && total > 0
                      ? value.received / total
                      : null,
                ),
              ],
            ),
          );
        },
      ),
    );

    final result = await AppUpdateService.downloadAndInstall(
      onProgress: (received, total) {
        progress.value = (received: received, total: total);
      },
    );
    progress.dispose();

    if (!mounted) return;
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    if (result.success) {
      _showSnack('已打开安装界面，请按提示完成更新');
    } else {
      _showSnack(result.error ?? '更新失败');
    }
  }

  Future<void> _clearCache() async {
    final confirmed = await showGlassDialog<bool>(
      context,
      child: GlassDialog(
        title: const Text('清理缓存'),
        onClose: () => Navigator.pop(context, false),
        child: const Text('将清除本地草稿与画格收藏缓存，登录状态不受影响。'),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('清理'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ProfileCacheService.clearCaches();
    await _localScripts.load();
    await _imageFavorites.load();
    if (!mounted) return;
    _showSnack(result.message);
    setState(() {});
  }

  Future<void> _logout() async {
    await ref.read(authRepositoryProvider).logout();
    if (!mounted) return;
    context.go(AppRoutes.discovery);
  }

  void _showSettingsSheet(BuildContext context, {required bool loggedIn}) {
    showGlassSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('设置', style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: AppDimensions.spacingMd),
          ListenableBuilder(
            listenable: ThemeModeNotifier.instance,
            builder: (context, _) => ProfileSettingsTile(
              title: '外观设置',
              subtitle: ThemeModeNotifier.labelFor(
                ThemeModeNotifier.instance.themeMode,
              ),
              icon: Icons.dark_mode_outlined,
              embedded: true,
              onTap: () {
                Navigator.pop(context);
                _showThemeSheet(context);
              },
            ),
          ),
          const Divider(height: 1),
          ProfileSettingsTile(
            title: '缓存管理',
            subtitle: '清理缓存释放空间',
            icon: Icons.delete_outline,
            embedded: true,
            onTap: () {
              Navigator.pop(context);
              _clearCache();
            },
          ),
          const Divider(height: 1),
          ProfileSettingsTile(
            title: '版本更新',
            subtitle: _appVersion.isEmpty ? '检查更新' : 'v$_appVersion',
            icon: Icons.system_update_alt_outlined,
            embedded: true,
            onTap: () {
              Navigator.pop(context);
              _manualUpdate();
            },
          ),
          const Divider(height: 1),
          ProfileSettingsTile(
            title: '关于 rc0',
            subtitle: '了解更多关于我们',
            icon: Icons.info_outline,
            embedded: true,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.profileAbout);
            },
          ),
          if (loggedIn) ...[
            const Divider(height: 1),
            ProfileSettingsTile(
              title: '退出登录',
              subtitle: '退出当前账号',
              icon: Icons.logout_outlined,
              embedded: true,
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ],
      ),
    );
  }

  void _showThemeSheet(BuildContext context) {
    showGlassSheet<void>(
      context,
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingLg,
        AppDimensions.spacingSm,
        AppDimensions.spacingLg,
        AppDimensions.spacingLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '外观设置',
            style: AppTextStyles.title.copyWith(fontSize: 16),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            '选择应用的颜色主题',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          const ThemeModeSelector(),
        ],
      ),
    );
  }

  Widget _buildShortcutGrid({
    required int worksCount,
    required int favoriteCount,
    required bool loggedIn,
  }) {
    return GlassCard(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingSm,
        vertical: AppDimensions.spacingMd,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ProfileShortcutItem(
                  label: '作品库',
                  icon: Icons.video_library_outlined,
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  onTap: () => context.push(AppRoutes.profileWorks),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: '收藏夹',
                  icon: Icons.star_outline,
                  iconColor: AppColors.catPink,
                  iconBackground: AppColors.catPinkBg,
                  onTap: () => context.go(AppRoutes.favoritesTab(1)),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: '图库',
                  icon: Icons.photo_library_outlined,
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  onTap: () => context.push(AppRoutes.gallery),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: '模板',
                  icon: Icons.dashboard_outlined,
                  iconColor: AppColors.catViolet,
                  iconBackground: AppColors.catVioletBg,
                  onTap: () => context.go(AppRoutes.discoveryTemplate),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Row(
            children: [
              Expanded(
                child: ProfileShortcutItem(
                  label: '创作',
                  icon: Icons.add_circle_outline,
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  onTap: () => context.go(AppRoutes.studioCreate),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: '导入',
                  icon: Icons.upload_file_outlined,
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  onTap: () => context.go(AppRoutes.studioCreate),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: 'AI 工具',
                  icon: Icons.auto_fix_high_outlined,
                  iconColor: AppColors.catPink,
                  iconBackground: AppColors.catPinkBg,
                  onTap: () => context.push(AppRoutes.createAiHubPath),
                ),
              ),
              Expanded(
                child: ProfileShortcutItem(
                  label: '帮助',
                  icon: Icons.headset_mic_outlined,
                  iconColor: AppColors.catOrange,
                  iconBackground: AppColors.catOrangeBg,
                  onTap: () => _openLabs('help_feedback'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final profile = session.profile;
    final hasSession = session.isLoggedIn;
    final profileReady = profile != null;
    final loadingProfile = hasSession && !profileReady;

    final displayName = ProfileDisplay.displayName(
      profile,
      loading: loadingProfile,
    );
    final bio = ProfileDisplay.displayBio(
      profile,
      hasSession: hasSession,
    );
    final level = ProfileDisplay.level(profile);
    final username = ProfileDisplay.handle(profile);
    final avatarPath = ProfileDisplay.avatarPath(profile);
    final backgroundPath = ProfileDisplay.backgroundPath(profile);

    final worksCount = profileReady
        ? (profile.screenplayCount.toInt() > 0
            ? profile.screenplayCount.toInt()
            : _localScripts.localScreenplays.length)
        : _localScripts.localScreenplays.length;
    final favoriteCount =
        _imageFavorites.items.length + _spFavoriteCount;

    final body = RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          ProfileHeaderCard(
            name: displayName,
            bio: bio,
            username: username,
            level: level,
            avatarUrl: avatarPath,
            backgroundUrl: backgroundPath,
            isLoggedIn: hasSession,
            loadingProfile: loadingProfile,
            works: worksCount,
            following: profileReady ? profile.followingCount.toInt() : 0,
            followers: profileReady ? profile.followerCount.toInt() : 0,
            likes: profileReady ? profile.totalLikes.toInt() : 0,
            onLogin: () => context.go(
              AppRoutes.loginWithRedirect(AppRoutes.profile),
            ),
            onEdit: profileReady
                ? () => context.push(AppRoutes.profileEdit)
                : null,
            onMembership: () => _openLabs('membership'),
            onScan: () => _showSnack('扫码功能即将上线'),
            onSettings: () => _showSettingsSheet(
              context,
              loggedIn: profileReady,
            ),
            onWorksTap: () => context.push(AppRoutes.profileWorks),
            onFollowingTap: () => _openLabs('following'),
            onFollowersTap: () => _openLabs('followers'),
            onLikesTap: profileReady
                ? () => context.push(AppRoutes.profileLikes)
                : () => context.go(
                      AppRoutes.loginWithRedirect(AppRoutes.profileLikes),
                    ),
          ),
          Transform.translate(
            offset: const Offset(0, -AppDimensions.spacingMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildShortcutGrid(
                    worksCount: worksCount,
                    favoriteCount: favoriteCount,
                    loggedIn: profileReady,
                  ),
                  const SizedBox(height: AppDimensions.spacingLg),
                  GlassCard(
                    borderRadius: BorderRadius.circular(20),
                    padding: EdgeInsets.zero,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppDimensions.spacingSm),
                        FeedTabBar(
                          tabs: _contentTabs,
                          selectedIndex: _contentTabIndex,
                          onChanged: (i) =>
                              setState(() => _contentTabIndex = i),
                          underlineStyle: true,
                          embedded: true,
                        ),
                        const SizedBox(height: AppDimensions.spacingXs),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppDimensions.spacingMd,
                            AppDimensions.spacingSm,
                            AppDimensions.spacingMd,
                            AppDimensions.spacingMd,
                          ),
                          child: FadeSlideIndexedStack(
                            index: _contentTabIndex,
                            children: [
                              ProfileWorksPreview(
                                screenplays: _localScripts.localScreenplays,
                                onViewAll: () =>
                                    context.push(AppRoutes.profileWorks),
                              ),
                              _ProfileTabPlaceholder(
                                icon: Icons.star_outline,
                                title: '$favoriteCount 个收藏',
                                subtitle: '剧本与画格收藏',
                                actionLabel: '查看收藏夹',
                                onAction: () =>
                                    context.go(AppRoutes.favoritesTab(1)),
                              ),
                              _ProfileTabPlaceholder(
                                icon: Icons.favorite_outline,
                                title: '点赞记录',
                                subtitle: '查看你点赞过的内容',
                                actionLabel: profileReady
                                    ? '查看点赞'
                                    : '登录后查看',
                                onAction: profileReady
                                    ? () => context.push(AppRoutes.profileLikes)
                                    : () => context.go(
                                          AppRoutes.loginWithRedirect(
                                            AppRoutes.profileLikes,
                                          ),
                                        ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          ShellBottomSpacer(
            extra: AppDimensions.spacingMd,
          ),
        ],
      ),
    );

    if (Breakpoints.useSidebarShell(context)) {
      return DesktopHubScaffold(
        appBar: const DesktopShellAppBar(
          title: Text('我的'),
          automaticallyImplyLeading: false,
        ),
        desktopHeader: const DesktopHubHeader(
          title: '我的',
          subtitle: '作品、身份与设置',
        ),
        body: AdaptiveContent(
          maxWidth: 960,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingXl,
          ),
          child: body,
        ),
      );
    }

    if (widget.embeddedInHub) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: SizedBox.expand(child: body),
      );
    }

    return WikiModeTagPageScaffold(
      appBar: const DesktopShellAppBar(
        title: Text('我的'),
        automaticallyImplyLeading: false,
      ),
      body: body,
    );
  }
}

class _ProfileTabPlaceholder extends StatelessWidget {
  const _ProfileTabPlaceholder({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final tertiary = Theme.of(context).brightness == Brightness.dark
        ? AppColors.textTertiaryDark
        : AppColors.textTertiary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(icon, size: 40, color: tertiary),
        const SizedBox(height: AppDimensions.spacingSm),
        Text(
          title,
          style: AppTextStyles.label,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingXs),
        Text(
          subtitle,
          style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Center(
          child: TextButton(
            onPressed: onAction,
            child: Text(actionLabel),
          ),
        ),
      ],
    );
  }
}
