import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(prefix, style: AppTextStyles.bodySecondary),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
