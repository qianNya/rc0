import 'package:flutter/foundation.dart';

import '../../../api/cine-equipment/api/cine-equipment-api.dart' as gear_api;
import '../../../api/cine-equipment/data/cine-equipment-api.dart';
import '../../../core/auth/auth_bridge.dart';
import '../../cine_equipment/data/equipment_repository.dart';
import '../../cine_equipment/domain/camera_body.dart';
import '../../cine_equipment/domain/cine_camera_setup.dart';
import '../../cine_equipment/domain/lens.dart';
import '../domain/gear_cabinet.dart';
import '../domain/gear_device.dart';
import '../domain/gear_shelf.dart';
import '../domain/gear_room_type.dart';
import 'gear_cabinet_api_mapper.dart';
import 'gear_cabinet_layout_codec.dart';
import 'gear_cabinet_layout_local.dart';
import 'gear_cabinet_sample_data.dart';

/// Gear cabinet repository — API catalog via [EquipmentRepository], sample fallback.
class GearCabinetRepository extends ChangeNotifier {
  GearCabinetRepository._();

  static final GearCabinetRepository instance = GearCabinetRepository._();

  /// When false, always loads [GearCabinetSampleData] (rollback / demo).
  static bool useApiCatalog = true;

  /// When true, attempts `/cine-equipment/layout` before local prefs.
  static bool useRemoteLayout = true;

  final _equipment = EquipmentRepository.instance;

  List<GearRoom> _rooms = [];
  bool _loading = false;
  String? _error;
  bool _layoutDirty = false;
  bool _savingLayout = false;

  List<GearRoom> get rooms => List.unmodifiable(_rooms);
  bool get loading => _loading;
  String? get error => _error;
  bool get isSampleData => !useApiCatalog || _rooms.isEmpty;
  bool get layoutDirty => _layoutDirty;
  bool get savingLayout => _savingLayout;

  Future<void> load() async {
    if (_rooms.isNotEmpty) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      if (useApiCatalog) {
        await _equipment.load();
        if (_equipment.allBodies.isNotEmpty ||
            _equipment.allLenses.isNotEmpty ||
            _equipment.allSetups.isNotEmpty) {
          _rooms = GearCabinetApiMapper.buildRooms(
            _EquipmentCatalogAdapter(_equipment),
          );
        } else {
          _rooms = GearCabinetSampleData.buildRooms();
        }
      } else {
        _rooms = GearCabinetSampleData.buildRooms();
      }
      if (_equipment.lastError != null && _rooms.isEmpty) {
        _error = _equipment.lastError;
      }
      await _applySavedLayout();
    } catch (e) {
      _error = '加载设备库失败';
      _rooms = GearCabinetSampleData.buildRooms();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    _rooms = [];
    _layoutDirty = false;
    if (useApiCatalog) {
      await _equipment.refreshFromApi();
    }
    await load();
  }

  Future<String?> saveLayout() async {
    if (_rooms.isEmpty) return null;
    _savingLayout = true;
    notifyListeners();

    final payload = GearCabinetLayoutCodec.toPayload(_rooms);
    String? error;

    try {
      if (useRemoteLayout && AuthBridge.isLoggedIn) {
        GearCabinetLayoutItem? saved;
        await gear_api.saveGearCabinetLayout(
          body: GearCabinetLayoutSaveBody(
            version: GearCabinetLayoutCodec.version,
            rooms: payload['rooms'] as Map<String, dynamic>,
          ),
          ok: (item) => saved = item,
          fail: (msg) => error = msg,
        );
        if (saved != null) {
          _layoutDirty = false;
          await GearCabinetLayoutLocal.instance.save(payload);
          return null;
        }
      }

      await GearCabinetLayoutLocal.instance.save(payload);
      _layoutDirty = false;
      return error;
    } finally {
      _savingLayout = false;
      notifyListeners();
    }
  }

