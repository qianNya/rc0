import 'package:flutter/material.dart';

import 'gear_device_status.dart';
import 'gear_room_type.dart';

class GearDevice {
  const GearDevice({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.roomType,
    this.imageUrl,
    this.icon,
    this.status = GearDeviceStatus.available,
    this.tags = const [],
    this.notes,
    this.specs = const {},
  });

  final String id;
  final String name;
  final String brand;
  final String type;
  final GearRoomType roomType;
  final String? imageUrl;
  final IconData? icon;
  final GearDeviceStatus status;
  final List<String> tags;
  final String? notes;
  final Map<String, String> specs;
}
