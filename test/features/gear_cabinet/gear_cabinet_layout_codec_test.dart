import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/gear_cabinet/data/gear_cabinet_layout_codec.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_cabinet.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_device.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_device_status.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_room_type.dart';
import 'package:rc0/features/gear_cabinet/domain/gear_shelf.dart';

void main() {
  test('apply reorders cabinets shelves and devices', () {
    final room = GearRoom(
      id: 'room-camera',
      name: '相机房',
      type: GearRoomType.camera,
      cabinets: [
        GearCabinet(
          id: 'cab-a',
          roomId: 'room-camera',
          name: 'A',
          shelves: [
            GearShelf(
              id: 'shelf-1',
              index: 0,
              label: 'S1',
              devices: [
                _device('dev-1', 'One'),
                _device('dev-2', 'Two'),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'cab-b',
          roomId: 'room-camera',
          name: 'B',
          shelves: const [],
        ),
      ],
    );

    final saved = {
      'camera': {
        'cabinetOrder': ['cab-b', 'cab-a'],
        'cabinets': {
          'cab-a': {
            'shelfOrder': ['shelf-1'],
            'shelves': {
              'shelf-1': {
                'deviceOrder': ['dev-2', 'dev-1'],
              },
            },
          },
        },
      },
    };

    final applied = GearCabinetLayoutCodec.apply([room], saved).single;

    expect(applied.cabinets.map((c) => c.id), ['cab-b', 'cab-a']);
    expect(
      applied.cabinets[1].shelves.single.devices.map((d) => d.id),
      ['dev-2', 'dev-1'],
    );
  });
}

GearDevice _device(String id, String name) {
  return GearDevice(
    id: id,
    name: name,
    brand: 'Brand',
    type: 'Body',
    roomType: GearRoomType.camera,
    status: GearDeviceStatus.available,
  );
}
