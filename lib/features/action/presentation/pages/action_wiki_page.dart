import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../studio/presentation/widgets/studio_editor_shell_glass_button.dart';
import '../../domain/action_wiki_item.dart';

class ActionWikiPage extends StatefulWidget {
  const ActionWikiPage({super.key, this.embeddedInHub = false});

  final bool embeddedInHub;

  @override
  State<ActionWikiPage> createState() => _ActionWikiPageState();
}

class _ActionWikiPageState extends State<ActionWikiPage> {
  final _searchController = TextEditingController();
  final _items = buildActionWikiItems();
  int _groupIndex = 0;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ActionWikiItem> get _filtered {
    final query = _searchController.text.trim();
    final group = actionWikiGroups[_groupIndex];
    return _items.where((item) {
      final matchesGroup = group == '全部' || item.group == group;
      final matchesQuery =
          query.isEmpty || item.label.contains(query) || item.group.contains(query);
      return matchesGroup && matchesQuery;
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = _filtered;

    return DesktopStackScaffold(
      title: const Text('动作'),
      onBack: widget.embeddedInHub ? null : () => popOrGoDiscovery(context),
      actions: [
        IconButton(
          tooltip: '拍摄预设',
          icon: const Icon(Icons.tune_outlined),
          onPressed: () => context.push(
            AppRoutes.shootPresetPicker(mode: 'manage', scope: 'action'),
          ),
        ),
      ],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: StudioEditorShellGlassButton(
          label: '预设库',
          icon: Icons.collections_outlined,
          minWidth: 120,
          onPressed: () => context.push(
            AppRoutes.shootPresetPicker(mode: 'manage', scope: 'action'),
          ),
        ),
      ),
      body: ColoredBox(
        color: isDark
            ? AppColors.characterBackgroundDark
            : Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
                AppDimensions.spacingMd,
                AppDimensions.spacingSm,
              ),
              child: SizedBox(
                height: 48,
                child: AppSearchField(
                  hint: '搜索动作、景别、运镜',
                  controller: _searchController,
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                ),
                itemCount: actionWikiGroups.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppDimensions.spacingSm),
                itemBuilder: (context, index) {
                  final selected = index == _groupIndex;
                  return FilterChip(
                    label: Text(actionWikiGroups[index]),
                    selected: selected,
                    onSelected: (_) => setState(() => _groupIndex = index),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? AppColors.accent : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Expanded(
              child: filtered.isEmpty
                  ? const EmptyStateView(
                      icon: Icons.accessibility_new_outlined,
                      title: '暂无匹配动作',
                      subtitle: '试试其他分类或关键词',
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimensions.spacingMd,
                        0,
                        AppDimensions.spacingMd,
                        AppDimensions.spacingLg,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: AppDimensions.spacingSm,
                        crossAxisSpacing: AppDimensions.spacingSm,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return _ActionCard(
                          item: item,
                          onTap: () => _showItemSheet(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemSheet(BuildContext context, ActionWikiItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(AppDimensions.spacingMd),
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        decoration: BoxDecoration(
          color: Theme.of(ctx).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.label, style: AppTextStyles.title.copyWith(fontSize: 18)),
            const SizedBox(height: 4),
            Text(item.group, style: AppTextStyles.bodySecondary),
            const SizedBox(height: AppDimensions.spacingMd),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(
                  AppRoutes.shootPresetPicker(mode: 'manage', scope: 'action'),
                );
              },
              child: const Text('在预设库中查看'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item, required this.onTap});

  final ActionWikiItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                child: const PoseCoverImage(aspectRatio: 1, iconSize: 36),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              item.group,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
