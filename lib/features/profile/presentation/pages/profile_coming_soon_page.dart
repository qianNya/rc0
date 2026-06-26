import 'package:flutter/material.dart';

import '../../../../core/responsive/breakpoints.dart';
import '../../../../shared/widgets/desktop_shell_app_bar.dart';
import '../../../../shared/widgets/empty_state_view.dart';

class ProfileComingSoonPage extends StatelessWidget {
  const ProfileComingSoonPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final appBar = DesktopShellAppBar(
      title: Text(title),
      automaticallyImplyLeading: false,
    );

    if (Breakpoints.isDesktop(context)) {
      return DesktopShellTabScaffold(
        appBar: appBar,
        body: EmptyStateView(
          icon: Icons.construction_outlined,
          title: '即将上线',
          subtitle: '$title 功能正在建设中',
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: EmptyStateView(
        icon: Icons.construction_outlined,
        title: '即将上线',
        subtitle: '$title 功能正在建设中',
      ),
    );
  }
}
