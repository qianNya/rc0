import 'package:flutter/material.dart';

import '../../domain/gear_cabinet.dart';
import '../theme/gear_cabinet_colors.dart';

/// Decorative wood cabinet frame with gold nameplate.
class GearWoodCabinetFrame extends StatelessWidget {
  const GearWoodCabinetFrame({
    super.key,
    required this.cabinet,
    required this.child,
    this.compact = false,
  });

  final GearCabinet cabinet;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final radius = compact ? 20.0 : 28.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            GearCabinetColors.woodLight,
            GearCabinetColors.woodDark,
            GearCabinetColors.woodGrain,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: GearCabinetColors.borderWood,
          width: compact ? 1.2 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: compact ? 12 : 24,
            offset: Offset(0, compact ? 6 : 12),
          ),
          BoxShadow(
            color: GearCabinetColors.spotlight,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius - 2),
        child: Stack(
          children: [
            // Wood grain lines
            Positioned.fill(
              child: CustomPaint(
                painter: _WoodGrainPainter(compact: compact),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: compact ? 28 : 40),
                Expanded(child: child),
                SizedBox(height: compact ? 8 : 12),
              ],
            ),
            Positioned(
              top: compact ? 6 : 10,
              left: 0,
              right: 0,
              child: Center(child: _Nameplate(label: cabinet.displayLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nameplate extends StatelessWidget {
  const _Nameplate({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8C96A),
            GearCabinetColors.nameplateGold,
            GearCabinetColors.nameplateGoldDim,
          ],
        ),
        border: Border.all(
          color: const Color(0xFF6B5520),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Color(0xFF2A1F0A),
          ),
        ),
      ),
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  _WoodGrainPainter({required this.compact});

  final bool compact;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: compact ? 0.06 : 0.08)
      ..strokeWidth = 1;

    for (var i = 0; i < (compact ? 6 : 10); i++) {
      final y = size.height * (0.1 + i * 0.09);
      final path = Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(
          size.width * 0.5,
          y + (i.isEven ? 3 : -3),
          size.width,
          y + (i.isEven ? 1 : -1),
        );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
