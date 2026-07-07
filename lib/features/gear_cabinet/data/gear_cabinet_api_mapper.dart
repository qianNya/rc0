import 'package:flutter/material.dart';

import '../../cine_equipment/domain/cine_camera_setup.dart';
import '../../cine_equipment/domain/camera_body.dart';
import '../../cine_equipment/domain/equipment_category.dart';
import '../../cine_equipment/domain/lens.dart';
import '../domain/gear_cabinet.dart';
import '../domain/gear_device.dart';
import '../domain/gear_device_status.dart';
import '../domain/gear_room_type.dart';
import '../domain/gear_shelf.dart';
import 'gear_cabinet_sample_data.dart';

/// Read-only catalog slice used to build gear rooms.
abstract class GearCabinetCatalogSource {
  List<CameraBody> get allBodies;
  List<Lens> get allLenses;
  List<CineCameraSetup> get builtInSetups;
  List<CineCameraSetup> get userSetups;
  CameraBody? findBodyById(String id);
  Lens? findLensById(String id);
}

/// Maps [GearCabinetCatalogSource] catalog into Gear Cabinet room hierarchy.
///
/// Lighting room has no backend table yet — reuses sample data for that room only.
abstract final class GearCabinetApiMapper {
  static const _devicesPerShelf = 4;

  static List<GearRoom> buildRooms(GearCabinetCatalogSource equipment) {
    final sampleRooms = GearCabinetSampleData.buildRooms();
    final lightingRoom = sampleRooms.firstWhere(
      (r) => r.type == GearRoomType.lighting,
    );

    return [
      lightingRoom,
      _cameraRoom(equipment.allBodies),
      _lensRoom(equipment.allLenses),
      _accessoryRoom(equipment),
    ];
  }

  static GearRoom _cameraRoom(List<CameraBody> bodies) {
    const roomId = 'room-camera';
    return GearRoom(
      id: roomId,
      name: '相机房',
      type: GearRoomType.camera,
      cabinets: _cabinetsFromBodies(roomId, bodies),
    );
  }

  static GearRoom _lensRoom(List<Lens> lenses) {
    const roomId = 'room-lens';
    return GearRoom(
      id: roomId,
      name: '镜头房',
      type: GearRoomType.lens,
      cabinets: _cabinetsFromLenses(roomId, lenses),
    );
  }

  static GearRoom _accessoryRoom(GearCabinetCatalogSource equipment) {
    const roomId = 'room-accessory';
    final builtin = equipment.builtInSetups;
    final user = equipment.userSetups;

    final cabinets = <GearCabinet>[
      if (builtin.isNotEmpty)
        _setupCabinet(
          roomId: roomId,
          cabinetId: 'cab-setups-builtin',
          name: '系统组合',
          setups: builtin,
          equipment: equipment,
        ),
      if (user.isNotEmpty)
        _setupCabinet(
          roomId: roomId,
          cabinetId: 'cab-setups-user',
          name: '我的组合',
          setups: user,
          equipment: equipment,
        ),
    ];

    if (cabinets.isEmpty) {
      return sampleAccessoryRoom(roomId);
    }

    return GearRoom(
      id: roomId,
      name: '配件房',
      type: GearRoomType.accessory,
      cabinets: cabinets,
    );
  }

  static GearRoom sampleAccessoryRoom(String roomId) {
    return GearCabinetSampleData.buildRooms().firstWhere(
      (r) => r.type == GearRoomType.accessory,
    );
  }

  static List<GearCabinet> _cabinetsFromBodies(
    String roomId,
    List<CameraBody> bodies,
  ) {
    if (bodies.isEmpty) return const [];

    final byBrand = <String, List<CameraBody>>{};
    for (final body in bodies) {
      (byBrand[body.brand] ??= []).add(body);
    }

    final brands = byBrand.keys.toList()..sort();
    return [
      for (var i = 0; i < brands.length; i++)
        _bodyBrandCabinet(
          roomId: roomId,
          cabinetId: 'cab-camera-${_slug(brands[i])}',
          brand: brands[i],
          bodies: byBrand[brands[i]]!,
        ),
    ];
  }

  static GearCabinet _bodyBrandCabinet({
    required String roomId,
    required String cabinetId,
    required String brand,
    required List<CameraBody> bodies,
  }) {
    return _brandCabinet<CameraBody>(
      roomId: roomId,
      cabinetId: cabinetId,
      brand: brand,
      items: bodies,
      deviceBuilder: _bodyDevice,
      mountOf: (body) => body.mount,
    );
  }

  static GearCabinet _lensBrandCabinet({
    required String roomId,
    required String cabinetId,
    required String brand,
    required List<Lens> lenses,
  }) {
    return _brandCabinet<Lens>(
      roomId: roomId,
      cabinetId: cabinetId,
      brand: brand,
      items: lenses,
      deviceBuilder: _lensDevice,
      mountOf: (lens) => lens.mount,
    );
  }

