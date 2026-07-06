import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../domain/feature_labs_catalog.dart';

class FeatureLabsPage extends StatefulWidget {
  const FeatureLabsPage({
    super.key,
    this.highlightFeatureId,
  });

  final String? highlightFeatureId;

  @override
  State<FeatureLabsPage> createState() => _FeatureLabsPageState();
}

class _FeatureLabsPageState extends State<FeatureLabsPage> {
  final _scrollController = ScrollController();
  final _featureKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToHighlight() {
    final id = widget.highlightFeatureId;
    if (id == null || id.isEmpty) return;
    final key = _featureKeys[id];
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      alignment: 0.1,
    );
  }

  GlobalKey _keyFor(String id) =>
      _featureKeys.putIfAbsent(id, GlobalKey.new);

  void _onEntryTap(FeatureLabsEntry entry) {
    final route = entry.route;
    if (route != null && route.isNotEmpty) {
      context.push(route);
      return;
    }
    showGlassDialog<void>(
      context,
      child: GlassDialog(
        title: Text(entry.title),
        child: Text(
          '${entry.subtitle}\n\n该功能正在建设中，敬请期待。',
          style: AppTextStyles.bodySecondary,
        ),
        footer: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingMd),
          child: Align(
            alignment: Alignment.centerRight,
            child: GlassButton(
              label: '知道了',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = FeatureLabsCatalog.groupedEntries();

    return DesktopStackScaffold(
      title: const Text('功能实验室'),
      onBack: () => popOrGoDiscovery(context),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.spacingMd,
          AppDimensions.spacingSm,
          AppDimensions.spacingMd,
          AppDimensions.spacingXl,
        ),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 4, 4, 16),
            child: Text(
              '预览中的能力会逐步开放；点击条目可查看说明或进入相关入口。',
              style: AppTextStyles.bodySecondary,
            ),
          ),
          for (final group in FeatureLabsCatalog.groups) ...[
            if ((grouped[group] ?? []).isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(group, style: AppTextStyles.title),
              ),
              for (final entry in grouped[group]!)
                Padding(
                  key: _keyFor(entry.id),
                  padding: const EdgeInsets.only(bottom: AppDimensions.spacingSm),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    onTap: () => _onEntryTap(entry),
                    child: GlassListRow(
                      leading: Icon(entry.icon),
                      title: entry.title,
                      subtitle: entry.subtitle,
                      trailing: _statusChip(entry.status),
                    ),
                  ),
                ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _statusChip(FeatureLabsStatus status) {
    final label = switch (status) {
      FeatureLabsStatus.preview => '预览',
      FeatureLabsStatus.comingSoon => '即将上线',
    };
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Text(label, style: AppTextStyles.caption),
    );
  }
}
