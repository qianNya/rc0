import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/widgets/pose_cover_image.dart';
import '../../../screenplay/domain/shoot_preset.dart';

const _coverPalettes = <List<Color>>[
  [Color(0xFF3B4A6B), Color(0xFF1A1F2E)],
  [Color(0xFF5A3FD4), Color(0xFF2D1B69)],
  [Color(0xFF2E5C8A), Color(0xFF1A3A5C)],
  [Color(0xFF8B5A2B), Color(0xFF4A3018)],
  [Color(0xFF2D6A4F), Color(0xFF1B4332)],
  [Color(0xFF9B2335), Color(0xFF5C1520)],
  [Color(0xFF4A5568), Color(0xFF2D3748)],
  [Color(0xFF6B4FE0), Color(0xFF3D2F6B)],
];

List<Color> presetCoverGradient(ShootPreset preset) {
  final hash = preset.id.hashCode ^ preset.label.hashCode;
  return _coverPalettes[hash.abs() % _coverPalettes.length];
}

class PresetCover extends StatelessWidget {
  const PresetCover({
    super.key,
    required this.preset,
    this.height,
    this.expand = false,
    this.borderRadius = 0,
    this.showIcon = true,
  });

  final ShootPreset preset;
  final double? height;
  final bool expand;
  final double borderRadius;
  final bool showIcon;

  IconData get _icon {
    final label = preset.label;
    if (label.contains('人像') || label.contains('写真')) {
      return Icons.face_retouching_natural_outlined;
    }
    if (label.contains('电影') || label.contains('宽幅')) {
      return Icons.movie_filter_outlined;
    }
    if (label.contains('Vlog') || label.contains('竖屏') || label.contains('手机')) {
      return Icons.smartphone_outlined;
    }
    if (label.contains('胶片') || label.contains('富士')) {
      return Icons.camera_roll_outlined;
    }
    return Icons.photo_camera_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final colors = presetCoverGradient(preset);
    final imageUrl = preset.coverImageUrl;

    Widget child;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      child = PoseCoverImage(
        imagePath: imageUrl,
        expand: expand,
        borderRadius: borderRadius,
      );
    } else {
      child = Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: showIcon
            ? Center(
                child: Icon(
                  _icon,
                  size: expand ? 48 : 36,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              )
            : null,
      );
    }

    if (height != null) {
      child = SizedBox(height: height, child: child);
    }

    if (borderRadius > 0) {
      child = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: child,
      );
    }

    return child;
  }
}

class PresetOfficialBadge extends StatelessWidget {
  const PresetOfficialBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '官方',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}
