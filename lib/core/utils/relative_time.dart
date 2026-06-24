/// Formats [date] as a short relative label for recent-project lists.
String formatRelativeTime(DateTime date, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final local = date.toLocal();
  final today = DateTime(current.year, current.month, current.day);
  final target = DateTime(local.year, local.month, local.day);
  final dayDiff = today.difference(target).inDays;

  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  final time = '$hour:$minute';

  if (dayDiff == 0) return '今天 $time';
  if (dayDiff == 1) return '昨天 $time';
  if (dayDiff < 7) return '$dayDiff天前';

  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  if (local.year == current.year) {
    return '$month-$day';
  }
  return '${local.year}-$month-$day';
}
