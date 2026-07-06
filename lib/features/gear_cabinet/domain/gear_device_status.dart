import 'package:flutter/material.dart';

import '../presentation/theme/gear_cabinet_colors.dart';

/// Device availability state.
enum GearDeviceStatus {
  available,
  borrowed,
  repair;

  String get label => switch (this) {
        GearDeviceStatus.available => '可用',
        GearDeviceStatus.borrowed => '借出',
        GearDeviceStatus.repair => '维修',
      };

  Color get color => switch (this) {
        GearDeviceStatus.available => GearCabinetColors.statusAvailable,
        GearDeviceStatus.borrowed => GearCabinetColors.textSecondary,
        GearDeviceStatus.repair => GearCabinetColors.statusRepair,
      };
}
