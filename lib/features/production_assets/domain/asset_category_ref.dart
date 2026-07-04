/// Reference to a production-asset category (built-in domain or user-defined).
class AssetCategoryRef {
  const AssetCategoryRef({
    required this.id,
    required this.label,
    this.isBuiltin = false,
    this.route,
    this.subtitle,
  });

  final String id;
  final String label;
  final bool isBuiltin;
  final String? route;
  final String? subtitle;

  static String builtinId(String slug) => 'builtin:$slug';

  static bool isBuiltinId(String id) => id.startsWith('builtin:');

  static String? builtinSlug(String id) {
    if (!isBuiltinId(id)) return null;
    return id.substring('builtin:'.length);
  }
}
