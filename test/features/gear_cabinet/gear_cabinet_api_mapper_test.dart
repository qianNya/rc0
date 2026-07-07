import 'package:flutter_test/flutter_test.dart';

import 'package:rc0/features/cine_equipment/domain/camera_body.dart';
import 'package:rc0/features/cine_equipment/domain/cine_camera_setup.dart';
import 'package:rc0/features/cine_equipment/domain/equipment_category.dart';
import 'package:rc0/features/cine_equipment/domain/lens.dart';
import 'package:rc0/features/gear_cabinet/data/gear_cabinet_api_mapper.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_room_type.dart';

void main() {
  test('buildRooms groups bodies by brand and lenses by brand', () {
    final equipment = _FakeCatalog(
      bodies: const [
        CameraBody(
          id: 'arri-alexa',
          brandId: 'arri',
          brand: 'ARRI',
          model: 'Alexa 35',
          displayName: 'ARRI Alexa 35',
          mount: 'LPL',
          category: EquipmentCategory.cinema,
        ),
        CameraBody(
          id: 'sony-fx6',
          brandId: 'sony',
          brand: 'Sony',
          model: 'FX6',
          displayName: 'Sony FX6',
          mount: 'E',
          category: EquipmentCategory.cinema,
        ),
      ],
      lenses: const [
        Lens(
          id: 'zeiss-supreme',
          brandId: 'zeiss',
          brand: 'Zeiss',
          model: 'Supreme Prime',
          displayName: 'Zeiss Supreme 50mm',
          focalRange: '50mm',
          mount: 'PL',
          category: EquipmentCategory.cinema,
        ),
      ],
      setups: const [
        CineCameraSetup(
          id: 'rig-1',
          title: '夜景 rig',
          bodyId: 'arri-alexa',
          lensId: 'zeiss-supreme',
          focalLengthMm: 50,
          apertureF: 2.0,
          isBuiltIn: true,
        ),
      ],
    );

    final rooms = GearCabinetApiMapper.buildRooms(equipment);

    expect(rooms.length, 4);
    expect(rooms[0].type, GearRoomType.lighting);
    expect(rooms[1].type, GearRoomType.camera);
    expect(rooms[1].cabinets.length, 2);
    expect(
      rooms[1].cabinets
          .expand((cab) => cab.shelves)
          .expand((shelf) => shelf.devices)
          .any((d) => d.id == 'body-arri-alexa'),
      isTrue,
    );

    expect(rooms[2].type, GearRoomType.lens);
    expect(rooms[2].cabinets.single.name, 'Zeiss');

    expect(rooms[3].type, GearRoomType.accessory);
    expect(
      rooms[3].cabinets.first.shelves.first.devices.first.id,
      'setup-rig-1',
    );
  });
}

class _FakeCatalog implements GearCabinetCatalogSource {
  _FakeCatalog({
    required List<CameraBody> bodies,
    required List<Lens> lenses,
    required List<CineCameraSetup> setups,
  })  : _bodies = bodies,
        _lenses = lenses,
        _setups = setups;

  final List<CameraBody> _bodies;
  final List<Lens> _lenses;
  final List<CineCameraSetup> _setups;

  @override
  List<CameraBody> get allBodies => _bodies;

  @override
  List<Lens> get allLenses => _lenses;

  @override
  List<CineCameraSetup> get builtInSetups => _setups;

  @override
  List<CineCameraSetup> get userSetups => const [];

  @override
  CameraBody? findBodyById(String id) {
    for (final body in _bodies) {
      if (body.id == id) return body;
    }
    return null;
  }

  @override
  Lens? findLensById(String id) {
    for (final lens in _lenses) {
      if (lens.id == id) return lens;
    }
    return null;
  }
}
