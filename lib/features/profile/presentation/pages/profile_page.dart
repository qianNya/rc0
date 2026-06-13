import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/domain/screenplay/screenplay.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../screenplay/data/screenplay_local_repository.dart';
import '../../../screenplay/presentation/widgets/screenplay_delete_actions.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/rc0_widgets.dart';
import '../../../../shared/widgets/screenplay_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _repository = ScreenplayLocalRepository.instance;
  int _desktopTab = 0;

  @override
  void initState() {
    super.initState();
    _repository.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _repository.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() => setState(() {});

  Future<void> _deleteScript(Screenplay script) async {
    final confirmed = await confirmDeleteScreenplay(
      context,
      title: script.title,
    );
    if (!confirmed || !mounted) return;

    await _repository.delete(script.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('剧本已删除')));
  }

  @override
  Widget build(BuildContext context) {
    final scripts = _repository.localScreenplays;

    return ResponsiveBuilder(
      mobile: (_) => _ProfileMobileView(
        scripts: scripts,
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
      desktop: (_) => _ProfileDesktopView(
        scripts: scripts,
        selectedTab: _desktopTab,
        onTabChanged: (i) => setState(() => _desktopTab = i),
        onDelete: _deleteScript,
        onUpload: () => context.go(AppRoutes.upload),
      ),
    );
  }
}

class _ProfileMobileView extends StatelessWidget {
  const _ProfileMobileView({
    required this.scripts,
    required this.onDelete,
    required this.onUpload,
  });

  final List<Screenplay> scripts;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final recent = scripts.take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const _ProfileHeader(compact: true),
              const SizedBox(height: 20),
              _StatsRow(works: scripts.length),
              const SizedBox(height: 20),
              for (final item in AppCatalog.profileMenuItems)
                _MenuTile(
                  label: item,
                  onTap: () => _handleMenuTap(context, item),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(
                    child: Text('我的剧本', style: AppTextStyles.label),
                  ),
                  if (scripts.isNotEmpty)
                    TextButton(
                      onPressed: onUpload,
                      child: const Text('上传'),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                EmptyStateView(
                  icon: Icons.folder_open_outlined,
                  title: '暂无剧本',
                  subtitle: '上传后会显示在这里',
                  actionLabel: '去上传',
                  onAction: onUpload,
                )
              else
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: recent.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final script = recent[index];
                      return GestureDetector(
                        onTap: () =>
                            context.push(AppRoutes.script(script.id)),
                        child: SizedBox(
                          width: 80,
                          child: PoseCoverImage(
                            imagePath: script.coverImagePath,
                            aspectRatio: 1,
                            iconSize: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuTap(BuildContext context, String item) {
    switch (item) {
      case '我的收藏':
        context.go(AppRoutes.favorites);
      case '我的上传':
        context.go(AppRoutes.upload);
      case '设置':
        break;
      default:
        break;
    }
  }
}

class _ProfileDesktopView extends StatelessWidget {
  const _ProfileDesktopView({
    required this.scripts,
    required this.selectedTab,
    required this.onTabChanged,
    required this.onDelete,
    required this.onUpload,
  });

  final List<Screenplay> scripts;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;
  final Future<void> Function(Screenplay) onDelete;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: _ProfileHeader(compact: false)),
                SecondaryButton(
                  label: '上传剧本',
                  isExpanded: false,
                  onPressed: onUpload,
                ),
              ],
            ),
            const SizedBox(height: 20),
            _StatsRow(works: scripts.length),
            const SizedBox(height: 24),
            Row(
              children: [
                for (var i = 0; i < 2; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TagChip(
                      label: ['我的剧本', '收藏'][i],
                      selected: selectedTab == i,
                      onTap: () => onTabChanged(i),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedTab == 0)
              scripts.isEmpty
                  ? EmptyStateView(
                      icon: Icons.folder_open_outlined,
                      title: '暂无剧本',
                      subtitle: '上传参考图，创建你的第一部剧本',
                      actionLabel: '上传剧本',
                      onAction: onUpload,
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            Breakpoints.gridColumns(context, desktop: 4),
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: scripts.length,
                      itemBuilder: (_, index) {
                        final script = scripts[index];
                        return ScreenplayCard(
                          screenplay: script,
                          compact: true,
                          onDelete: () => onDelete(script),
                        );
                      },
                    )
            else
              const EmptyStateView(
                icon: Icons.favorite_border,
                title: '暂无收藏',
                subtitle: '收藏功能即将上线',
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return const Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.placeholder,
            child: Icon(Icons.person, size: 32),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本地创作者', style: AppTextStyles.title),
                SizedBox(height: 4),
                Text('管理你的剧本与参考图'),
              ],
            ),
          ),
        ],
      );
    }

    return const Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.placeholder,
          child: Icon(Icons.person, size: 40),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本地创作者', style: AppTextStyles.display),
            SizedBox(height: 4),
            Text('管理你的剧本与参考图'),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.works});

  final int works;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              Text('$works', style: AppTextStyles.title),
              const SizedBox(height: 2),
              Text('剧本', style: AppTextStyles.bodySecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }
}
