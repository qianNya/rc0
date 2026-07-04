import '../../../api/cine-equipment/data/cine-equipment-api.dart';
import '../domain/camera_body.dart';
import '../domain/cine_camera_setup.dart';
import '../domain/equipment_brand.dart';
import '../domain/equipment_category.dart';
import '../domain/lens.dart';

EquipmentBrand brandFromApi(CineEquipmentBrandItem item) {
  return EquipmentBrand(
    id: item.slug,
    name: item.name,
    category: _categoryFrom(item.category),
    itemKind: _kindFrom(item.itemKind),
    sort: item.sort,
  );
}

CameraBody bodyFromApi(CineCameraBodyItem item) {
  return CameraBody(
    id: item.slug,
    brandId: item.brandId,
    brand: item.brand,
    model: item.model,
    displayName: item.displayName,
    mount: item.mount,
    category: _categoryFrom(item.category),
    promptHint: item.promptHint,
    summaryLabel:
        item.summaryLabel.isNotEmpty ? item.summaryLabel : item.displayName,
    isBuiltIn: item.isBuiltIn,
  );
}

Lens lensFromApi(CineLensItem item) {
  return Lens(
    id: item.slug,
    brandId: item.brandId,
    brand: item.brand,
    model: item.model,
    displayName: item.displayName,
    focalRange: item.focalRange,
    mount: item.mount,
    category: _categoryFrom(item.category),
    promptHint: item.promptHint,
    summaryLabel:
        item.summaryLabel.isNotEmpty ? item.summaryLabel : item.displayName,
    isBuiltIn: item.isBuiltIn,
  );
}

CineCameraSetup setupFromApi(CineCameraSetupItem item) {
  final remoteId = item.id.toInt();
  return CineCameraSetup(
    id: item.slug.isNotEmpty ? item.slug : 'setup-$remoteId',
    title: item.title,
    bodyId: item.bodySlug,
    lensId: item.lensSlug,
    focalLengthMm: item.focalLengthMm,
    apertureF: item.apertureF,
    isBuiltIn: item.isBuiltIn,
    remoteId: remoteId,
  );
}

CineCameraSetupWriteBody setupToWriteBody(CineCameraSetup setup) {
  return CineCameraSetupWriteBody(
    title: setup.title,
    bodySlug: setup.bodyId,
    lensSlug: setup.lensId,
    focalLengthMm: setup.focalLengthMm,
    apertureF: setup.apertureF,
  );
}

CineCameraSetupUpdateBody setupToUpdateBody(CineCameraSetup setup) {
  return CineCameraSetupUpdateBody(
    title: setup.title,
    bodySlug: setup.bodyId,
    lensSlug: setup.lensId,
    focalLengthMm: setup.focalLengthMm,
    apertureF: setup.apertureF,
  );
}

EquipmentCategory _categoryFrom(String raw) {
  return EquipmentCategory.values.firstWhere(
    (c) => c.name == raw,
    orElse: () => EquipmentCategory.photo,
  );
}

EquipmentItemKind _kindFrom(String raw) {
  return EquipmentItemKind.values.firstWhere(
    (k) => k.name == raw,
    orElse: () => EquipmentItemKind.body,
  );
}

String equipmentItemKindApi(EquipmentItemKind kind) => kind.name;
