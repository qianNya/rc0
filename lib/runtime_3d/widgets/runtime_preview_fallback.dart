import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_dimensions.dart';
import '../../app/theme/app_text_styles.dart';
import '../../features/action/presentation/models/action_model_source.dart';
import '../contracts/pose_contract.dart';

/// Shown when Unity Player is not linked — explains why the viewport is empty
/// and renders a 2D schematic so the page is not a blank black box.
class RuntimePreviewFallback extends StatelessWidget {
  const RuntimePreviewFallback({
    super.key,
    this.model,
    this.poseMode = ModelPoseMode.standing,
    this.backgroundColor = const Color(0xFF121018),
    this.compact = false,
  });

  final ActionModelSource? model;
  final ModelPoseMode poseMode;
  final Color backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _PreviewSchematicPainter(
              accent: AppColors.accent,
              hasModel: model?.canRender == true,
            ),
          ),
          if (!compact)
            Positioned(
              left: AppDimensions.spacingMd,
              right: AppDimensions.spacingMd,
              bottom: AppDimensions.spacingMd,
              child: _SetupCard(model: model, poseMode: poseMode),
            ),
        ],
      ),
    );
  }
}

class _SetupCard extends StatelessWidget {
  const _SetupCard({required this.model, required this.poseMode});

  final ActionModelSource? model;
  final ModelPoseMode poseMode;

  @override
  Widget build(BuildContext context) {
    final modelLine = model == null
        ? '尚未选择模型'
        : '${model!.name} · ${model!.extension.toUpperCase()} · ${model!.sizeLabel}';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.view_in_ar_outlined,
                  size: 20,
                  color: AppColors.accent.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Unity 3D 尚未链接',
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              modelLine,
              style: AppTextStyles.caption.copyWith(color: Colors.white70),
            ),
            if (model?.canRender == true) ...[
              const SizedBox(height: 4),
              Text(
                '姿态预览：${poseMode.label}（2D 占位，非实时 3D）',
                style: AppTextStyles.caption.copyWith(color: Colors.white54),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              'macOS：运行 scripts/link_unity_macos.sh 后 flutter run -d macos\n'
              'iOS：需导出 UnityFramework.framework（不是 .app）\n'
              '详见 packages/rc0_unity_widget/README.md',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white54,
                height: 1.45,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewSchematicPainter extends CustomPainter {
  _PreviewSchematicPainter({
    required this.accent,
    required this.hasModel,
  });

  final Color accent;
  final bool hasModel;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1A1824),
          const Color(0xFF0E0C12),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    const step = 32.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final center = Offset(size.width / 2, size.height * 0.52);
    final bodyColor = hasModel
        ? accent.withValues(alpha: 0.55)
        : Colors.white.withValues(alpha: 0.15);

    // Floor ellipse
    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 72),
        width: 120,
        height: 28,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );

    // Simple mannequin
    final headR = 22.0;
    canvas.drawCircle(
      center + const Offset(0, -58),
      headR,
      Paint()..color = bodyColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 52, height: 88),
        const Radius.circular(18),
      ),
      Paint()..color = bodyColor,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(-38, 8),
          width: 22,
          height: 64,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = bodyColor.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center + const Offset(38, 8),
          width: 22,
          height: 64,
        ),
        const Radius.circular(10),
      ),
      Paint()..color = bodyColor.withValues(alpha: 0.85),
    );

    if (!hasModel) {
      final tp = TextPainter(
        text: TextSpan(
          text: '选择或导入模型',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.35),
            fontSize: 13,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        center + Offset(-tp.width / 2, 100),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PreviewSchematicPainter oldDelegate) =>
      oldDelegate.hasModel != hasModel || oldDelegate.accent != accent;
}
