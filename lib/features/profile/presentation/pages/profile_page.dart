import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/feed_tab_bar.dart';
import '../../../../shared/widgets/profile_widgets.dart';
import '../../../../shared/widgets/screenplay_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repository = ScreenplayLocalRepository.instance;
  final _auth = AuthRepository.instance;
  final _userProfile = UserProfileRepository.instance;
  int _selectedTab = 0;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
    _auth.addListener(_onDataChanged);
    _userProfile.addListener(_onDataChanged);
    if (_auth.isLoggedIn) {
      _userProfile.refreshMyStats();
    }
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = info.version);
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
            final statusText = percent != null
                ? '正在下载… $percent%'
                : '正在下载…';

            return AlertDialog(
              title: const Text('手动更新'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(statusText),
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('已打开安装界面，请按提示完成更新')),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(result.error ?? '更新失败')),
        );
    }
  }

  Widget _updateFooter({Widget? primaryFooter}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (primaryFooter != null) ...[
          primaryFooter,
          const SizedBox(height: 12),
        ],
        TextButton.icon(
          onPressed: _manualUpdate,
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
          icon: const Icon(Icons.system_update, size: 18),
          label: Text(
            _appVersion.isEmpty ? '手动更新' : '手动更新 · v$_appVersion',
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    _auth.removeListener(_onDataChanged);
    _userProfile.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    context.go(AppRoutes.explore);
  }

  ProfileHeaderData _headerData() {
    final profile = _auth.profile;
    if (!_auth.isLoggedIn || profile == null) {
      return ProfileHeaderData(
        name: '未登录',
        bio: '登录后查看个人资料',
        footer: _updateFooter(
          primaryFooter: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () async {
                  if (_auth.isLoggedIn && _auth.profile == null) {
                    await _auth.handleUnauthorized();
                  }
                  if (!mounted) return;
                  context.go(AppRoutes.loginWithRedirect(AppRoutes.profile));
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                child: const Text('登录'),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => context.go(AppRoutes.register),
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: const Text('注册'),
              ),
            ],
          ),
        ),
      );
    }

    final displayName =
        profile.nickname.isNotEmpty ? profile.nickname : profile.username;
    final bio = profile.bio.isNotEmpty
        ? profile.bio
        : (profile.email.isNotEmpty ? profile.email : '@${profile.username}');
    final works = profile.screenplayCount.toInt() > 0
        ? profile.screenplayCount.toInt()
        : _repository.localScreenplays.length;

    return ProfileHeaderData(
      name: displayName,
      bio: bio,
      avatarUrl: profile.avatar.isNotEmpty ? profile.avatar : null,
      works: works,
      following: profile.followingCount.toInt(),
      followers: profile.followerCount.toInt(),
      totalLikes: profile.totalLikes.toInt(),
      footer: _updateFooter(
        primaryFooter: TextButton.icon(
          onPressed: _logout,
          style: TextButton.styleFrom(foregroundColor: Colors.white70),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('退出登录'),
        ),
      ),
    );
  }

  Future<void> _deleteScript(Screenplay script) async {
    final confirmed = await confirmDeleteScreenplay(
      context,
      title: script.title,
    );
    if (!confirmed || !mounted) return;

    final result = await _repository.deleteScreenplay(script.id);
    if (!mounted) return;
    if (result.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('剧本已删除')));
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(result.error ?? '删除失败，请重试')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scripts = _repository.localScreenplays;
    final header = _headerData();

    return ResponsiveBuilder(
      mobile: (_) => _ProfileMobileView(
        header: header,
        scripts: scripts,
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
      desktop: (_) => _ProfileDesktopView(
        header: header,
        scripts: scripts,
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
    );
  }
}

class ProfileHeaderData {
  const ProfileHeaderData({
    required this.name,
    required this.bio,
    this.avatarUrl,
    this.footer,
    this.works = 0,
    this.following = 0,
    this.followers = 0,
    this.totalLikes = 0,
  });

  final String name;
  final String bio;
  final String? avatarUrl;
  final Widget? footer;
  final int works;
  final int following;
  final int followers;
  final int totalLikes;
}

class _ProfileMobileView extends StatelessWidget {
  const _ProfileMobileView({
    required this.header,
    required this.scripts,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final ProfileHeaderData header;
  final List<Screenplay> scripts;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: ProfileGradientHeader(
              name: header.name,
              bio: header.bio,
              avatarUrl: header.avatarUrl,
              footer: header.footer,
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StatBar(
                works: header.works,
                following: header.following,
                followers: header.followers,
                likes: header.totalLikes,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FeedTabBar(
              tabs: AppCatalog.profileTabs,
              selectedIndex: selectedTab,
              onChanged: onTabChanged,
              underlineStyle: true,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          if (selectedTab == 0)
            scripts.isEmpty
                ? const SliverFillRemaining(
                    child: EmptyStateView(
                      icon: Icons.folder_open_outlined,
                      title: '暂无作品',
                      subtitle: '创作后会显示在这里',
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.68,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final script = scripts[index];
                          return ScreenplayCard(
                            screenplay: script,
                            compact: true,
                            onDelete: () => onDelete(script),
                          );
                        },
                        childCount: scripts.length,
                      ),
                    ),
                  )
          else
            const SliverFillRemaining(
              child: EmptyStateView(
                icon: Icons.construction_outlined,
                title: '即将上线',
                subtitle: '该分类正在建设中',
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

class _ProfileDesktopView extends StatelessWidget {
  const _ProfileDesktopView({
    required this.header,
    required this.scripts,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final ProfileHeaderData header;
  final List<Screenplay> scripts;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileGradientHeader(
              name: header.name,
              bio: header.bio,
              avatarUrl: header.avatarUrl,
              footer: header.footer,
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatBar(
                          works: header.works,
                          following: header.following,
                          followers: header.followers,
                          likes: header.totalLikes,
                        ),
                      ),
                      const SizedBox(width: 24),
                      ElevatedButton.icon(
                        onPressed: onUpload,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('创作'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  FeedTabBar(
                    tabs: AppCatalog.profileTabs,
                    selectedIndex: selectedTab,
                    onChanged: onTabChanged,
                    underlineStyle: true,
                  ),
                  const SizedBox(height: 20),
                  if (selectedTab == 0)
                    scripts.isEmpty
                        ? const EmptyStateView(
                            icon: Icons.folder_open_outlined,
                            title: '暂无作品',
                            subtitle: '点击右上角开始创作',
                          )
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount:
                                  Breakpoints.gridColumns(context, desktop: 4),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            itemCount: scripts.length,
                            itemBuilder: (_, index) {
                              final script = scripts[index];
                              return ScreenplayCard(
                                screenplay: script,
                                compact: true,
                                onDelete: () => onDelete(script),
                              );
                            },
                          )
                  else
                    const EmptyStateView(
                      icon: Icons.construction_outlined,
                      title: '即将上线',
                      subtitle: '该分类正在建设中',
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
