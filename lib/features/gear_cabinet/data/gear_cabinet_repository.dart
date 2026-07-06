import 'package:flutter/foundation.dart';

import '../domain/gear_cabinet.dart';
import '../domain/gear_device.dart';
import '../domain/gear_shelf.dart';
import '../domain/gear_room_type.dart';
import 'gear_cabinet_sample_data.dart';

/// In-memory gear cabinet repository with sample data.
class GearCabinetRepository extends ChangeNotifier {
  GearCabinetRepository._();

  static final GearCabinetRepository instance = GearCabinetRepository._();

  List<GearRoom> _rooms = [];
  bool _loading = false;
  String? _error;

  List<GearRoom> get rooms => List.unmodifiable(_rooms);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load() async {
    if (_rooms.isNotEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      await Future<void>.delayed(const Duration(milliseconds: 280));
      _rooms = GearCabinetSampleData.buildRooms();
    } catch (e) {
      _error = '加载设备库失败';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _rooms = [];
    await load();
  }

  GearRoom? roomByType(GearRoomType type) {
    for (final room in _rooms) {
      if (room.type == type) return room;
    }
    return null;
  }

  GearCabinet? cabinetById(String cabinetId) {
    for (final room in _rooms) {
      for (final cabinet in room.cabinets) {
        if (cabinet.id == cabinetId) return cabinet;
      }
    }
    return null;
  }

  GearDevice? deviceById(String deviceId) {
    for (final room in _rooms) {
      for (final cabinet in room.cabinets) {
        for (final shelf in cabinet.shelves) {
          for (final device in shelf.devices) {
            if (device.id == deviceId) return device;
          }
        }
      }
    }
    return null;
  }

  ({GearRoom room, GearCabinet cabinet, GearShelf? shelf})? locateDevice(
    String deviceId,
  ) {
    for (final room in _rooms) {
      for (final cabinet in room.cabinets) {
        for (final shelf in cabinet.shelves) {
          for (final device in shelf.devices) {
            if (device.id == deviceId) {
              return (room: room, cabinet: cabinet, shelf: shelf);
            }
          }
        }
      }
    }
    return null;
  }

  List<GearDevice> searchDevices(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final results = <GearDevice>[];
    for (final room in _rooms) {
      for (final cabinet in room.cabinets) {
        for (final shelf in cabinet.shelves) {
          for (final device in shelf.devices) {
            final haystack =
                '${device.name} ${device.brand} ${device.type}'.toLowerCase();
            if (haystack.contains(q)) results.add(device);
          }
        }
      }
    }
    return results;
  }
}
