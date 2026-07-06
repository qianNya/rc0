import 'package:flutter/material.dart';

/// Equipment room category — maps to top-level Room tabs.
enum GearRoomType {
  lighting,
  camera,
  lens,
  accessory;

  String get label => switch (this) {
        GearRoomType.lighting => '灯具',
        GearRoomType.camera => '相机',
        GearRoomType.lens => '镜头',
        GearRoomType.accessory => '配件',
      };

  IconData get icon => switch (this) {
        GearRoomType.lighting => Icons.lightbulb_outline,
        GearRoomType.camera => Icons.videocam_outlined,
        GearRoomType.lens => Icons.lens_outlined,
        GearRoomType.accessory => Icons.build_outlined,
      };

  IconData get selectedIcon => switch (this) {
        GearRoomType.lighting => Icons.lightbulb,
        GearRoomType.camera => Icons.videocam,
        GearRoomType.lens => Icons.lens,
        GearRoomType.accessory => Icons.build,
      };
}
