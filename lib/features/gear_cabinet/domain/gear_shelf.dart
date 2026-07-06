import 'gear_device.dart';

class GearShelf {
  const GearShelf({
    required this.id,
    required this.index,
    required this.label,
    required this.devices,
  });

  final String id;
  final int index;
  final String label;
  final List<GearDevice> devices;
}
