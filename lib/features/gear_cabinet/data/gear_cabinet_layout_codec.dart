import '../domain/gear_cabinet.dart';
import '../domain/gear_shelf.dart';

/// Encodes/decodes user layout overrides for gear cabinet rooms.
abstract final class GearCabinetLayoutCodec {
  static const int version = 1;

  static Map<String, dynamic> toPayload(List<GearRoom> rooms) => {
        'version': version,
        'rooms': encodeRooms(rooms),
      };

  static Map<String, dynamic> encodeRooms(List<GearRoom> rooms) {
    final result = <String, dynamic>{};
    for (final room in rooms) {
      result[room.type.name] = _encodeRoom(room);
    }
    return result;
  }

  static List<GearRoom> apply(
    List<GearRoom> rooms,
    Map<String, dynamic>? savedRooms,
  ) {
    if (savedRooms == null || savedRooms.isEmpty) return rooms;
    return rooms
        .map((room) {
          final raw = savedRooms[room.type.name];
          if (raw is! Map<String, dynamic>) return room;
          return _applyRoom(room, raw);
        })
        .toList(growable: false);
  }

  static Map<String, dynamic> _encodeRoom(GearRoom room) {
    final cabinets = <String, dynamic>{};
    for (final cabinet in room.cabinets) {
      final shelves = <String, dynamic>{};
      for (final shelf in cabinet.shelves) {
        shelves[shelf.id] = {
          'deviceOrder': shelf.devices.map((d) => d.id).toList(),
        };
      }
      cabinets[cabinet.id] = {
        'shelfOrder': cabinet.shelves.map((s) => s.id).toList(),
        'shelves': shelves,
      };
    }
    return {
      'cabinetOrder': room.cabinets.map((c) => c.id).toList(),
      'cabinets': cabinets,
    };
  }

  static GearRoom _applyRoom(GearRoom room, Map<String, dynamic> data) {
    final cabinetOrder = _stringList(data['cabinetOrder']);
    final cabinetData = data['cabinets'];

    final orderedCabinets = _reorderByIds(
      room.cabinets,
      cabinetOrder,
      (cabinet) => cabinet.id,
    ).map((cabinet) {
      if (cabinetData is! Map<String, dynamic>) return cabinet;
      final rawCabinet = cabinetData[cabinet.id];
      if (rawCabinet is! Map<String, dynamic>) return cabinet;
      return _applyCabinet(cabinet, rawCabinet);
    }).toList(growable: false);

    return GearRoom(
      id: room.id,
      name: room.name,
      type: room.type,
      cabinets: orderedCabinets,
    );
  }

  static GearCabinet _applyCabinet(
    GearCabinet cabinet,
    Map<String, dynamic> data,
  ) {
    final shelfOrder = _stringList(data['shelfOrder']);
    final shelfData = data['shelves'];

    final orderedShelves = _reorderByIds(
      cabinet.shelves,
      shelfOrder,
      (shelf) => shelf.id,
    ).asMap().entries.map((entry) {
      final shelf = entry.value;
      final index = entry.key;
      if (shelfData is! Map<String, dynamic>) {
        return GearShelf(
          id: shelf.id,
          index: index,
          label: shelf.label,
          devices: shelf.devices,
        );
      }
      final rawShelf = shelfData[shelf.id];
      if (rawShelf is! Map<String, dynamic>) {
        return GearShelf(
          id: shelf.id,
          index: index,
          label: shelf.label,
          devices: shelf.devices,
        );
      }
      final deviceOrder = _stringList(rawShelf['deviceOrder']);
      final devices = _reorderByIds(
        shelf.devices,
        deviceOrder,
        (device) => device.id,
      );
      return GearShelf(
        id: shelf.id,
        index: index,
        label: shelf.label,
        devices: devices,
      );
    }).toList(growable: false);

    return GearCabinet(
      id: cabinet.id,
      roomId: cabinet.roomId,
      name: cabinet.name,
      shortLabel: cabinet.shortLabel,
      shelves: orderedShelves,
    );
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((e) => e.toString()).toList(growable: false);
  }

  static List<T> _reorderByIds<T>(
    List<T> items,
    List<String> order,
    String Function(T item) idOf,
  ) {
    if (order.isEmpty) return items;
    final byId = {for (final item in items) idOf(item): item};
    final result = <T>[];
    for (final id in order) {
      final item = byId.remove(id);
      if (item != null) result.add(item);
    }
    result.addAll(byId.values);
    return result;
  }

  static Map<String, dynamic>? roomsFromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final rooms = payload['rooms'];
    if (rooms is Map<String, dynamic>) return rooms;
    return null;
  }
}
