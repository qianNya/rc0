/// Formats large counts for marketplace UI (e.g. 56000 → 5.6w).
String formatCompactCount(int n) {
  if (n >= 100000000) {
    final v = n / 100000000;
    return '${v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)}亿';
  }
  if (n >= 10000) {
    final v = n / 10000;
    return '${v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)}w';
  }
  if (n >= 1000) {
    final v = n / 1000;
    return '${v >= 10 ? v.toStringAsFixed(0) : v.toStringAsFixed(1)}k';
  }
  return '$n';
}
