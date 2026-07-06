import 'gear_room_type.dart';
import 'gear_shelf.dart';

class GearCabinet {
  const GearCabinet({
    required this.id,
    required this.roomId,
    required this.name,
    required this.shelves,
    this.shortLabel,
  });

  final String id;
  final String roomId;
  final String name;
  final String? shortLabel;
  final List<GearShelf> shelves;

  String get displayLabel => shortLabel ?? name;

  int get deviceCount =>
      shelves.fold<int>(0, (sum, shelf) => sum + shelf.devices.length);
}

class GearRoom {
  const GearRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.cabinets,
  });

  final String id;
  final String name;
  final GearRoomType type;
  final List<GearCabinet> cabinets;

  int get deviceCount =>
      cabinets.fold<int>(0, (sum, cab) => sum + cab.deviceCount);
}
