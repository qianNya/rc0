import 'package:flutter/material.dart';

import '../domain/gear_cabinet.dart';
import '../domain/gear_device.dart';
import '../domain/gear_device_status.dart';
import '../domain/gear_room_type.dart';
import '../domain/gear_shelf.dart';

abstract final class GearCabinetSampleData {
  static List<GearRoom> buildRooms() => [
        _lightingRoom(),
        _cameraRoom(),
        _lensRoom(),
        _accessoryRoom(),
      ];

  static GearRoom _lightingRoom() {
    const roomId = 'room-lighting';
    return GearRoom(
      id: roomId,
      name: '灯光房',
      type: GearRoomType.lighting,
      cabinets: [
        GearCabinet(
          id: 'cab-a',
          roomId: roomId,
          name: 'A柜',
          shortLabel: 'A柜',
          shelves: [
            GearShelf(
              id: 'a-1',
              index: 1,
              label: 'A-1',
              devices: [
                _device(
                  'd-a1-1',
                  'Aputure 600D Pro',
                  'Aputure',
                  'LED',
                  GearRoomType.lighting,
                  Icons.wb_incandescent_outlined,
                ),
                _device(
                  'd-a1-2',
                  'Godox SL60W',
                  'Godox',
                  'LED',
                  GearRoomType.lighting,
                  Icons.light_mode_outlined,
                ),
                _device(
                  'd-a1-3',
                  'Nanlite FS-300B',
                  'Nanlite',
                  'Bi-Color',
                  GearRoomType.lighting,
                  Icons.highlight_outlined,
                ),
                _device(
                  'd-a1-4',
                  'PavoTube 30C',
                  'Nanlite',
                  'Tube',
                  GearRoomType.lighting,
                  Icons.straighten_outlined,
                  status: GearDeviceStatus.borrowed,
                ),
              ],
            ),
            GearShelf(
              id: 'a-2',
              index: 2,
              label: 'A-2',
              devices: [
                _device(
                  'd-a2-1',
                  'Aputure 300D II',
                  'Aputure',
                  'LED',
                  GearRoomType.lighting,
                  Icons.wb_incandescent_outlined,
                ),
                _device(
                  'd-a2-2',
                  'Godox VL300',
                  'Godox',
                  'LED',
                  GearRoomType.lighting,
                  Icons.light_mode_outlined,
                ),
                _device(
                  'd-a2-3',
                  'ARRI Skypanel S60',
                  'ARRI',
                  'Panel',
                  GearRoomType.lighting,
                  Icons.grid_view_outlined,
                ),
                _device(
                  'd-a2-4',
                  'LiteMat Plus 4',
                  'LiteGear',
                  'Mat',
                  GearRoomType.lighting,
                  Icons.view_day_outlined,
                ),
              ],
            ),
            GearShelf(
              id: 'a-3',
              index: 3,
              label: 'A-3',
              devices: [
                _device(
                  'd-a3-1',
                  'Octabox 120cm',
                  'Aputure',
                  'Modifier',
                  GearRoomType.lighting,
                  Icons.blur_circular_outlined,
                ),
                _device(
                  'd-a3-2',
                  'Lantern 65',
                  'Aputure',
                  'Modifier',
                  GearRoomType.lighting,
                  Icons.circle_outlined,
                ),
                _device(
                  'd-a3-3',
                  'Softbox 90x120',
                  'Godox',
                  'Modifier',
                  GearRoomType.lighting,
                  Icons.crop_square_outlined,
                ),
                _device(
                  'd-a3-4',
                  'Beauty Dish',
                  'Profoto',
                  'Modifier',
                  GearRoomType.lighting,
                  Icons.radio_button_unchecked_outlined,
                  status: GearDeviceStatus.repair,
                ),
              ],
            ),
            GearShelf(
              id: 'a-4',
              index: 4,
              label: 'A-4',
              devices: [
                _device(
                  'd-a4-1',
                  'C-Stand',
                  'Avenger',
                  'Stand',
                  GearRoomType.lighting,
                  Icons.vertical_align_center_outlined,
                ),
                _device(
                  'd-a4-2',
                  'Boom Arm',
                  'Manfrotto',
                  'Stand',
                  GearRoomType.lighting,
                  Icons.open_in_full_outlined,
                ),
                _device(
                  'd-a4-3',
                  'Combo Stand',
                  'Matthews',
                  'Stand',
                  GearRoomType.lighting,
                  Icons.height_outlined,
                ),
                _device(
                  'd-a4-4',
                  'Sandbag 15kg',
                  'Matthews',
                  'Grip',
                  GearRoomType.lighting,
                  Icons.fitness_center_outlined,
                ),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'cab-b',
          roomId: roomId,
          name: 'B柜',
          shortLabel: 'B柜',
          shelves: [
            GearShelf(
              id: 'b-1',
              index: 1,
              label: 'B-1',
              devices: [
                _device(
                  'd-b1-1',
                  'ARRI M18',
                  'ARRI',
                  'HMI',
                  GearRoomType.lighting,
                  Icons.wb_sunny_outlined,
                ),
                _device(
                  'd-b1-2',
                  'Kino Flo Diva',
                  'Kino Flo',
                  'Fluorescent',
                  GearRoomType.lighting,
                  Icons.view_column_outlined,
                ),
              ],
            ),
            GearShelf(
              id: 'b-2',
              index: 2,
              label: 'B-2',
              devices: [
                _device(
                  'd-b2-1',
                  'Dedolight DLED7',
                  'Dedolight',
                  'LED',
                  GearRoomType.lighting,
                  Icons.flashlight_on_outlined,
                ),
                _device(
                  'd-b2-2',
                  'Astera Titan',
                  'Astera',
                  'Tube',
                  GearRoomType.lighting,
                  Icons.linear_scale_outlined,
                ),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'cab-c',
          roomId: roomId,
          name: 'C柜',
          shortLabel: 'C柜',
          shelves: [
            GearShelf(
              id: 'c-1',
              index: 1,
              label: 'C-1',
              devices: [
                _device(
                  'd-c1-1',
                  'Fog Machine',
                  'Antari',
                  'FX',
                  GearRoomType.lighting,
                  Icons.cloud_outlined,
                ),
                _device(
                  'd-c1-2',
                  'Haze Generator',
                  'Look Solutions',
                  'FX',
                  GearRoomType.lighting,
                  Icons.blur_on_outlined,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GearRoom _cameraRoom() {
    const roomId = 'room-camera';
    return GearRoom(
      id: roomId,
      name: '相机房',
      type: GearRoomType.camera,
      cabinets: [
        GearCabinet(
          id: 'cam-a',
          roomId: roomId,
          name: 'A柜',
          shelves: [
            GearShelf(
              id: 'cam-a-1',
              index: 1,
              label: 'A-1',
              devices: [
                _device(
                  'd-cam-1',
                  'ARRI Alexa Mini LF',
                  'ARRI',
                  'Cinema',
                  GearRoomType.camera,
                  Icons.movie_filter_outlined,
                ),
                _device(
                  'd-cam-2',
                  'RED Komodo 6K',
                  'RED',
                  'Cinema',
                  GearRoomType.camera,
                  Icons.videocam_outlined,
                ),
                _device(
                  'd-cam-3',
                  'Sony FX6',
                  'Sony',
                  'Cinema',
                  GearRoomType.camera,
                  Icons.camera_alt_outlined,
                ),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'cam-b',
          roomId: roomId,
          name: 'B柜',
          shelves: [
            GearShelf(
              id: 'cam-b-1',
              index: 1,
              label: 'B-1',
              devices: [
                _device(
                  'd-cam-4',
                  'Canon R5 C',
                  'Canon',
                  'Hybrid',
                  GearRoomType.camera,
                  Icons.photo_camera_outlined,
                ),
                _device(
                  'd-cam-5',
                  'Blackmagic 6K Pro',
                  'Blackmagic',
                  'Cinema',
                  GearRoomType.camera,
                  Icons.videocam_outlined,
                  status: GearDeviceStatus.borrowed,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GearRoom _lensRoom() {
    const roomId = 'room-lens';
    return GearRoom(
      id: roomId,
      name: '镜头房',
      type: GearRoomType.lens,
      cabinets: [
        GearCabinet(
          id: 'lens-a',
          roomId: roomId,
          name: '定焦柜',
          shelves: [
            GearShelf(
              id: 'lens-a-1',
              index: 1,
              label: 'A-1',
              devices: [
                _device(
                  'd-lens-1',
                  'Zeiss Supreme 50mm',
                  'Zeiss',
                  'Prime',
                  GearRoomType.lens,
                  Icons.lens_outlined,
                ),
                _device(
                  'd-lens-2',
                  'Cooke S7/i 85mm',
                  'Cooke',
                  'Prime',
                  GearRoomType.lens,
                  Icons.lens_outlined,
                ),
                _device(
                  'd-lens-3',
                  'Sigma Art 35mm',
                  'Sigma',
                  'Prime',
                  GearRoomType.lens,
                  Icons.lens_outlined,
                ),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'lens-b',
          roomId: roomId,
          name: '变焦柜',
          shelves: [
            GearShelf(
              id: 'lens-b-1',
              index: 1,
              label: 'B-1',
              devices: [
                _device(
                  'd-lens-4',
                  'Angenieux EZ-2 22-60',
                  'Angenieux',
                  'Zoom',
                  GearRoomType.lens,
                  Icons.lens_blur_outlined,
                ),
                _device(
                  'd-lens-5',
                  'Canon CN-E 24-70',
                  'Canon',
                  'Zoom',
                  GearRoomType.lens,
                  Icons.lens_blur_outlined,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GearRoom _accessoryRoom() {
    const roomId = 'room-accessory';
    return GearRoom(
      id: roomId,
      name: '配件房',
      type: GearRoomType.accessory,
      cabinets: [
        GearCabinet(
          id: 'acc-a',
          roomId: roomId,
          name: '稳定柜',
          shelves: [
            GearShelf(
              id: 'acc-a-1',
              index: 1,
              label: 'A-1',
              devices: [
                _device(
                  'd-acc-1',
                  'DJI Ronin 4D',
                  'DJI',
                  'Gimbal',
                  GearRoomType.accessory,
                  Icons.threed_rotation_outlined,
                ),
                _device(
                  'd-acc-2',
                  'Easyrig V5',
                  'Easyrig',
                  'Support',
                  GearRoomType.accessory,
                  Icons.accessibility_new_outlined,
                ),
              ],
            ),
          ],
        ),
        GearCabinet(
          id: 'acc-b',
          roomId: roomId,
          name: '监视柜',
          shelves: [
            GearShelf(
              id: 'acc-b-1',
              index: 1,
              label: 'B-1',
              devices: [
                _device(
                  'd-acc-3',
                  'SmallHD 702 Touch',
                  'SmallHD',
                  'Monitor',
                  GearRoomType.accessory,
                  Icons.monitor_outlined,
                ),
                _device(
                  'd-acc-4',
                  'Teradek Bolt 4K',
                  'Teradek',
                  'Wireless',
                  GearRoomType.accessory,
                  Icons.wifi_tethering_outlined,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static GearDevice _device(
    String id,
    String name,
    String brand,
    String type,
    GearRoomType roomType,
    IconData icon, {
    GearDeviceStatus status = GearDeviceStatus.available,
  }) {
    return GearDevice(
      id: id,
      name: name,
      brand: brand,
      type: type,
      roomType: roomType,
      icon: icon,
      status: status,
      tags: [roomType.label, type],
      specs: {
        '品牌': brand,
        '类型': type,
        '状态': status.label,
      },
    );
  }
}
