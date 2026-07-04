import 'package:flutter/material.dart';

import '../../../../app/theme/app_dimensions.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../shared/widgets/glass/glass_card.dart';
import '../../domain/camera_body.dart';
import '../../domain/cine_camera_setup.dart';
import '../../domain/lens.dart';

class EquipmentCard extends StatelessWidget {
  const EquipmentCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.favorite = false,
    this.onTap,
    this.onFavorite,
  });

  factory EquipmentCard.body({
    required CameraBody body,
    bool favorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavorite,
  }) {
    return EquipmentCard(
      title: body.displayName,
      subtitle: '${body.brand} · ${body.mount}',
      favorite: favorite,
      onTap: onTap,
      onFavorite: onFavorite,
    );
  }

  factory EquipmentCard.lens({
    required Lens lens,
    bool favorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavorite,
  }) {
    return EquipmentCard(
      title: lens.displayName,
      subtitle: '${lens.brand} · ${lens.focalRange}',
      favorite: favorite,
      onTap: onTap,
      onFavorite: onFavorite,
    );
  }

  factory EquipmentCard.setup({
    required CineCameraSetup setup,
    required String summary,
    bool favorite = false,
    VoidCallback? onTap,
    VoidCallback? onFavorite,
  }) {
    return EquipmentCard(
      title: setup.title.isNotEmpty ? setup.title : summary,
      subtitle: summary,
      favorite: favorite,
      onTap: onTap,
      onFavorite: onFavorite,
    );
  }

  final String title;
  final String subtitle;
  final Widget? trailing;
  final bool favorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(subtitle, style: AppTextStyles.bodySecondary),
              ],
            ),
          ),
          if (onFavorite != null)
            IconButton(
              onPressed: onFavorite,
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
              ),
            ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
