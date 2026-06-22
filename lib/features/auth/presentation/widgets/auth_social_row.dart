import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthSocialRow extends StatelessWidget {
  const AuthSocialRow({
    super.key,
    this.dividerText = '或使用其他方式登录',
    this.onTap,
  });

  final String dividerText;
  final VoidCallback? onTap;

  static const _providers = [
    ('Apple', Icons.apple),
    ('微信', Icons.chat_bubble_outline),
    ('QQ', Icons.forum_outlined),
    ('微博', Icons.public),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.border)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                dividerText,
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 12),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.border)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final p in _providers)
              _SocialButton(
                label: p.$1,
                icon: p.$2,
                onTap: onTap,
              ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
