import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.tagline,
    this.leadingEmoji,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? tagline;
  final String? leadingEmoji;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leadingEmoji != null ? '$title $leadingEmoji' : title,
                style: AppTextStyles.title.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.title.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
              if (tagline != null) ...[
                const SizedBox(height: 8),
                Text(
                  tagline!,
                  style: AppTextStyles.bodySecondary.copyWith(fontSize: 13),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 12),
          trailing!,
        ],
      ],
    );
  }
}

class AuthHeaderAvatar extends StatelessWidget {
  const AuthHeaderAvatar({super.key, this.assetPath});

  final String? assetPath;

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return CircleAvatar(
        radius: 36,
        backgroundColor: AppColors.accentLight,
        backgroundImage: AssetImage(assetPath!),
      );
    }
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.accentLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.camera_alt_outlined,
        size: 32,
        color: AppColors.accent,
      ),
    );
  }
}