  void reorderCabinets(GearRoomType roomType, int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final roomIndex = _rooms.indexWhere((room) => room.type == roomType);
    if (roomIndex < 0) return;

    final room = _rooms[roomIndex];
    final cabinets = List<GearCabinet>.from(room.cabinets);
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= cabinets.length ||
        newIndex >= cabinets.length) {
      return;
    }
    final moved = cabinets.removeAt(oldIndex);
    cabinets.insert(newIndex, moved);
    _rooms[roomIndex] = GearRoom(
      id: room.id,
      name: room.name,
      type: room.type,
      cabinets: cabinets,
    );
    _layoutDirty = true;
    notifyListeners();
  }

  void reorderDevices({
    required String cabinetId,
    required String shelfId,
    required int oldIndex,
    required int newIndex,
  }) {
    if (oldIndex == newIndex) return;
    final located = _locateShelf(cabinetId, shelfId);
    if (located == null) return;

    final devices = List<GearDevice>.from(located.shelf.devices);
    if (oldIndex < 0 ||
        newIndex < 0 ||
        oldIndex >= devices.length ||
        newIndex >= devices.length) {
      return;
    }
    final moved = devices.removeAt(oldIndex);
    devices.insert(newIndex, moved);
    _replaceShelf(
      located.roomIndex,
      located.cabinetIndex,
      located.shelfIndex,
      GearShelf(
        id: located.shelf.id,
        index: located.shelf.index,
        label: located.shelf.label,
        devices: devices,
      ),
    );
    _layoutDirty = true;
    notifyListeners();
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

  Future<void> _applySavedLayout() async {
    Map<String, dynamic>? savedRooms;

    if (useRemoteLayout && AuthBridge.isLoggedIn) {
      GearCabinetLayoutItem? remote;
      await gear_api.getGearCabinetLayout(ok: (item) => remote = item);
      if (remote != null && remote!.rooms.isNotEmpty) {
        savedRooms = remote!.rooms;
        await GearCabinetLayoutLocal.instance.save({
          'version': remote!.version,
          'rooms': remote!.rooms,
        });
      }
    }

    savedRooms ??= GearCabinetLayoutCodec.roomsFromPayload(
      await GearCabinetLayoutLocal.instance.load(),
    );

    if (savedRooms != null && savedRooms.isNotEmpty) {
      _rooms = GearCabinetLayoutCodec.apply(_rooms, savedRooms);
    }
  }

  ({int roomIndex, int cabinetIndex, int shelfIndex, GearShelf shelf})?
      _locateShelf(String cabinetId, String shelfId) {
    for (var roomIndex = 0; roomIndex < _rooms.length; roomIndex++) {
      final room = _rooms[roomIndex];
      for (var cabinetIndex = 0; cabinetIndex < room.cabinets.length; cabinetIndex++) {
        final cabinet = room.cabinets[cabinetIndex];
        if (cabinet.id != cabinetId) continue;
        for (var shelfIndex = 0; shelfIndex < cabinet.shelves.length; shelfIndex++) {
          final shelf = cabinet.shelves[shelfIndex];
          if (shelf.id == shelfId) {
            return (
              roomIndex: roomIndex,
              cabinetIndex: cabinetIndex,
              shelfIndex: shelfIndex,
              shelf: shelf,
            );
          }
        }
      }
    }
    return null;
  }

  void _replaceShelf(
    int roomIndex,
    int cabinetIndex,
    int shelfIndex,
    GearShelf shelf,
  ) {
    final room = _rooms[roomIndex];
    final cabinet = room.cabinets[cabinetIndex];
    final shelves = List<GearShelf>.from(cabinet.shelves);
    shelves[shelfIndex] = shelf;
    final cabinets = List<GearCabinet>.from(room.cabinets);
    cabinets[cabinetIndex] = GearCabinet(
      id: cabinet.id,
      roomId: cabinet.roomId,
      name: cabinet.name,
      shortLabel: cabinet.shortLabel,
      shelves: shelves,
    );
    _rooms[roomIndex] = GearRoom(
      id: room.id,
      name: room.name,
      type: room.type,
      cabinets: cabinets,
    );
  }
}

class _EquipmentCatalogAdapter implements GearCabinetCatalogSource {
  const _EquipmentCatalogAdapter(this._equipment);

  final EquipmentRepository _equipment;

  @override
  List<CameraBody> get allBodies => _equipment.allBodies;

  @override
  List<Lens> get allLenses => _equipment.allLenses;

  @override
  List<CineCameraSetup> get builtInSetups => _equipment.builtInSetups;

  @override
  List<CineCameraSetup> get userSetups => _equipment.userSetups;

  @override
  CameraBody? findBodyById(String id) => _equipment.findBodyById(id);

  @override
  Lens? findLensById(String id) => _equipment.findLensById(id);
}
