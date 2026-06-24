import '../../../api/cine-preset/data/cine-preset-api.dart';
import '../domain/shoot_params.dart';
import '../domain/shoot_preset.dart';

ShootPreset shootPresetFromApi(CinePresetItem item) {
  final scope = shootPresetScopeFromInt(item.scope.toInt());
  return ShootPreset(
    id: 'preset-${item.id}',
    remoteId: item.id.toInt(),
    label: item.name,
    subtitle: item.description.isNotEmpty ? item.description : null,
    params: ShootParams.fromJson(item.params),
    isBuiltIn: item.isBuiltIn,
    scope: scope,
    categoryId: item.categoryId.toInt() > 0
        ? 'cat-${item.categoryId.toInt()}'
        : null,
  );
}

Map<String, dynamic> shootParamsToApiJson(ShootParams params) => params.toJson();
