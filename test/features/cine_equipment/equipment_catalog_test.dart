import 'package:flutter_test/flutter_test.dart';
import 'package:rc0/features/cine_equipment/domain/equipment_category.dart';
import 'package:rc0/features/cine_equipment/data/equipment_catalog.dart';
import 'package:rc0/features/cine_equipment/data/equipment_setup_mapper.dart';
import 'package:rc0/features/cine_equipment/domain/cine_camera_setup.dart';

void main() {
  test('EquipmentCatalog includes ArriFlex and Cooke seeds', () {
    final body = EquipmentCatalog.findBodyById('arri-flex-435');
    final lens = EquipmentCatalog.findLensById('cooke-s4-8');
    expect(body?.displayName, 'ArriFlex 435');
    expect(lens?.displayName, 'Cooke S4/i 8mm');
  });

  test('EquipmentCatalog includes Nikon Z8 with brand taxonomy', () {
    final body = EquipmentCatalog.findBodyById('nikon-z8');
    expect(body?.brandId, 'nikon');
    expect(body?.displayName, 'Nikon Z8');

    final brands = EquipmentCatalog.brandsFor(
      category: body!.category,
      itemKind: EquipmentItemKind.body,
    );
    expect(brands.any((b) => b.id == 'nikon'), isTrue);
  });

  test('EquipmentSetupMapper builds prompt from setup', () {
    const setup = CineCameraSetup(
      id: 'test',
      title: 'Test',
      bodyId: 'arri-flex-435',
      lensId: 'cooke-s4-8',
      focalLengthMm: 8,
      apertureF: 4,
    );
    final prompt = EquipmentSetupMapper.promptDescription(setup);
    expect(prompt, contains('ARRI Flex 435'));
    expect(prompt, contains('8mm focal length'));
    expect(prompt, contains('f/4'));
  });

  test('EquipmentSetupMapper displaySummary formats combo', () {
    const setup = CineCameraSetup(
      id: 'test',
      title: '',
      bodyId: 'arri-flex-435',
      lensId: 'cooke-s4-8',
      focalLengthMm: 8,
      apertureF: 4,
    );
    final summary = EquipmentSetupMapper.displaySummary(setup);
    expect(summary, contains('ArriFlex 435'));
    expect(summary, contains('8mm'));
    expect(summary, contains('f/4'));
  });
}
