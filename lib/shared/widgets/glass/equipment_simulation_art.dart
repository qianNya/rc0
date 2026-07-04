import 'package:flutter/material.dart';

import '../../../features/cine_equipment/domain/equipment_category.dart';

/// Side-view equipment silhouettes for carousel pickers (no Material icons).
abstract final class EquipmentSimulationArt {
  static Widget cameraBody({
    EquipmentCategory? category,
    String? deviceName,
    bool compact = false,
  }) {
    return CustomPaint(
      size: Size(compact ? 52 : 58, compact ? 34 : 40),
      painter: _CameraBodyPainter(
        variant: _bodyVariant(category, deviceName),
      ),
    );
  }

  static Widget lens({bool compact = false}) {
    return CustomPaint(
      size: Size(compact ? 54 : 60, compact ? 28 : 32),
      painter: const _LensPainter(),
    );
  }

  static _BodyVariant _bodyVariant(
    EquipmentCategory? category,
    String? deviceName,
  ) {
    final name = deviceName?.toLowerCase() ?? '';
    if (name.contains('iphone') || name.contains('手机')) {
      return _BodyVariant.phone;
    }
    if (category == EquipmentCategory.cinema ||
        name.contains('arri') ||
        name.contains('red') ||
        name.contains('flex')) {
      return _BodyVariant.cinema;
    }
    if (category == EquipmentCategory.vintage || name.contains('bolex')) {
      return _BodyVariant.vintage;
    }
    return _BodyVariant.mirrorless;
  }
}

enum _BodyVariant { cinema, mirrorless, phone, vintage }

class _CameraBodyPainter extends CustomPainter {
  const _CameraBodyPainter({required this.variant});

  final _BodyVariant variant;

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF3A3A3C)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF636366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final detail = Paint()
      ..color = const Color(0xFF48484A)
      ..style = PaintingStyle.fill;

    switch (variant) {
      case _BodyVariant.cinema:
        _paintCinema(canvas, size, fill, stroke, detail);
      case _BodyVariant.mirrorless:
        _paintMirrorless(canvas, size, fill, stroke, detail);
      case _BodyVariant.phone:
        _paintPhone(canvas, size, fill, stroke, detail);
      case _BodyVariant.vintage:
        _paintVintage(canvas, size, fill, stroke, detail);
    }
  }

  void _paintCinema(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.22, size.width * 0.72, size.height * 0.52),
      const Radius.circular(4),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    final mag = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.02, size.height * 0.3, size.width * 0.14, size.height * 0.36),
      const Radius.circular(3),
    );
    canvas.drawRRect(mag, fill);
    canvas.drawRRect(mag, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.48),
      size.height * 0.16,
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.84, size.height * 0.48),
      size.height * 0.16,
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.12, size.width * 0.22, size.height * 0.12),
      detail,
    );
  }

  void _paintMirrorless(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.24, size.width * 0.62, size.height * 0.5),
      const Radius.circular(5),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.49),
      size.height * 0.17,
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.49),
      size.height * 0.17,
      stroke,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.24, size.height * 0.14, size.width * 0.18, size.height * 0.12),
        const Radius.circular(2),
      ),
      detail,
    );
  }

  void _paintPhone(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.28, size.height * 0.06, size.width * 0.38, size.height * 0.88),
      const Radius.circular(8),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.2),
      size.width * 0.055,
      detail,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.36, size.height * 0.72, size.width * 0.22, size.height * 0.05),
        const Radius.circular(3),
      ),
      detail,
    );
  }

  void _paintVintage(
    Canvas canvas,
    Size size,
    Paint fill,
    Paint stroke,
    Paint detail,
  ) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.1, size.height * 0.3, size.width * 0.55, size.height * 0.42),
      const Radius.circular(3),
    );
    canvas.drawRRect(body, fill);
    canvas.drawRRect(body, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.5),
      size.height * 0.18,
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.5),
      size.height * 0.18,
      stroke,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.18, size.height * 0.18, size.width * 0.12, size.height * 0.16),
      detail,
    );
  }

  @override
  bool shouldRepaint(covariant _CameraBodyPainter oldDelegate) =>
      oldDelegate.variant != variant;
}

class _LensPainter extends CustomPainter {
  const _LensPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()
      ..color = const Color(0xFF48484A)
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = const Color(0xFF636366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final ring = Paint()
      ..color = const Color(0xFF3A3A3C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final barrel = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.08, size.height * 0.28, size.width * 0.72, size.height * 0.44),
      const Radius.circular(6),
    );
    canvas.drawRRect(barrel, fill);
    canvas.drawRRect(barrel, stroke);

    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.5),
      size.height * 0.28,
      fill,
    );
    canvas.drawCircle(
      Offset(size.width * 0.86, size.height * 0.5),
      size.height * 0.28,
      ring,
    );

    for (var i = 0; i < 3; i++) {
      final y = size.height * (0.36 + i * 0.12);
      canvas.drawLine(
        Offset(size.width * 0.14, y),
        Offset(size.width * 0.62, y),
        stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
