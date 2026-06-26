import 'package:flutter/material.dart';

import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import '../../../../shared/widgets/empty_state_view.dart';

class ProfileComingSoonPage extends StatelessWidget {
  const ProfileComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DesktopShellAppBar(title: Text(title)),
      body: EmptyStateView(
        icon: Icons.construction_outlined,
        title: '即将上线',
        subtitle: '$title 功能正在建设中',
      ),
    );
  }
}
