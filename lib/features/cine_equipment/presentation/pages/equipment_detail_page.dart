import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../data/equipment_repository.dart';
import '../../data/equipment_setup_mapper.dart';
import '../../domain/cine_camera_setup.dart';
import '../../domain/equipment_category.dart';

class EquipmentDetailPage extends StatefulWidget {
  const EquipmentDetailPage({
    super.key,
    required this.kind,
    required this.id,
  });

  final String kind;
  final String id;

  @override
  State<EquipmentDetailPage> createState() => _EquipmentDetailPageState();
}

class _EquipmentDetailPageState extends State<EquipmentDetailPage> {
  final _repo = EquipmentRepository.instance;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await _repo.load();
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return switch (widget.kind) {
      'body' => _buildBodyDetail(),
      'lens' => _buildLensDetail(),
      'setup' => _buildSetupDetail(),
      _ => DesktopStackScaffold(
          title: const Text('设备详情'),
          onBack: () => popOrGoHome(context),
          body: const EmptyStateView(
            icon: Icons.devices_other_outlined,
            title: '未找到设备',
            subtitle: '请返回设备库',
          ),
        ),
    };
  }

  Widget _buildBodyDetail() {
    final body = _repo.findBodyById(widget.id);
    if (body == null) {
      return DesktopStackScaffold(
        title: const Text('机身详情'),
        onBack: () => popOrGoHome(context),
        body: const EmptyStateView(
          icon: Icons.videocam_outlined,
          title: '未找到机身',
          subtitle: '请返回设备库',
        ),
      );
    }
    final fav = _repo.isFavorite(EquipmentItemKind.body, body.id);
    return _detailScaffold(
      title: Text(body.displayName),
      subtitle: '${body.brand} ${body.model} · ${body.mount} 卡口',
      promptHint: body.promptHint,
      favorite: fav,
      onFavorite: () => _repo.toggleFavorite(EquipmentItemKind.body, body.id),
    );
  }

  Widget _buildLensDetail() {
    final lens = _repo.findLensById(widget.id);
    if (lens == null) {
      return DesktopStackScaffold(
        title: const Text('镜头详情'),
        onBack: () => popOrGoHome(context),
        body: const EmptyStateView(
          icon: Icons.lens_outlined,
          title: '未找到镜头',
          subtitle: '请返回设备库',
        ),
      );
    }
    final fav = _repo.isFavorite(EquipmentItemKind.lens, lens.id);
    return _detailScaffold(
      title: Text(lens.displayName),
      subtitle: '${lens.brand} ${lens.model} · ${lens.focalRange}',
      promptHint: lens.promptHint,
      favorite: fav,
      onFavorite: () => _repo.toggleFavorite(EquipmentItemKind.lens, lens.id),
    );
  }

  Widget _buildSetupDetail() {
    final setup = _repo.findSetupById(widget.id);
    if (setup == null) {
      return DesktopStackScaffold(
        title: const Text('组合详情'),
        onBack: () => popOrGoHome(context),
        body: const EmptyStateView(
          icon: Icons.tune_outlined,
          title: '未找到组合',
          subtitle: '请返回设备库',
        ),
      );
    }
    final fav = _repo.isFavorite(EquipmentItemKind.setup, setup.id);
    return _detailScaffold(
      title: Text(
        setup.title.isNotEmpty
            ? setup.title
            : EquipmentSetupMapper.displaySummary(setup),
      ),
      subtitle: EquipmentSetupMapper.displaySummary(setup),
      promptHint: EquipmentSetupMapper.promptDescription(setup),
      favorite: fav,
      onFavorite: () =>
          _repo.toggleFavorite(EquipmentItemKind.setup, setup.id),
      onApply: () => context.pop<CineCameraSetup>(setup),
    );
  }

  Widget _detailScaffold({
    required Widget title,
    required String subtitle,
    required String promptHint,
    required bool favorite,
    required VoidCallback onFavorite,
    VoidCallback? onApply,
  }) {
    return DesktopStackScaffold(
      title: title,
      onBack: () => popOrGoHome(context),
      actions: [
        IconButton(
          onPressed: onFavorite,
          icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        children: [
          Text(subtitle, style: AppTextStyles.body),
          const SizedBox(height: AppDimensions.spacingLg),
          Text('Prompt 片段', style: AppTextStyles.label),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            promptHint.isNotEmpty ? promptHint : '暂无',
            style: AppTextStyles.bodySecondary,
          ),
          if (onApply != null) ...[
            const SizedBox(height: AppDimensions.spacingXl),
            FilledButton(
              onPressed: onApply,
              child: const Text('应用此组合'),
            ),
          ],
        ],
      ),
    );
  }
}
