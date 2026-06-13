import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/empty_state_view.dart';
import '../../../../shared/widgets/rc0_widgets.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(
            Breakpoints.isDesktop(context) ? 32 : 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: '我的收藏'),
              const SizedBox(height: 16),
              const Expanded(
                child: EmptyStateView(
                  icon: Icons.favorite_border,
                  title: '暂无收藏',
                  subtitle: '收藏功能即将上线，届时可在此查看收藏的剧本',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
