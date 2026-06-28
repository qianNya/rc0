import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../core/theme/theme_mode_notifier.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../../../shared/widgets/theme_mode_selector.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../favorites/data/image_favorite_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../data/profile_cache_service.dart';
import '../../data/screenplay_favorite_repository.dart';
import '../widgets/profile_grid_tile.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_settings_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = AuthRepository.instance;
  final _userProfile = UserProfileRepository.instance;
  final _localScripts = ScreenplayLocalRepository.instance;
  final _imageFavorites = ImageFavoriteRepository.instance;
  final _spFavorites = ScreenplayFavoriteRepository.instance;

  String _appVersion = '';
  int _spFavoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_onDataChanged);
    _userProfile.addListener(_onDataChanged);
    _localScripts.addListener(_onDataChanged);
    _imageFavorites.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    _loadVersion();
  }

  @override
  void dispose() {
    _auth.removeListener(_onDataChanged);
    _userProfile.removeListener(_onDataChanged);
    _localScripts.removeListener(_onDataChanged);
    _imageFavorites.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => scheduleSetState(this);

  Future<void> _refresh() async {
    if (_auth.isLoggedIn) {
      await _userProfile.refreshMyStats();
      final fav = await _spFavorites.fetchFavorites();
      await _imageFavorites.load();
      if (!mounted) return;
      setState(() => _spFavoriteCount = fav.items.length);
      if (fav.error != null) _showSnack(fav.error!);
    }
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

  void _comingSoon(String title) {
    context.push(AppRoutes.comingSoon(title));
  }

  Future<void> _manualUpdate() async {
    final progress = ValueNotifier<({int received, int? total})>(
      (received: 0, total: null),
    );

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<({int received, int? total})>(
          valueListenable: progress,
          builder: (_, value, _) {
            final total = value.total;
            final percent = total != null && total > 0
                ? (value.received * 100 / total).clamp(0, 100).toInt()
                : null;
            return AlertDialog(
              title: const Text('版本更新'),
              content: Column(
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
        );
      },
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('清理缓存'),
        content: const Text('将清除本地草稿与画格收藏缓存，登录状态不受影响。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('清理')),
        ],
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
    await _auth.logout();
    if (!mounted) return;
    context.go(AppRoutes.discovery);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _auth.profile;
    final loggedIn = _auth.isLoggedIn && profile != null;

    final displayName = loggedIn
        ? (profile.nickname.isNotEmpty ? profile.nickname : profile.username)
        : 'rc0用户';
    final bio = loggedIn
        ? (profile.bio.isNotEmpty
            ? profile.bio
            : '用镜头记录美好，分享创意灵感')
        : '登录后查看个人资料与作品';
    final level = loggedIn ? profile.level.toInt() : null;

    final worksCount = loggedIn
        ? (profile.screenplayCount.toInt() > 0
            ? profile.screenplayCount.toInt()
            : _localScripts.localScreenplays.length)
        : _localScripts.localScreenplays.length;
    final favoriteCount =
        _imageFavorites.items.length + _spFavoriteCount;

    final appBar = DesktopShellAppBar(
      title: const Text('我的'),
      automaticallyImplyLeading: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.qr_code_scanner_outlined),
          onPressed: () => _showSnack('扫码功能即将上线'),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => _showSnack('请使用下方设置项'),
        ),
      ],
    );

    final body = RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          children: [
            ProfileHeaderCard(
              name: displayName,
              bio: bio,
              level: level,
              avatarUrl: loggedIn && profile.avatar.isNotEmpty
                  ? profile.avatar
                  : null,
              isLoggedIn: loggedIn,
              onLogin: () => context.go(
                AppRoutes.loginWithRedirect(AppRoutes.profile),
              ),
              onRegister: () => context.go(AppRoutes.register),
              onEdit: loggedIn
                  ? () => context.push(AppRoutes.profileEdit)
                  : null,
              onLogout: loggedIn ? _logout : null,
              onMembership: () => _comingSoon('会员'),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StatBar(
                works: worksCount,
                following: loggedIn ? profile.followingCount.toInt() : 0,
                followers: loggedIn ? profile.followerCount.toInt() : 0,
                likes: loggedIn ? profile.totalLikes.toInt() : 0,
                onWorksTap: () => context.push(AppRoutes.profileWorks),
                onFollowingTap: () => _comingSoon('关注列表'),
                onFollowersTap: () => _comingSoon('粉丝列表'),
                onLikesTap: loggedIn
                    ? () => context.push(AppRoutes.profileLikes)
                    : () => context.go(
                          AppRoutes.loginWithRedirect(AppRoutes.profileLikes),
                        ),
              ),
            ),
            const SizedBox(height: 4),
            _section(
              title: '我的资产',
              actionLabel: '全部',
              onAction: () => context.push(AppRoutes.profileWorks),
              children: [
                ProfileGridTile(
                  title: '作品库',
                  subtitle: '$worksCount 个作品',
                  icon: Icons.video_library_outlined,
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  onTap: () => context.push(AppRoutes.profileWorks),
                ),
                ProfileGridTile(
                  title: '收藏夹',
                  subtitle: '$favoriteCount 个收藏',
                  icon: Icons.star_outline,
                  iconColor: AppColors.catPink,
                  iconBackground: AppColors.catPinkBg,
                  onTap: () => context.go(AppRoutes.favoritesTab(1)),
                ),
                ProfileGridTile(
                  title: '模板库',
                  subtitle: '快速制作视频',
                  icon: Icons.dashboard_outlined,
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  onTap: () => context.push(AppRoutes.community),
                ),
                ProfileGridTile(
                  title: 'LUT 调色',
                  subtitle: '电影感预设',
                  icon: Icons.tune,
                  iconColor: AppColors.catGreen,
                  iconBackground: AppColors.catGreenBg,
                  onTap: () => _comingSoon('LUT 调色'),
                ),
              ],
            ),
            _section(
              title: '创作与工具',
              children: [
                ProfileGridTile(
                  title: '创建作品',
                  subtitle: '开始你的创作',
                  icon: Icons.add_circle_outline,
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  onTap: () => context.go(AppRoutes.studioCreate),
                ),
                ProfileGridTile(
                  title: '使用模板',
                  subtitle: '快速制作视频',
                  icon: Icons.auto_awesome_mosaic_outlined,
                  iconColor: AppColors.catViolet,
                  iconBackground: AppColors.catVioletBg,
                  onTap: () => context.push(AppRoutes.community),
                ),
                ProfileGridTile(
                  title: '导入素材',
                  subtitle: '导入本地文件',
                  icon: Icons.upload_file_outlined,
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  onTap: () => context.go(AppRoutes.studioCreate),
                ),
                ProfileGridTile(
                  title: 'AI 工具',
                  subtitle: '智能创作助手',
                  icon: Icons.auto_fix_high_outlined,
                  iconColor: AppColors.catPink,
                  iconBackground: AppColors.catPinkBg,
                  onTap: () => _comingSoon('AI 工具'),
                ),
              ],
            ),
            _section(
              title: '互动与服务',
              children: [
                ProfileGridTile(
                  title: '消息中心',
                  subtitle: '评论、点赞和通知',
                  icon: Icons.chat_bubble_outline,
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  onTap: () => _comingSoon('消息中心'),
                ),
                ProfileGridTile(
                  title: '点赞记录',
                  subtitle: '查看你点赞的内容',
                  icon: Icons.favorite_outline,
                  iconColor: AppColors.catPink,
                  iconBackground: AppColors.catPinkBg,
                  onTap: loggedIn
                      ? () => context.push(AppRoutes.profileLikes)
                      : () => context.go(
                            AppRoutes.loginWithRedirect(AppRoutes.profileLikes),
                          ),
                ),
                ProfileGridTile(
                  title: '关注动态',
                  subtitle: '关注用户的最新动态',
                  icon: Icons.people_outline,
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  onTap: () => context.push(AppRoutes.community),
                ),
                ProfileGridTile(
                  title: '帮助与反馈',
                  subtitle: '问题反馈与建议',
                  icon: Icons.headset_mic_outlined,
                  iconColor: AppColors.catOrange,
                  iconBackground: AppColors.catOrangeBg,
                  onTap: () => _comingSoon('帮助与反馈'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: SectionHeader(
                title: '设置',
                titleStyle: AppTextStyles.title.copyWith(fontSize: 16),
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  ListenableBuilder(
                    listenable: ThemeModeNotifier.instance,
                    builder: (context, _) => ProfileSettingsTile(
                      title: '外观设置',
                      subtitle: ThemeModeNotifier.labelFor(
                        ThemeModeNotifier.instance.themeMode,
                      ),
                      icon: Icons.dark_mode_outlined,
                      onTap: () => _showThemeSheet(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProfileSettingsTile(
                    title: '缓存管理',
                    subtitle: '清理缓存释放空间',
                    icon: Icons.delete_outline,
                    onTap: _clearCache,
                  ),
                  const SizedBox(height: 8),
                  ProfileSettingsTile(
                    title: '版本更新',
                    subtitle: _appVersion.isEmpty ? '检查更新' : 'v$_appVersion',
                    icon: Icons.system_update_alt_outlined,
                    onTap: _manualUpdate,
                  ),
                  const SizedBox(height: 8),
                  ProfileSettingsTile(
                    title: '关于 rc0',
                    subtitle: '了解更多关于我们',
                    icon: Icons.info_outline,
                    onTap: () => context.push(AppRoutes.profileAbout),
                  ),
                ],
              ),
            ),
            const ShellBottomSpacer(),
          ],
        ),
    );

    if (Breakpoints.isDesktop(context)) {
      return DesktopShellTabScaffold(appBar: appBar, body: body);
    }

    if (widget.embeddedInHub) {
      return Scaffold(body: body);
    }

    return Scaffold(appBar: appBar, body: body);
  }

  Widget _section({
    required String title,
    required List<Widget> children,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(
            title: title,
            action: actionLabel,
            onActionTap: onAction,
            showChevron: true,
            titleStyle: AppTextStyles.title.copyWith(fontSize: 16),
            actionStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          ),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.45,
            children: children,
          ),
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
}
