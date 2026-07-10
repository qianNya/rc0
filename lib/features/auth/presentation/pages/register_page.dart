import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/auth_providers.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../widgets/auth_footer_link.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_page_scaffold.dart';
import '../widgets/auth_social_row.dart';
import '../widgets/auth_text_field.dart';
import '../../../../shared/widgets/glass/glass.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, this.redirectFrom});

  final String? redirectFrom;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreed = false;

  static final _passwordPattern = RegExp(r'^[\w!@#$%^&*\-+=]{6,16}$');

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (username.isEmpty || password.isEmpty) {
      _showError('请输入用户名和密码');
      return;
    }
    if (!_passwordPattern.hasMatch(password)) {
      _showError('密码需为 6-16 位字母、数字或符号组合');
      return;
    }
    if (password != confirm) {
      _showError('两次输入的密码不一致');
      return;
    }
    if (!_agreed) {
      _showError('请先阅读并同意用户协议与隐私政策');
      return;
    }

    if (email.isNotEmpty && !email.contains('@')) {
      _showError('请输入有效的邮箱地址');
      return;
    }

    setState(() => _loading = true);
    final error = await ref.read(authRepositoryProvider).registerAndLogin(
      username: username,
      password: password,
      email: email.isEmpty ? null : email,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      _showError(error);
      return;
    }

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

  void _goLogin() {
    final from = widget.redirectFrom;
    if (from != null && from.isNotEmpty) {
      context.go(AppRoutes.loginWithRedirect(from));
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthPageScaffold(
      desktopTitle: '创建账号',
      onBack: _goLogin,
      onHelp: () => _showPlaceholder('帮助中心即将上线'),
      header: const AuthHeader(
        title: '创建账号',
        subtitle: '加入 rc0',
        tagline: '开启你的创作之旅',
        trailing: AuthHeaderAvatar(),
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
            controller: _emailController,
            hintText: '邮箱（选填）',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            hintText: '设置登录密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            helperText: '密码需为 6-16 位字母、数字或符号组合',
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
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmController,
            hintText: '确认登录密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirm,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 36,
                child: Checkbox(
                  value: _agreed,
                  activeColor: AppColors.accent,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _agreed = !_agreed),
                  child: Wrap(
                    children: [
                      const Text('我已阅读并同意', style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => _showPlaceholder('用户协议即将上线'),
                        child: const Text(
                          '《用户协议》',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                      const Text('和', style: TextStyle(fontSize: 12)),
                      GestureDetector(
                        onTap: () => _showPlaceholder('隐私政策即将上线'),
                        child: const Text(
                          '《隐私政策》',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GlassButton(
                filled: true,
                expand: true,
            label: '注册',
            loading: _loading,
            onPressed: _submit,
          ),
          const SizedBox(height: 24),
          AuthSocialRow(
            dividerText: '或使用其他方式注册',
            onTap: () => _showPlaceholder('第三方注册即将上线'),
          ),
        ],
      ),
      footer: AuthFooterLink(
        prefix: '已有账号？',
        linkText: '立即登录',
        onTap: _goLogin,
      ),
    );
  }
}
