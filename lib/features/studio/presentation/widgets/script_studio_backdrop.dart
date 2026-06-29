import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'script_studio_theme.dart';

/// Procedural nebula backdrop for Script Studio.
class ScriptStudioBackdrop extends StatelessWidget {
  const ScriptStudioBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: ScriptStudioColors.background,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0C0618),
            ScriptStudioColors.nebulaDeep,
            Color(0xFF0A1428),
            ScriptStudioColors.background,
          ],
          stops: [0, 0.35, 0.72, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _NebulaOrb(
            top: -0.08,
            left: -0.15,
            size: 0.75,
            colors: [
              ScriptStudioColors.nebulaMagenta.withValues(alpha: 0.55),
              ScriptStudioColors.nebulaPurple.withValues(alpha: 0.2),
              Colors.transparent,
            ],
          ),
          _NebulaOrb(
            top: 0.12,
            right: -0.2,
            size: 0.65,
            colors: [
              ScriptStudioColors.nebulaBlue.withValues(alpha: 0.45),
              Color(0xFF2A4A9A).withValues(alpha: 0.15),
              Colors.transparent,
            ],
          ),
          _NebulaOrb(
            bottom: 0.05,
            left: 0.1,
            size: 0.9,
            colors: [
              ScriptStudioColors.accentGlow.withValues(alpha: 0.18),
              ScriptStudioColors.nebulaPurple.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, 0.85),
                radius: 1.1,
                colors: [
                  Colors.black.withValues(alpha: 0),
                  Colors.black.withValues(alpha: 0.35),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NebulaOrb extends StatelessWidget {
  const _NebulaOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.colors,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final diameter = math.max(w, h) * size;

        return Positioned(
          top: top != null ? h * top! : null,
          bottom: bottom != null ? h * bottom! : null,
          left: left != null ? w * left! : null,
          right: right != null ? w * right! : null,
          child: IgnorePointer(
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: colors),
              ),
            ),
          ),
        );
      },
    );
  }
}
