import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../core/domain/screenplay/screenplay_display.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/feed_grid_skeleton.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass_screenplay_row.dart';
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

    return DesktopStackScaffold(
      title: const Text('点赞记录'),
      onBack: () => popOrGoDiscovery(context),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Padding(
                padding: EdgeInsets.all(AppDimensions.spacingMd),
                child: FeedGridSkeleton(tileCount: 5),
              )
            : items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                      GlassEmptyState(
                        icon: Icons.thumb_up_off_alt_outlined,
                        title: _error != null ? '加载失败' : '暂无点赞',
                        subtitle: _error ?? '你点赞的剧本会显示在这里',
                        actionLabel: _error != null ? '重试' : '去社区看看',
                        onAction: _error != null
                            ? _load
                            : () => context.go(AppRoutes.discoveryTemplate),
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    itemCount: items.length + (_error != null ? 1 : 0),
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppDimensions.spacingSm),
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
                      return GlassScreenplayRow(
                        title: title,
                        subtitle: like.createAt,
                        imagePath: screenplay?.effectiveCoverImagePath,
                        onTap: () => context.push(AppRoutes.script('$spId')),
                      );
                    },
                  ),
      ),
    );
  }
}
