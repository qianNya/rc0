import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../data/screenplay_like_repository.dart';

class ProfileLikesPage extends StatefulWidget {
  const ProfileLikesPage({super.key});

  @override
  State<ProfileLikesPage> createState() => _ProfileLikesPageState();
}

class _ProfileLikesPageState extends State<ProfileLikesPage> {
  final _repo = ScreenplayLikeRepository.instance;
  bool _loading = true;
  String? _error;

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
    final result = await _repo.fetchLikes();
    if (!mounted) return;
    setState(() {
      _error = result.error;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _repo.items;

    return Scaffold(
      appBar: AppBar(title: const Text('点赞记录')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      EmptyStateView(
                        icon: Icons.thumb_up_off_alt_outlined,
                        title: _error != null ? '加载失败' : '暂无点赞',
                        subtitle: _error ?? '你点赞的剧本会显示在这里',
                        actionLabel:
                            _error != null ? '重试' : '去社区看看',
                        onAction: _error != null
                            ? _load
                            : () => context.push(AppRoutes.community),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length + (_error != null ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      if (_error != null && i == 0) {
                        return InlineErrorBanner(
                          message: _error!,
                          onRetry: _load,
                        );
                      }
                      final index = _error != null ? i - 1 : i;
                      final like = items[index];
                      final spId = like.screenplayId.toInt();
                      final screenplay = _repo.screenplayFor(spId);
                      final title = screenplay?.title.isNotEmpty == true
                          ? screenplay!.title
                          : '剧本 #$spId';
                      return ListTile(
                        tileColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        leading: CircleAvatar(
                          backgroundImage: screenplay?.coverUrl != null
                              ? NetworkImage(screenplay!.coverUrl!)
                              : null,
                          child: screenplay?.coverUrl == null
                              ? const Icon(Icons.movie_outlined, size: 20)
                              : null,
                        ),
                        title: Text(title),
                        subtitle: Text(like.createAt),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(AppRoutes.script('$spId')),
                      );
                    },
                  ),
      ),
    );
  }
}
