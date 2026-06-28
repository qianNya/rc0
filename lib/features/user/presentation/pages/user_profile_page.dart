import 'package:flutter/material.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../social/data/social_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../../user/data/user_screenplays_repository.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../../../shared/widgets/explore_feed_tile.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/profile_widgets.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key, required this.userId});

  final int userId;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _userRepo = UserProfileRepository.instance;
  final _screenplays = UserScreenplaysRepository.instance;
  final _social = SocialRepository.instance;

  UserProfileSummary? _profile;
  bool _loading = true;
  String? _profileError;
  String? _worksError;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _screenplays.addListener(_onScreenplaysChanged);
    _load();
  }

  @override
  void dispose() {
    _screenplays.removeListener(_onScreenplaysChanged);
    super.dispose();
  }

  void _onScreenplaysChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _profileError = null;
      _worksError = null;
    });
    final profile = await _userRepo.fetchPublicProfile(widget.userId);
    await _screenplays.loadFirstPage(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _loading = false;
      _profileError = profile == null ? '用户不存在' : null;
      _worksError = _screenplays.errorFor(widget.userId);
    });
  }

  bool get _isSelf {
    final me = AuthRepository.instance.profile;
    return me != null && me.id.toInt() == widget.userId;
  }

  Future<void> _toggleFollow() async {
    if (_profile == null || _isSelf || _followBusy) return;
    setState(() => _followBusy = true);
    final err = _profile!.isFollowing
        ? await _social.unfollowUser(widget.userId)
        : await _social.followUser(widget.userId);
    if (!mounted) return;
    setState(() => _followBusy = false);
    if (err != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    setState(() {
      _profile = _profile!.copyWith(
        followerDelta: _profile!.isFollowing ? -1 : 1,
        isFollowing: !_profile!.isFollowing,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return DesktopStackScaffold(
        title: const Text('用户主页'),
        onBack: () => popOrGoDiscovery(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null) {
      return DesktopStackScaffold(
        title: const Text('用户主页'),
        onBack: () => popOrGoDiscovery(context),
        body: EmptyStateView(
          icon: Icons.person_off_outlined,
          title: _profileError ?? '加载失败',
          subtitle: '请稍后重试',
          actionLabel: '重试',
          onAction: _load,
        ),
      );
    }

    final screenplays = _screenplays.itemsFor(widget.userId);

    final p = _profile!;
    final name = p.nickname.isNotEmpty ? p.nickname : p.username;

    return DesktopStackScaffold(
      title: Text(name),
      onBack: () => popOrGoDiscovery(context),
      centerTitle: false,
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          children: [
            ProfileGradientHeader(
              name: name,
              bio: p.bio.isNotEmpty ? p.bio : '@${p.username}',
              avatarUrl: p.avatar.isNotEmpty ? p.avatar : null,
              level: p.level,
              footer: _isSelf
                  ? null
                  : PrimaryButton(
                      label: _followBusy
                          ? '处理中…'
                          : (p.isFollowing ? '已关注' : '关注'),
                      onPressed: _followBusy ? null : _toggleFollow,
                    ),
            ),
            const SizedBox(height: 16),
            StatBar(
              works: p.screenplayCount,
              following: p.followingCount,
              followers: p.followerCount,
              likes: p.totalLikes,
            ),
            const SizedBox(height: 24),
            Text('作品', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_worksError != null)
              InlineErrorBanner(message: _worksError!, onRetry: _load),
            if (screenplays.isEmpty && _worksError == null)
              const EmptyStateView(
                icon: Icons.movie_outlined,
                title: '暂无公开作品',
              )
            else
              ...screenplays.map(
                (s) => ExploreFeedTile(screenplay: s),
              ),
          ],
        ),
      ),
    );
  }
}
