import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/fade_slide_tab_switcher.dart';
import '../../../../shared/widgets/wiki_mode_tag_app_bar.dart';
import '../../data/equipment_repository.dart';
import '../../data/equipment_setup_mapper.dart';
import '../../domain/equipment_category.dart';
import '../widgets/equipment_card.dart';
import '../widgets/equipment_wiki_app_bar.dart';

class MyEquipmentPage extends StatefulWidget {
  const MyEquipmentPage({super.key});

  @override
  State<MyEquipmentPage> createState() => _MyEquipmentPageState();
}

class _MyEquipmentPageState extends State<MyEquipmentPage> {
  final _repo = EquipmentRepository.instance;
  int _tabIndex = 0;
  bool _loading = true;

  static const _tabs = ['收藏机身', '收藏镜头', '我的组合'];

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

  @override
  Widget build(BuildContext context) {
    return WikiModeTagPageScaffold(
      appBar: EquipmentWikiAppBar(
        title: '我的设备',
        leading: WikiModeTagIconButton(
          icon: Icons.arrow_back,
          onPressed: () => popOrGoHome(context),
          tooltip: '返回',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const WikiModeTagToolbarInset(),
            WikiModeTagTabBar(
              tabs: _tabs,
              selectedIndex: _tabIndex,
              onChanged: (index) => setState(() => _tabIndex = index),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : FadeSlideIndexedStack(
                      index: _tabIndex,
                      children: [
                        _buildFavoriteBodies(),
                        _buildFavoriteLenses(),
                        _buildUserSetups(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteBodies() {
    final items = _repo.bodiesForCategory(EquipmentCategory.favorites);
    if (items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.videocam_outlined,
        title: '暂无收藏机身',
        subtitle: '在设备库中收藏机身',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final body = items[index];
        return EquipmentCard.body(
          body: body,
          favorite: true,
          onFavorite: () =>
              _repo.toggleFavorite(EquipmentItemKind.body, body.id),
          onTap: () => context.push(
            AppRoutes.equipmentDetailPath('body', body.id),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteLenses() {
    final items = _repo.lensesForCategory(EquipmentCategory.favorites);
    if (items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.lens_outlined,
        title: '暂无收藏镜头',
        subtitle: '在设备库中收藏镜头',
      );
    }
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: items.length,
      separatorBuilder: (_, _) =>
          const SizedBox(height: AppDimensions.spacingSm),
      itemBuilder: (context, index) {
        final lens = items[index];
        return EquipmentCard.lens(
          lens: lens,
          favorite: true,
          onFavorite: () =>
              _repo.toggleFavorite(EquipmentItemKind.lens, lens.id),
          onTap: () => context.push(
            AppRoutes.equipmentDetailPath('lens', lens.id),
          ),
        );
      },
    );
  }

  Widget _buildUserSetups() {
    final setups = _repo.userSetups;
    if (setups.isEmpty) {
      return const EmptyStateView(
        icon: Icons.tune_outlined,
        title: '暂无自定义组合',
        subtitle: '在摄影机控制浮层中保存组合',
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
          onTap: () => context.push(
            AppRoutes.equipmentDetailPath('setup', setup.id),
          ),
        );
      },
    );
  }
}
