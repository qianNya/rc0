import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../data/equipment_repository.dart';
import '../../data/equipment_setup_mapper.dart';
import '../../domain/equipment_brand.dart';
import '../../domain/equipment_category.dart';
import '../widgets/equipment_card.dart';
import '../widgets/equipment_glass_filter_chips.dart';
import '../widgets/equipment_wiki_app_bar.dart';

class EquipmentHubPage extends StatefulWidget {
  const EquipmentHubPage({
    super.key,
    this.applyScope = EquipmentApplyScope.browse,
    this.initialSetupId,
    this.actIndex,
    this.sceneIndex,
    this.frameIndex,
  });

  final EquipmentApplyScope applyScope;
  final String? initialSetupId;
  final int? actIndex;
  final int? sceneIndex;
  final int? frameIndex;

  @override
  State<EquipmentHubPage> createState() => _EquipmentHubPageState();
}

enum EquipmentApplyScope { browse, apply }

class _EquipmentHubPageState extends State<EquipmentHubPage> {
  final _repo = EquipmentRepository.instance;
  int _tabIndex = 0;
  int _categoryIndex = 0;
  int _brandIndex = 0;
  bool _loading = true;

  static const _tabs = ['机身', '镜头', '组合'];
  static const _categories = [
    EquipmentCategory.cinema,
    EquipmentCategory.photo,
    EquipmentCategory.vintage,
  ];

  @override
  void initState() {
    super.initState();
    _repo.addListener(_onRepo);
    _load();
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepo);
    super.dispose();
  }

  void _onRepo() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  EquipmentCategory get _category => _categories[_categoryIndex];

  EquipmentItemKind get _itemKind =>
      _tabIndex == 0 ? EquipmentItemKind.body : EquipmentItemKind.lens;

  List<EquipmentBrand> get _brands => _repo.brandsFor(
        category: _category,
        itemKind: _itemKind,
      );

  String? get _selectedBrandId {
    final brands = _brands;
    if (brands.isEmpty) return null;
    final index = _brandIndex.clamp(0, brands.length - 1);
    return brands[index].id;
  }

  @override
  Widget build(BuildContext context) {
    return WikiModeTagPageScaffold(
      appBar: EquipmentWikiAppBar(
        leading: WikiModeTagIconButton(
          icon: Icons.arrow_back,
          onPressed: () => popOrGoHome(context),
          tooltip: '返回',
        ),
        actions: [
          WikiModeTagIconButton(
            icon: Icons.refresh_rounded,
            onPressed: _loading ? null : () => _repo.refreshFromApi(),
            tooltip: '刷新',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: WikiModeTagIconButton(
              icon: Icons.folder_outlined,
              onPressed: () => context.push(AppRoutes.myEquipment),
              tooltip: '我的设备',
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          0,
          AppDimensions.spacingMd,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            WikiModeTagTabBar(
              tabs: _tabs,
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() {
                _tabIndex = index;
                _brandIndex = 0;
              }),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            if (_tabIndex < 2) _buildTaxonomyFilters(),
            if (_repo.lastError != null)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: AppDimensions.spacingXs,
                ),
                child: Text(
                  _repo.lastError!,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeSlideIndexedStack(
                      index: _tabIndex,
                      children: [
                        _buildBodyList(),
                        _buildLensList(),
                        _buildSetupList(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxonomyFilters() {
    final brands = _brands;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EquipmentGlassFilterChips(
          labels: _categories.map((c) => c.label).toList(growable: false),
          selectedIndex: _categoryIndex,
          onChanged: (index) => setState(() {
            _categoryIndex = index;
            _brandIndex = 0;
          }),
        ),
        if (brands.isNotEmpty) ...[
          EquipmentGlassFilterChips(
            labels: brands.map((b) => b.name).toList(growable: false),
            selectedIndex: _brandIndex.clamp(0, brands.length - 1),
            onChanged: (index) => setState(() => _brandIndex = index),
          ),
        ],
      ],
    );
  }

  Widget _buildBodyList() {
    final items = _repo.bodiesForCategory(
      _category,
      brandId: _selectedBrandId,
    );
    if (items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.videocam_outlined,
        title: '暂无机身',
        subtitle: '切换分类或品牌试试',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final body = items[index];
        final fav = _repo.isFavorite(EquipmentItemKind.body, body.id);
        return EquipmentCard.body(
          body: body,
          favorite: fav,
          onFavorite: () =>
              _repo.toggleFavorite(EquipmentItemKind.body, body.id),
          onTap: () => context.push(
            AppRoutes.equipmentDetailPath('body', body.id),
          ),
        );
      },
    );
  }

  Widget _buildLensList() {
    final items = _repo.lensesForCategory(
      _category,
      brandId: _selectedBrandId,
    );
    if (items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.lens_outlined,
        title: '暂无镜头',
        subtitle: '切换分类或品牌试试',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final lens = items[index];
        final fav = _repo.isFavorite(EquipmentItemKind.lens, lens.id);
        return EquipmentCard.lens(
          lens: lens,
          favorite: fav,
          onFavorite: () =>
              _repo.toggleFavorite(EquipmentItemKind.lens, lens.id),
          onTap: () => context.push(
            AppRoutes.equipmentDetailPath('lens', lens.id),
          ),
        );
      },
    );
  }

  Widget _buildSetupList() {
    final setups = _repo.allSetups;
    if (setups.isEmpty) {
      return const EmptyStateView(
        icon: Icons.tune_outlined,
        title: '暂无组合',
        subtitle: '在出图流程中保存摄影机组合',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: setups.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final setup = setups[index];
        final fav = _repo.isFavorite(EquipmentItemKind.setup, setup.id);
        return EquipmentCard.setup(
          setup: setup,
          summary: EquipmentSetupMapper.displaySummary(setup),
          favorite: fav,
          onFavorite: () =>
              _repo.toggleFavorite(EquipmentItemKind.setup, setup.id),
          onTap: () {
            if (widget.applyScope == EquipmentApplyScope.apply) {
              context.pop(setup);
              return;
            }
            context.push(AppRoutes.equipmentDetailPath('setup', setup.id));
          },
        );
      },
    );
  }
}