  static List<GearCabinet> _cabinetsFromLenses(String roomId, List<Lens> lenses) {
    if (lenses.isEmpty) return const [];

    final byBrand = <String, List<Lens>>{};
    for (final lens in lenses) {
      (byBrand[lens.brand] ??= []).add(lens);
    }

    final brands = byBrand.keys.toList()..sort();
    return [
      for (final brand in brands)
        _lensBrandCabinet(
          roomId: roomId,
          cabinetId: 'cab-lens-${_slug(brand)}',
          brand: brand,
          lenses: byBrand[brand]!,
        ),
    ];
  }

  static GearCabinet _brandCabinet<T>({
    required String roomId,
    required String cabinetId,
    required String brand,
    required List<T> items,
    required GearDevice Function(T item) deviceBuilder,
    required String Function(T item) mountOf,
  }) {
    final byMount = <String, List<T>>{};
    for (final item in items) {
      final mount = mountOf(item).isEmpty ? '通用' : mountOf(item);
      (byMount[mount] ??= []).add(item);
    }

    final mounts = byMount.keys.toList()..sort();
    final shelves = <GearShelf>[];

    for (var shelfIndex = 0; shelfIndex < mounts.length; shelfIndex++) {
      final mount = mounts[shelfIndex];
      final mountItems = byMount[mount]!
        ..sort((a, b) => deviceBuilder(a).name.compareTo(deviceBuilder(b).name));

      for (var chunk = 0; chunk < mountItems.length; chunk += _devicesPerShelf) {
        final slice = mountItems.skip(chunk).take(_devicesPerShelf).toList();
        final shelfNumber = shelves.length + 1;
        shelves.add(
          GearShelf(
            id: '$cabinetId-shelf-$shelfNumber',
            index: shelfNumber,
            label: '$brand · $mount',
            devices: slice.map(deviceBuilder).toList(growable: false),
          ),
        );
      }
    }

    return GearCabinet(
      id: cabinetId,
      roomId: roomId,
      name: brand,
      shortLabel: brand,
      shelves: shelves,
    );
  }

  static GearCabinet _setupCabinet({
    required String roomId,
    required String cabinetId,
    required String name,
    required List<CineCameraSetup> setups,
    required GearCabinetCatalogSource equipment,
  }) {
    final devices = setups
        .map((setup) => _setupDevice(setup, equipment))
        .toList(growable: false);

    final shelves = <GearShelf>[];
    for (var i = 0; i < devices.length; i += _devicesPerShelf) {
      final shelfNumber = shelves.length + 1;
      shelves.add(
        GearShelf(
          id: '$cabinetId-shelf-$shelfNumber',
          index: shelfNumber,
          label: '$name · $shelfNumber',
          devices: devices.skip(i).take(_devicesPerShelf).toList(growable: false),
        ),
      );
    }

    return GearCabinet(
      id: cabinetId,
      roomId: roomId,
      name: name,
      shortLabel: name,
      shelves: shelves,
    );
  }

  static GearDevice _bodyDevice(CameraBody body) {
    return GearDevice(
      id: 'body-${body.id}',
      name: body.displayName,
      brand: body.brand,
      type: body.category.label,
      roomType: GearRoomType.camera,
      icon: Icons.videocam_outlined,
      status: GearDeviceStatus.available,
      tags: [
        if (body.favorite) '收藏',
        if (body.mount.isNotEmpty) body.mount,
      ],
      specs: {
        '卡口': body.mount,
        '型号': body.model,
      },
    );
  }

  static GearDevice _lensDevice(Lens lens) {
    return GearDevice(
      id: 'lens-${lens.id}',
      name: lens.displayName,
      brand: lens.brand,
      type: lens.focalRange.isNotEmpty ? lens.focalRange : '镜头',
      roomType: GearRoomType.lens,
      icon: Icons.lens_outlined,
      status: GearDeviceStatus.available,
      tags: [
        if (lens.favorite) '收藏',
        if (lens.mount.isNotEmpty) lens.mount,
      ],
      specs: {
        '焦段': lens.focalRange,
        '卡口': lens.mount,
      },
    );
  }

  static GearDevice _setupDevice(
    CineCameraSetup setup,
    GearCabinetCatalogSource equipment,
  ) {
    final body = equipment.findBodyById(setup.bodyId);
    final lens = equipment.findLensById(setup.lensId);
    final bodyLabel = body?.displaySummary ?? setup.bodyId;
    final lensLabel = lens?.displaySummary ?? setup.lensId;

    return GearDevice(
      id: 'setup-${setup.id}',
      name: setup.title.isNotEmpty ? setup.title : '$bodyLabel + $lensLabel',
      brand: body?.brand ?? '',
      type: '组合',
      roomType: GearRoomType.accessory,
      icon: Icons.camera_outlined,
      status: GearDeviceStatus.available,
      tags: [
        if (setup.favorite) '收藏',
        '${setup.focalLengthMm.toStringAsFixed(0)}mm',
        'f/${setup.apertureF.toStringAsFixed(1)}',
      ],
      notes: '$bodyLabel · $lensLabel',
      specs: {
        '机身': bodyLabel,
        '镜头': lensLabel,
        '焦段': '${setup.focalLengthMm.toStringAsFixed(0)}mm',
        '光圈': 'f/${setup.apertureF.toStringAsFixed(1)}',
      },
    );
  }

  static String _slug(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}
