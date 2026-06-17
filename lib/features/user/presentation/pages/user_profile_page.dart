import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../api/admin/api/admin_api_ext.dart' as admin_api;
import '../../../../api/admin/data/admin-api.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../social/data/social_repository.dart';
import '../../../user/data/user_profile_repository.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/feed_card.dart';
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
  final _social = SocialRepository.instance;

  PublicUserProfile? _profile;
  List<Screenplay> _screenplays = [];
  bool _loading = true;
  String? _error;
  bool _followBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final profile = await _userRepo.fetchPublicProfile(widget.userId);
    final scripts = await _fetchUserScreenplays(widget.userId);
    if (!mounted) return;
    setState(() {
      _profile = profile;
      _screenplays = scripts.items;
      _loading = false;
      _error = profile == null ? '用户不存在' : scripts.error;
    });
  }

  Future<({List<Screenplay> items, String? error})> _fetchUserScreenplays(
    int userId,
  ) async {
    final completer = Completer<({List<Screenplay> items, String? error})>();
    await admin_api.listUserScreenplays(
      userId,
      ok: (resp) {
        final list = resp.list;
        final items = list
            .map(
              (b) => Screenplay(
                id: b.id.toString(),
                title: b.title,
                coverUrl: b.coverUrl.isNotEmpty ? b.coverUrl : null,
                author: b.creatorNickname.isNotEmpty ? b.creatorNickname : '创作者',
                ownerUserId: b.creatorId.toInt(),
                likes: b.likeCount.toInt(),
                views: b.viewCount.toInt(),
                isLocal: false,
                remoteScreenplayId: b.id.toInt(),
              ),
            )
            .toList();
        completer.complete((items: items, error: null as String?));
      },
      fail: (msg) => completer.complete((items: <Screenplay>[], error: msg)),
    );
    return completer.future;
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
      _profile = PublicUserProfile(
        id: _profile!.id,
        username: _profile!.username,
        nickname: _profile!.nickname,
        avatar: _profile!.avatar,
        bio: _profile!.bio,
        level: _profile!.level,
        followerCount: _profile!.followerCount +
            (_profile!.isFollowing ? -1 : 1),
        followingCount: _profile!.followingCount,
        totalLikes: _profile!.totalLikes,
        screenplayCount: _profile!.screenplayCount,
        isFollowing: !_profile!.isFollowing,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_profile == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('用户主页')),
        body: EmptyStateView(
          icon: Icons.person_off_outlined,
          title: _error ?? '加载失败',
          subtitle: '请稍后重试',
        ),
      );
    }

    final p = _profile!;
    final name = p.nickname.isNotEmpty ? p.nickname : p.username;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ProfileGradientHeader(
              name: name,
              bio: p.bio.isNotEmpty ? p.bio : '@${p.username}',
              avatarUrl: p.avatar.isNotEmpty ? p.avatar : null,
              level: p.level.toInt(),
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
              works: p.screenplayCount.toInt(),
              following: p.followingCount.toInt(),
              followers: p.followerCount.toInt(),
              likes: p.totalLikes.toInt(),
            ),
            const SizedBox(height: 24),
            Text('作品', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (_screenplays.isEmpty)
              const EmptyStateView(
                icon: Icons.movie_outlined,
                title: '暂无公开作品',
              )
            else
              ..._screenplays.map(
                (s) => FeedCard(screenplay: s),
              ),
          ],
        ),
      ),
    );
  }
}
