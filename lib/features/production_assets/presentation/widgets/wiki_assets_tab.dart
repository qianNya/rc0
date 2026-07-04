import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../../../shared/widgets/shell_insets.dart';
import '../../data/asset_catalog.dart';
import '../../data/asset_repository.dart';
import '../../domain/user_asset_category.dart';
import '../../domain/user_asset_item.dart';
import 'asset_form_sheets.dart';

/// Which slice of the assets catalog to show.
enum AssetsTabSection { all, builtin, custom }

/// Wiki hub「资产」tab / shell assets hub body — built-in domains + user CRUD.
class WikiAssetsTab extends StatefulWidget {
  const WikiAssetsTab({
    super.key,
    this.section = AssetsTabSection.all,
    this.showHeader = true,
    this.embeddedInShell = false,
  });

  final AssetsTabSection section;
  final bool showHeader;
  final bool embeddedInShell;

  @override
  State<WikiAssetsTab> createState() => _WikiAssetsTabState();
}

class _WikiAssetsTabState extends State<WikiAssetsTab> {
  final _repo = AssetRepository.instance;
  String? _expandedCategoryId;

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _repo.load().then((_) {
      if (mounted) _repo.refreshFromApi();
    });
  }

  Future<void> _onRefresh() => _repo.refreshFromApi();

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  void _openDomain(WikiAssetDomain domain) {
    if (domain.usePush) {
      context.push(domain.route);
      return;
    }
    context.go(domain.route);
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      _expandedCategoryId =
          _expandedCategoryId == categoryId ? null : categoryId;
    });
  }

  Future<void> _confirmDeleteCategory(UserAssetCategory category) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除「${category.label}」及其下所有资产？'),
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
    if (ok != true || !mounted) return;
    final error = await _repo.deleteUserCategory(category.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _confirmDeleteItem(UserAssetItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除资产'),
        content: Text('确定删除「${item.name}」？'),
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
    if (ok != true || !mounted) return;
    await _repo.deleteItem(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final showBuiltin = widget.section == AssetsTabSection.all ||
        widget.section == AssetsTabSection.builtin;
    final showCustom = widget.section == AssetsTabSection.all ||
        widget.section == AssetsTabSection.custom;

    final topPadding = widget.embeddedInShell
        ? 0.0
        : MediaQuery.paddingOf(context).top + AppDimensions.spacingSm;

    return ColoredBox(
      color: Colors.transparent,
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            widget.embeddedInShell ? 0 : AppDimensions.spacingMd,
            topPadding,
            widget.embeddedInShell ? 0 : AppDimensions.spacingMd,
            ShellInsets.scrollBottom(
              context,
              extra: widget.embeddedInShell
                  ? AppDimensions.spacingSm
                  : AppDimensions.spacingMd,
            ),
          ),
          children: [
            if (widget.showHeader) ...[
              Text('资产', style: AppTextStyles.title.copyWith(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                '摄影设备、灯具与自定义制片资产',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
            ],
            if (showBuiltin) ...[
              if (widget.section == AssetsTabSection.all) ...[
                Text('内置库', style: AppTextStyles.label.copyWith(fontSize: 14)),
                const SizedBox(height: AppDimensions.spacingSm),
              ],
              for (final domain in _repo.builtinDomains) ...[
                _DomainCard(
                  domain: domain,
                  isDark: isDark,
                  itemCount: domain.acceptsUserItems
                      ? _repo.itemsForCategory(domain.categoryRef.id).length
                      : 0,
                  expanded: _expandedCategoryId == domain.categoryRef.id,
                  items: domain.acceptsUserItems
                      ? _repo.itemsForCategory(domain.categoryRef.id)
                      : const [],
                  onOpen: () => _openDomain(domain),
                  onToggleItems: domain.acceptsUserItems
                      ? () => _toggleCategory(domain.categoryRef.id)
                      : null,
                  onAddItem: domain.acceptsUserItems
                      ? () => showAssetItemSheet(
                            context,
                            categoryId: domain.categoryRef.id,
                          )
                      : null,
                  onEditItem: (item) => showAssetItemSheet(
                    context,
                    categoryId: domain.categoryRef.id,
                    existing: item,
                  ),
                  onDeleteItem: _confirmDeleteItem,
                ),
                const SizedBox(height: AppDimensions.spacingSm),
              ],
            ],
            if (showCustom) ...[
              if (widget.section == AssetsTabSection.all)
                const SizedBox(height: AppDimensions.spacingSm),
              Row(
                children: [
                  if (widget.section != AssetsTabSection.custom)
                    Expanded(
                      child: Text(
                        '自定义分类',
                        style: AppTextStyles.label.copyWith(fontSize: 14),
                      ),
                    )
                  else
                    const Spacer(),
                  TextButton.icon(
                    onPressed: () => showAssetCategorySheet(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('新建分类'),
                  ),
                ],
              ),
              if (_repo.userCategories.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingMd,
                  ),
                  child: Text(
                    '添加轨道、摇臂等自定义分类',
                    style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                  ),
                )
              else
                for (final category in _repo.userCategories) ...[
                  _UserCategorySection(
                    category: category,
                    isDark: isDark,
                    expanded: _expandedCategoryId == category.id,
                    items: _repo.itemsForCategory(category.id),
                    onToggle: () => _toggleCategory(category.id),
                    onEdit: () => showAssetCategorySheet(
                      context,
                      existing: category,
                    ),
                    onDelete: () => _confirmDeleteCategory(category),
                    onAddItem: () => showAssetItemSheet(
                      context,
                      categoryId: category.id,
                    ),
                    onEditItem: (item) => showAssetItemSheet(
                      context,
                      categoryId: category.id,
                      existing: item,
                    ),
                    onDeleteItem: _confirmDeleteItem,
                  ),
                  const SizedBox(height: AppDimensions.spacingSm),
                ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DomainCard extends StatelessWidget {
  const _DomainCard({
    required this.domain,
    required this.isDark,
    required this.itemCount,
    required this.expanded,
    required this.items,
    required this.onOpen,
    this.onToggleItems,
    this.onAddItem,
    this.onEditItem,
    this.onDeleteItem,
  });

  final WikiAssetDomain domain;
  final bool isDark;
  final int itemCount;
  final bool expanded;
  final List<UserAssetItem> items;
  final VoidCallback onOpen;
  final VoidCallback? onToggleItems;
  final VoidCallback? onAddItem;
  final void Function(UserAssetItem item)? onEditItem;
  final Future<void> Function(UserAssetItem item)? onDeleteItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: isDark
              ? AppColors.surfaceSecondaryDark
              : AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: InkWell(
            onTap: onOpen,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? domain.iconColor.withValues(alpha: 0.18)
                          : domain.backgroundColor,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusMd,
                      ),
                    ),
                    child: Icon(domain.icon, color: domain.iconColor, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          domain.label,
                          style: AppTextStyles.label.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          domain.subtitle,
                          style: AppTextStyles.bodySecondary.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onToggleItems != null && itemCount > 0)
                    TextButton(
                      onPressed: onToggleItems,
                      child: Text(expanded ? '收起' : '$itemCount 项'),
                    ),
                  Icon(Icons.chevron_right, color: AppColors.textTertiary),
                ],
              ),
            ),
          ),
        ),
        if (expanded && onAddItem != null) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          _AssetItemsPanel(
            items: items,
            onAdd: onAddItem!,
            onEdit: onEditItem!,
            onDelete: onDeleteItem!,
          ),
        ],
      ],
    );
  }
}

