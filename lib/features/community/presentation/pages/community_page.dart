import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/data/app_catalog.dart';
import '../../../../core/responsive/responsive_builder.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (_) => _CommunityMobileView(
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
      ),
      desktop: (_) => _CommunityDesktopView(
        selectedTab: _selectedTab,
        onTabChanged: (i) => setState(() => _selectedTab = i),
      ),
    );
  }
}

class _CommunityMobileView extends StatelessWidget {
  const _CommunityMobileView({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('社群话题', style: AppTextStyles.title),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppSearchField(hint: '搜索话题、讨论', onTap: () {}),
            ),
            const SizedBox(height: 12),
            _TabBar(selected: selectedTab, onChanged: onTabChanged),
            const SizedBox(height: 12),
            const Expanded(
              child: EmptyStateView(
                icon: Icons.forum_outlined,
                title: '社区即将开放',
                subtitle: '话题讨论与互动功能正在建设中',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityDesktopView extends StatelessWidget {
  const _CommunityDesktopView({
    required this.selectedTab,
    required this.onTabChanged,
  });

  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 220,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('社区话题', style: AppTextStyles.title),
                SizedBox(height: 16),
                Text(
                  '话题与讨论功能即将上线',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: EmptyStateView(
              icon: Icons.forum_outlined,
              title: '社区即将开放',
              subtitle: '话题讨论与互动功能正在建设中',
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppCatalog.communityTabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return TagChip(
            label: AppCatalog.communityTabs[index],
            selected: selected == index,
            onTap: () => onChanged(index),
          );
        },
      ),
    );
  }
}
