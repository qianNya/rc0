import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/ip_repository.dart';
import '../../domain/ip_entry.dart';

class IpDetailPage extends StatefulWidget {
  const IpDetailPage({super.key, required this.ipId});

  final int ipId;

  @override
  State<IpDetailPage> createState() => _IpDetailPageState();
}

class _IpDetailPageState extends State<IpDetailPage> {
  final _repo = IpRepository.instance;
  final _auth = AuthRepository.instance;
  IpEntry? _entry;
  bool _loading = true;
  String? _error;
  bool _deleting = false;

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
    final result = await _repo.fetchDetail(widget.ipId);
    if (!mounted) return;
    setState(() {
      _entry = result.ip;
      _error = result.error;
      _loading = false;
    });
  }

  Future<void> _confirmDelete() async {
    final entry = _entry;
    if (entry == null || _deleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除 IP'),
        content: Text('确定删除「${entry.title}」？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);
    final error = await _repo.delete(entry.id);
    if (!mounted) return;
    setState(() => _deleting = false);

    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entry;
    final secondary =
        Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.textSecondary;
    final canEdit = _auth.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry?.title.isNotEmpty == true ? entry!.title : 'IP 详情'),
        actions: [
          if (entry != null && canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: '编辑',
              onPressed: () async {
                await context.push(AppRoutes.ipEditPath(entry.id));
                if (mounted) _load();
              },
            ),
          if (entry != null && canEdit)
            IconButton(
              icon: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline),
              tooltip: '删除',
              onPressed: _deleting ? null : _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : entry == null
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.2),
                    EmptyStateView(
                      icon: Icons.hub_outlined,
                      title: _error != null ? '加载失败' : 'IP 不存在',
                      subtitle: _error,
                      actionLabel: _error != null ? '重试' : null,
                      onAction: _error != null ? _load : null,
                    ),
                  ],
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppDimensions.spacingMd),
                    children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.placeholderDark,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_stories_outlined,
                          size: 48,
                          color: AppColors.textTertiaryDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingMd),
                    Text(entry.title, style: AppTextStyles.title),
                    const SizedBox(height: 8),
                    Text(
                      AppCatalog.ipWorkTypeLabel(entry.workType),
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (entry.releaseYear > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '年份 ${entry.releaseYear}',
                        style: AppTextStyles.bodySecondary,
                      ),
                    ],
                    if (entry.summary.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(entry.summary, style: AppTextStyles.body),
                    ],
                    const SizedBox(height: AppDimensions.spacingLg),
                    Text('人物', style: AppTextStyles.label),
                    const SizedBox(height: 8),
                    Text(
                      '人物列表将在后端 character API 接入后展示',
                      style: TextStyle(fontSize: 13, color: secondary),
                    ),
                  ],
                ),
                ),
    );
  }
}
