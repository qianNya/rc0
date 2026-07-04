import '../domain/camera_body.dart';
import '../domain/cine_camera_setup.dart';
import '../domain/equipment_brand.dart';
import '../domain/equipment_category.dart';
import '../domain/lens.dart';

/// Built-in camera bodies, lenses, focal lengths, and aperture presets.
abstract final class EquipmentCatalog {
  static const focalLengthPresetsMm = <double>[
    8, 12, 16, 24, 35, 50, 85, 135,
  ];

  static const aperturePresetsF = <double>[
    1.4, 2, 2.8, 4, 5.6, 8, 11, 16,
  ];

  static List<CameraBody> get allBodies => [
        ...cinemaBodies,
        ...photoBodies,
        ...vintageBodies,
      ];

  static List<Lens> get allLenses => [
        ...cinemaLenses,
        ...photoLenses,
        ...vintageLenses,
      ];

  static List<EquipmentBrand> get allBrands => [
        ..._brandsFor(allBodies, EquipmentItemKind.body),
        ..._brandsFor(allLenses, EquipmentItemKind.lens),
      ];

  static List<EquipmentBrand> brandsFor({
    required EquipmentCategory category,
    required EquipmentItemKind itemKind,
  }) {
    return allBrands
        .where((b) => b.category == category && b.itemKind == itemKind)
        .toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));
  }

  static List<CineCameraSetup> get builtInSetups => [
        const CineCameraSetup(
          id: 'builtin-arri-cooke-8-f4',
          title: 'ArriFlex 435 · Cooke 8mm',
          bodyId: 'arri-flex-435',
          lensId: 'cooke-s4-8',
          focalLengthMm: 8,
          apertureF: 4,
          isBuiltIn: true,
        ),
        const CineCameraSetup(
          id: 'builtin-alexa-cooke-35-f28',
          title: 'Alexa 35 · Cooke 35mm',
          bodyId: 'arri-alexa-35',
          lensId: 'cooke-s4-35',
          focalLengthMm: 35,
          apertureF: 2.8,
          isBuiltIn: true,
        ),
        const CineCameraSetup(
          id: 'builtin-sony-gm-85-f14',
          title: 'Sony A7IV · GM 85mm',
          bodyId: 'sony-a7iv',
          lensId: 'sony-gm-85',
          focalLengthMm: 85,
          apertureF: 1.4,
          isBuiltIn: true,
        ),
        const CineCameraSetup(
          id: 'builtin-nikon-z8-50-f18',
          title: 'Nikon Z8 · 50mm',
          bodyId: 'nikon-z8',
          lensId: 'nikon-z-50',
          focalLengthMm: 50,
          apertureF: 1.8,
          isBuiltIn: true,
        ),
      ];

  static List<CameraBody> bodiesForCategory(
    EquipmentCategory category, {
    String? brandId,
  }) {
    if (category == EquipmentCategory.favorites) return const [];
    var items = allBodies.where((b) => b.category == category);
    if (brandId != null && brandId.isNotEmpty) {
      items = items.where((b) => b.brandId == brandId);
    }
    return items.toList();
  }

  static List<Lens> lensesForCategory(
    EquipmentCategory category, {
    String? brandId,
  }) {
    if (category == EquipmentCategory.favorites) return const [];
    var items = allLenses.where((l) => l.category == category);
    if (brandId != null && brandId.isNotEmpty) {
      items = items.where((l) => l.brandId == brandId);
    }
    return items.toList();
  }

  static CameraBody? findBodyById(String id) {
    for (final body in allBodies) {
      if (body.id == id) return body;
    }
    return null;
  }

  static Lens? findLensById(String id) {
    for (final lens in allLenses) {
      if (lens.id == id) return lens;
    }
    return null;
  }

  static CineCameraSetup? findSetupById(String id) {
    for (final setup in builtInSetups) {
      if (setup.id == id) return setup;
    }
    return null;
  }

  static List<EquipmentBrand> _brandsFor(
    Iterable<dynamic> items,
    EquipmentItemKind kind,
  ) {
    final map = <String, EquipmentBrand>{};
    for (final item in items) {
      final category = item.category as EquipmentCategory;
      final brandId = item.brandId as String;
      final brand = item.brand as String;
      if (brandId.isEmpty) continue;
      map.putIfAbsent(
        '${kind.name}:$brandId:${category.name}',
        () => EquipmentBrand(
          id: brandId,
          name: brand,
          category: category,
          itemKind: kind,
        ),
      );
    }
    return map.values.toList();
  }

  static final cinemaBodies = [
    _body(
      id: 'arri-flex-435',
      brandId: 'arri',
      brand: 'ARRI',
      model: 'Flex 435',
      displayName: 'ArriFlex 435',
      mount: 'PL',
      category: EquipmentCategory.cinema,
      promptHint: 'shot on ARRI Flex 435 35mm film camera',
    ),
    _body(
      id: 'arri-alexa-35',
      brandId: 'arri',
      brand: 'ARRI',
      model: 'Alexa 35',
      displayName: 'ARRI Alexa 35',
      mount: 'LPL',
      category: EquipmentCategory.cinema,
      promptHint: 'shot on ARRI Alexa 35 digital cinema camera',
    ),
    _body(
      id: 'red-komodo',
      brandId: 'red',
      brand: 'RED',
      model: 'Komodo 6K',
      displayName: 'RED Komodo 6K',
      mount: 'RF',
      category: EquipmentCategory.cinema,
      promptHint: 'shot on RED Komodo 6K cinema camera',
    ),
  ];

  static final photoBodies = [
    _body(
      id: 'nikon-z8',
      brandId: 'nikon',
      brand: 'Nikon',
      model: 'Z8',
      displayName: 'Nikon Z8',
      mount: 'Z',
      category: EquipmentCategory.photo,
      promptHint: 'shot on Nikon Z8 mirrorless camera',
    ),
    _body(
      id: 'sony-a7iv',
      brandId: 'sony',
      brand: 'Sony',
      model: 'A7 IV',
      displayName: 'Sony A7IV',
      mount: 'E',
      category: EquipmentCategory.photo,
      promptHint: 'shot on Sony A7 IV mirrorless camera',
    ),
    _body(
      id: 'canon-r5',
      brandId: 'canon',
      brand: 'Canon',
      model: 'EOS R5',
      displayName: 'Canon EOS R5',
      mount: 'RF',
      category: EquipmentCategory.photo,
      promptHint: 'shot on Canon EOS R5 mirrorless camera',
    ),
    _body(
      id: 'fuji-xt5',
      brandId: 'fujifilm',
      brand: 'Fujifilm',
      model: 'X-T5',
      displayName: '富士 X-T5',
      mount: 'X',
      category: EquipmentCategory.photo,
      promptHint: 'shot on Fujifilm X-T5 camera',
    ),
    _body(
      id: 'iphone-15-pro',
      brandId: 'apple',
      brand: 'Apple',
      model: 'iPhone 15 Pro',
      displayName: 'iPhone 15 Pro',
      mount: 'fixed',
      category: EquipmentCategory.photo,
      promptHint: 'shot on iPhone 15 Pro smartphone camera',
    ),
  ];

  static final vintageBodies = [
    _body(
      id: 'bolex-h16',
      brandId: 'bolex',
      brand: 'Bolex',
      model: 'H16',
      displayName: 'Bolex H16',
      mount: 'C',
      category: EquipmentCategory.vintage,
      promptHint: 'shot on Bolex H16 16mm film camera',
    ),
  ];

  static final cinemaLenses = [
    _lens(
      id: 'cooke-s4-8',
      brandId: 'cooke',
      brand: 'Cooke',
      model: 'S4/i 8mm T2',
      displayName: 'Cooke S4/i 8mm',
      focalRange: '8mm',
      mount: 'PL',
      category: EquipmentCategory.cinema,
      promptHint: 'Cooke S4/i 8mm cinema lens',
    ),
    _lens(
      id: 'cooke-s4-35',
      brandId: 'cooke',
      brand: 'Cooke',
      model: 'S4/i 35mm T2',
      displayName: 'Cooke S4/i 35mm',
      focalRange: '35mm',
      mount: 'PL',
      category: EquipmentCategory.cinema,
      promptHint: 'Cooke S4/i 35mm cinema lens',
    ),
    _lens(
      id: 'zeiss-master-50',
      brandId: 'zeiss',
      brand: 'Zeiss',
      model: 'Master Prime 50mm T1.3',
      displayName: 'Zeiss Master Prime 50mm',
      focalRange: '50mm',
      mount: 'PL',
      category: EquipmentCategory.cinema,
      promptHint: 'Zeiss Master Prime 50mm cinema lens',
    ),
  ];

  static final photoLenses = [
    _lens(
      id: 'nikon-z-50',
      brandId: 'nikon',
      brand: 'Nikon',
      model: 'NIKKOR Z 50mm f/1.8',
      displayName: 'Nikon Z 50mm f/1.8',
      focalRange: '50mm',
      mount: 'Z',
      category: EquipmentCategory.photo,
      promptHint: 'Nikon NIKKOR Z 50mm f/1.8 lens',
    ),
    _lens(
      id: 'sony-gm-85',
      brandId: 'sony',
      brand: 'Sony',
      model: 'FE 85mm F1.4 GM',
      displayName: 'Sony GM 85mm F1.4',
      focalRange: '85mm',
      mount: 'E',
      category: EquipmentCategory.photo,
      promptHint: 'Sony FE 85mm F1.4 GM lens',
    ),
    _lens(
      id: 'canon-rf-50',
      brandId: 'canon',
      brand: 'Canon',
      model: 'RF 50mm F1.2L',
      displayName: 'Canon RF 50mm F1.2L',
      focalRange: '50mm',
      mount: 'RF',
      category: EquipmentCategory.photo,
      promptHint: 'Canon RF 50mm F1.2L lens',
    ),
  ];

  static final vintageLenses = [
    _lens(
      id: 'helios-44',
      brandId: 'helios',
      brand: 'Helios',
      model: '44-2 58mm',
      displayName: 'Helios 44-2 58mm',
      focalRange: '58mm',
      mount: 'M42',
      category: EquipmentCategory.vintage,
      promptHint: 'Helios 44-2 vintage 58mm lens with swirly bokeh',
    ),
  ];

  static CameraBody _body({
    required String id,
    required String brandId,
    required String brand,
    required String model,
    required String displayName,
    required String mount,
    required EquipmentCategory category,
    required String promptHint,
  }) {
    return CameraBody(
      id: id,
      brandId: brandId,
      brand: brand,
      model: model,
      displayName: displayName,
      mount: mount,
      category: category,
      promptHint: promptHint,
      summaryLabel: displayName,
      isBuiltIn: true,
    );
  }

  static Lens _lens({
    required String id,
    required String brandId,
    required String brand,
    required String model,
    required String displayName,
    required String focalRange,
    required String mount,
    required EquipmentCategory category,
    required String promptHint,
  }) {
    return Lens(
      id: id,
      brandId: brandId,
      brand: brand,
      model: model,
      displayName: displayName,
      focalRange: focalRange,
      mount: mount,
      category: category,
      promptHint: promptHint,
      summaryLabel: displayName,
      isBuiltIn: true,
    );
  }
}
