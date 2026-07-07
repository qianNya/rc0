import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';

import '../../../../app/router/navigation_utils.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../data/auth_credentials_store.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_social_row.dart';
import '../widgets/auth_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key, this.redirectFrom});

  final String? redirectFrom;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final saved = await AuthCredentialsStore.loadSavedUsername();
    if (!mounted) return;
    setState(() {
      _rememberMe = saved.remember;
      if (saved.username != null) {
        _usernameController.text = saved.username!;
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('请输入用户名和密码');
      return;
    }

    setState(() => _loading = true);
    final error = await ref.read(authRepositoryProvider).login(
      username: username,
      password: password,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      return;
    }

    await AuthCredentialsStore.save(
      username: username,
      rememberMe: _rememberMe,
    );

    // Navigation is handled by [AppRouter._redirect] after auth state updates.
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showPlaceholder(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goRegister() {
    final from = widget.redirectFrom;
    if (from != null && from.isNotEmpty) {
      context.go(AppRoutes.registerWithRedirect(from));
    } else {
      context.go(AppRoutes.register);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      desktopTitle: '欢迎回来',
      onBack: () => popOrGoHome(context),
      onHelp: () => _showPlaceholder('帮助中心即将上线'),
      header: AuthHeader(
        title: '欢迎回来',
        leadingEmoji: '👋',
        subtitle: '登录 rc0',
        tagline: '用镜头记录美好，分享创意灵感',
        trailing: const AuthHeaderAvatar(
          assetPath: 'assets/branding/app_logo.png',
        ),
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _usernameController,
            hintText: '用户名',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            hintText: '请输入密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                height: 36,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: AppColors.accent,
                  onChanged: (v) =>
                      setState(() => _rememberMe = v ?? false),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: const Text('记住我', style: TextStyle(fontSize: 13)),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    _showPlaceholder('请联系管理员重置密码'),
                child: const Text('忘记密码？'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: '登录',
            isLoading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 24),
          AuthSocialRow(
            onTap: () => _showPlaceholder('第三方登录即将上线'),
          ),
        ],
      ),
      footer: AuthFooterLink(
        prefix: '还没有账号？',
        linkText: '立即注册',
        onTap: _goRegister,
      ),
    );
  }
}
