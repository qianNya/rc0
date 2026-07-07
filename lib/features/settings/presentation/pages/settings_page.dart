import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../app/providers/auth_providers.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_dimensions.dart';
import '../../../../shared/widgets/desktop/desktop_stack_scaffold.dart';
import '../../../../shared/widgets/glass/glass.dart';
import '../../../../shared/widgets/theme_mode_selector.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _showAppearanceSheet() async {
    await showGlassSheet(
      context,
      child: const ThemeModeSelector(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final auth = ref.read(authRepositoryProvider);

    return DesktopStackScaffold(
      title: const Text('设置'),
      onBack: () => context.pop(),
      body: ListView(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        children: [
          GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                GlassListRow(
                  title: '外观',
                  subtitle: '浅色 / 深色 / 跟随系统',
                  leading: const Icon(Icons.palette_outlined),
                  iconColor: AppColors.catPurple,
                  iconBackground: AppColors.catPurpleBg,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: _showAppearanceSheet,
                ),
                GlassListRow(
                  title: '账号',
                  subtitle: session.isLoggedIn
                      ? (session.displayName ?? '已登录')
                      : '未登录',
                  leading: const Icon(Icons.person_outline),
                  iconColor: AppColors.catBlue,
                  iconBackground: AppColors.catBlueBg,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push(
                    session.isLoggedIn
                        ? AppRoutes.profileEdit
                        : AppRoutes.login,
                  ),
                  showDivider: true,
                ),
                GlassListRow(
                  title: '关于',
                  subtitle: _version.isEmpty ? 'rc0' : '版本 $_version',
                  leading: const Icon(Icons.info_outline),
                  iconColor: AppColors.catGreen,
                  iconBackground: AppColors.catGreenBg,
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onTap: () => context.push(AppRoutes.profileAbout),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          if (session.isLoggedIn)
            GlassButton(
              label: '退出登录',
              filled: false,
              onPressed: () async {
                await auth.logout();
                if (context.mounted) context.go(AppRoutes.discovery);
              },
            ),
        ],
      ),
    );
  }
}
