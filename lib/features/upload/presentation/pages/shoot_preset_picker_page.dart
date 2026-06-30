import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/preset_catalog.dart';
import '../../../../core/utils/state_listeners.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/glass/glass_sheet.dart';
import '../../../screenplay/data/shoot_preset_repository.dart';
import '../../../screenplay/domain/shoot_preset.dart';
import '../widgets/preset_marketplace_widgets.dart';
import '../widgets/shoot_preset_edit_sheet.dart';
enum ShootPresetPickerMode { select, manage }

enum _MarketTab { mine, official, community }

class ShootPresetPickerPage extends StatefulWidget {
  const ShootPresetPickerPage({
    super.key,
    required this.mode,
    this.scopeLabel,
  });

  final ShootPresetPickerMode mode;
  final String? scopeLabel;

  @override
  State<ShootPresetPickerPage> createState() => _ShootPresetPickerPageState();
}

class _ShootPresetPickerPageState extends State<ShootPresetPickerPage> {
  final _repo = ShootPresetRepository.instance;
  final _searchController = TextEditingController();
  _MarketTab _tab = _MarketTab.mine;
  String _categoryId = 'all';
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepoChanged);
    if (!_repo.isLoaded) {
      _repo.load();
    } else {
      _repo.refreshFromApi();
    }
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onRepoChanged() => scheduleSetState(this);

  bool get _isManage => widget.mode == ShootPresetPickerMode.manage;

  String get _title {
    if (_isManage) return '管理拍摄预设';
    return '选择参数';
  }

  void _applyPreset(ShootPreset preset) {
    if (_isManage) return;
    _repo.recordUsage(preset);
    context.pop(preset.params);
  }

  Future<void> _createPreset() async {
    final result = await ShootPresetEditSheet.show(
      context,
      mode: ShootPresetEditMode.create,
    );
    if (!mounted || result == null) return;
    if (!_isManage && result.params != null) {
      context.pop(result.params);
    }
  }

  Future<void> _editPreset(ShootPreset preset) async {
    final result = await ShootPresetEditSheet.show(
      context,
      mode: ShootPresetEditMode.edit,
      initialPreset: preset,
    );
    if (!mounted || result == null) return;
    if (!_isManage && result.params != null) {
      context.pop(result.params);
    }
  }

  Future<void> _deletePreset(ShootPreset preset) async {
    final confirmed = await showGlassDialog<bool>(
      context,
      child: GlassDialog(
        title: const Text('删除预设'),
        onClose: () => Navigator.pop(context, false),
        child: Text('确定删除「${preset.label}」？'),
        footer: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除'),
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await _repo.delete(preset.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  Future<void> _duplicatePreset(ShootPreset preset) async {
    final result = await _repo.duplicate(preset);
    if (!mounted) return;
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到我的预设')),
      );
    }
  }

  void _sharePreset(ShootPreset preset) {
    Share.share(
      '${preset.label}\n${preset.displaySubtitle}\n— 来自 rc0 拍摄预设',
      subject: preset.label,
    );
  }

  void _showComingSoon(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action 即将上线')),
    );
  }

  Future<void> _showMyPresetMenu(ShootPreset preset) async {
    final action = await showGlassSheet<String>(
      context,
      padding: kGlassSheetMenuPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('编辑'),
            onTap: () => Navigator.pop(context, 'edit'),
          ),
          ListTile(
            leading: const Icon(Icons.copy_outlined),
            title: const Text('复制'),
            onTap: () => Navigator.pop(context, 'duplicate'),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('分享'),
            onTap: () => Navigator.pop(context, 'share'),
          ),
          ListTile(
            leading: const Icon(Icons.cloud_upload_outlined),
            title: const Text('上传社区'),
            onTap: () => Navigator.pop(context, 'upload'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text('删除', style: TextStyle(color: AppColors.error)),
            onTap: () => Navigator.pop(context, 'delete'),
          ),
        ],
      ),
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'edit':
        await _editPreset(preset);
      case 'duplicate':
        await _duplicatePreset(preset);
      case 'share':
        _sharePreset(preset);
      case 'upload':
        _showComingSoon('上传社区');
      case 'delete':
        await _deletePreset(preset);
    }
  }

  bool _matchesQuery(ShootPreset preset) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return preset.label.toLowerCase().contains(q) ||
        preset.displaySubtitle.toLowerCase().contains(q) ||
        (preset.authorName?.toLowerCase().contains(q) ?? false) ||
        (preset.params.device?.toLowerCase().contains(q) ?? false);
  }

  bool _matchesCategory(ShootPreset preset) {
    if (_categoryId == 'all') return true;
    return preset.categoryId == _categoryId;
  }

  List<ShootPreset> _filter(List<ShootPreset> presets) {
    return presets
        .where((p) => _matchesQuery(p) && _matchesCategory(p))
        .toList(growable: false);
  }

  List<ShootPreset> get _recent =>
      _filter(_repo.recentPresets.isNotEmpty
          ? _repo.recentPresets
          : _repo.builtinPresets.take(3).toList());

  List<ShootPreset> get _myPresets => _filter(_repo.userPresets);

  List<ShootPreset> get _official => _filter(_repo.builtinPresets);

  List<ShootPreset> get _community => _filter(_repo.communityPresets);

  void _onTabChanged(int index) {
    setState(() => _tab = _MarketTab.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_repo.isLoaded && _repo.allPresets.isEmpty) {
      return DesktopStackScaffold(
        title: Text(_title),
        onBack: () => popOrGoStudio(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_isManage) {
      return _buildManageScaffold();
    }

    return DesktopStackScaffold(
      title: Text(_title),
      onBack: () => popOrGoStudio(context),
      centerTitle: false,
      body: Stack(
        children: [
          Column(
            children: [
              PresetMarketSearchBar(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim()),
              ),
              PresetMarketSegmentedTabs(
                selectedIndex: _tab.index,
                myCount: _repo.userPresets.length,
                onChanged: _onTabChanged,
              ),
              if (_repo.lastError != null)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMd,
                  ),
                  child: Text(
                    _repo.lastError!,
                    style: AppTextStyles.bodySecondary.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              Expanded(child: _buildTabBody()),
            ],
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: _createPreset,
              icon: const Icon(Icons.add),
              label: const Text('创建预设'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManageScaffold() {
    final user = _repo.userPresets;
    return DesktopStackScaffold(
      title: Text(_title),
      onBack: () => popOrGoStudio(context),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          if (_repo.lastError != null) ...[
            Text(
              _repo.lastError!,
              style: AppTextStyles.bodySecondary.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
          ],
          PresetCreateTile(onTap: _createPreset),
          const SizedBox(height: 8),
          for (final preset in user) ...[
            PresetMyRowCard(
              preset: preset,
              onTap: () => _editPreset(preset),
              onLongPress: () => _showMyPresetMenu(preset),
            ),
            const SizedBox(height: 8),
          ],
          if (user.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                '登录后可同步自定义预设到云端',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createPreset,
        icon: const Icon(Icons.add),
        label: const Text('创建预设'),
      ),
    );
  }

  Widget _buildTabBody() {
    return switch (_tab) {
      _MarketTab.mine => _buildMineMarketplace(),
      _MarketTab.official => _buildOfficialTab(),
      _MarketTab.community => _buildCommunityTab(),
    };
  }

  Widget _buildMineMarketplace() {
    return ListView(
      children: [
        if (_recent.isNotEmpty) ...[
          PresetSectionHeader(
            title: '最近使用',
            leadingIcon: Icons.star_rounded,
            trailingLabel: '全部 >',
            onTrailingTap: () => _onTabChanged(_MarketTab.official.index),
          ),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              itemCount: _recent.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (_, i) => PresetRecentCard(
                preset: _recent[i],
                onTap: () => _applyPreset(_recent[i]),
              ),
            ),
          ),
        ],
        PresetSectionHeader(
          title: '我的预设 (${_repo.userPresets.length})',
          trailingLabel: '管理',
          onTrailingTap: () => context.push(
            AppRoutes.shootPresetPicker(mode: 'manage'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
          ),
          child: Column(
            children: [
              PresetCreateTile(onTap: _createPreset),
              for (final preset in _myPresets.take(4)) ...[
                const SizedBox(height: 8),
                PresetMyRowCard(
                  preset: preset,
                  onTap: () => _applyPreset(preset),
                  onLongPress: () => _showMyPresetMenu(preset),
                ),
              ],
            ],
          ),
        ),
        if (_official.isNotEmpty) ...[
          PresetSectionHeader(
            title: '官方精选',
            trailingLabel: '查看更多 >',
            onTrailingTap: () => _onTabChanged(_MarketTab.official.index),
          ),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              itemCount: _official.length.clamp(0, 6),
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (_, i) => PresetOfficialCard(
                preset: _official[i],
                onTap: () => _applyPreset(_official[i]),
              ),
            ),
          ),
        ],
        if (_community.isNotEmpty) ...[
          PresetSectionHeader(
            title: '热门社区',
            trailingLabel: '查看更多 >',
            onTrailingTap: () => _onTabChanged(_MarketTab.community.index),
          ),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
              ),
              itemCount: _community.length.clamp(0, 6),
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppDimensions.spacingSm),
              itemBuilder: (_, i) => PresetCommunityCard(
                preset: _community[i],
                compact: true,
                onUse: () => _applyPreset(_community[i]),
                onFavorite: () => _showComingSoon('收藏'),
              ),
            ),
          ),
        ],
        const PresetSectionHeader(title: '分类浏览'),
        PresetCategoryChips(
          categories: PresetCatalog.categories,
          selectedId: _categoryId,
          onSelected: (id) => setState(() => _categoryId = id),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildOfficialTab() {
    final items = _official;
    if (items.isEmpty) {
      return _emptyState('暂无官方预设');
    }
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        PresetCategoryChips(
          categories: PresetCatalog.categories,
          selectedId: _categoryId,
          onSelected: (id) => setState(() => _categoryId = id),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        for (final preset in items) ...[
          PresetListTileCard(
            preset: preset,
            onTap: () => _applyPreset(preset),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
        ],
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _buildCommunityTab() {
    final items = _community;
    if (items.isEmpty) {
      return _emptyState('暂无社区预设');
    }
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      children: [
        PresetCategoryChips(
          categories: PresetCatalog.categories,
          selectedId: _categoryId,
          onSelected: (id) => setState(() => _categoryId = id),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        for (final preset in items) ...[
          PresetCommunityCard(
            preset: preset,
            onUse: () => _applyPreset(preset),
            onFavorite: () => _showComingSoon('收藏'),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
        ],
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodySecondary,
      ),
    );
  }
}

ShootPresetPickerMode parseShootPresetPickerMode(String? raw) {
  if (raw == 'manage') return ShootPresetPickerMode.manage;
  return ShootPresetPickerMode.select;
}

String scopeLabelForPicker({
  required String scope,
  int? actIndex,
  int? sceneIndex,
  int? frameIndex,
}) {
  return switch (scope) {
    'scene' => '第${(sceneIndex ?? 0) + 1}场',
    'frame' =>
      '第${(actIndex ?? 0) + 1}幕 · 第${(sceneIndex ?? 0) + 1}场 · 第${(frameIndex ?? 0) + 1}画',
    _ => '剧本默认',
  };
}
