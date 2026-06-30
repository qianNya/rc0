import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../api/feed/data/feed-api.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/glass/glass_empty_state.dart';
import '../../../../shared/widgets/glass/glass_search_scaffold.dart';
import '../../../../shared/widgets/inline_error_banner.dart';
import '../../data/search_repository.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _repo = SearchRepository.instance;
  final _controller = TextEditingController();
  static const _tabs = ['剧本', '角色', '图片', '用户'];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onRepoChanged() => scheduleSetState(this);

  void _submit(String q) => _repo.search(q);

  void _openResult(SearchResultItem item) {
    final id = item.id.toInt();
    switch (item.type) {
      case 'screenplay':
        context.push(AppRoutes.script(id.toString()));
      case 'character':
        context.push(AppRoutes.characterDetailPath(id));
      case 'image':
        context.push(AppRoutes.image(id.toString()));
      case 'user':
        context.push(AppRoutes.user(id));
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassSearchScaffold(
      hint: '搜索剧本、角色、图片…',
      controller: _controller,
      onChanged: (v) {
        if (v.trim().isEmpty) _repo.search('');
      },
      onSubmitted: _submit,
      tabLabels: _tabs,
      tabIndex: _repo.tabIndex,
      onTabChanged: _repo.setTab,
      onBack: () => context.pop(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_repo.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_repo.error != null) {
      return InlineErrorBanner(
        message: _repo.error!,
        onRetry: () => _repo.search(_repo.query),
      );
    }
    if (_repo.query.trim().isEmpty) {
      return const GlassEmptyState(
        icon: Icons.search_outlined,
        title: '输入关键词开始搜索',
        subtitle: '支持剧本、角色、图片与用户',
      );
    }
    final results = _repo.results;
    if (results.isEmpty) {
      return GlassEmptyState(
        icon: Icons.search_off_outlined,
        title: '未找到结果',
        subtitle: '尝试其他关键词或切换分类',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      itemCount: results.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final item = results[index];
        return GlassCard(
          onTap: () => _openResult(item),
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: AppTextStyles.label),
              if (item.subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: AppTextStyles.bodySecondary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}