class _UserCategorySection extends StatelessWidget {
  const _UserCategorySection({
    required this.category,
    required this.isDark,
    required this.expanded,
    required this.items,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
  });

  final UserAssetCategory category;
  final bool isDark;
  final bool expanded;
  final List<UserAssetItem> items;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddItem;
  final void Function(UserAssetItem item) onEditItem;
  final Future<void> Function(UserAssetItem item) onDeleteItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GlassCard(
          onTap: onToggle,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  category.label,
                  style: AppTextStyles.label.copyWith(fontSize: 15),
                ),
              ),
              Text(
                '${items.length} 项',
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit();
                    case 'delete':
                      onDelete();
                    case 'add':
                      onAddItem();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'add', child: Text('添加资产')),
                  PopupMenuItem(value: 'edit', child: Text('编辑分类')),
                  PopupMenuItem(value: 'delete', child: Text('删除分类')),
                ],
              ),
            ],
          ),
        ),
        if (expanded) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          _AssetItemsPanel(
            items: items,
            onAdd: onAddItem,
            onEdit: onEditItem,
            onDelete: onDeleteItem,
          ),
        ],
      ],
    );
  }
}

class _AssetItemsPanel extends StatelessWidget {
  const _AssetItemsPanel({
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<UserAssetItem> items;
  final VoidCallback onAdd;
  final void Function(UserAssetItem item) onEdit;
  final Future<void> Function(UserAssetItem item) onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('添加'),
          ),
        ),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.spacingSm,
            ),
            child: Text(
              '暂无资产，点击添加',
              style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
            ),
          )
        else
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spacingXs),
              child: GlassCard(
                onTap: () => onEdit(item),
                padding: const EdgeInsets.all(AppDimensions.spacingMd),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.label),
                          if (item.displaySubtitle.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.displaySubtitle,
                              style: AppTextStyles.bodySecondary.copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '删除',
                      onPressed: () => onDelete(item),
                      icon: const Icon(Icons.delete_outline, size: 20),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
