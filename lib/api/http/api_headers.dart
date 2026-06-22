String authorizationHeader(String token) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) return trimmed;
  if (trimmed.toLowerCase().startsWith('bearer ')) return trimmed;
  return 'Bearer $trimmed';
}

String apiErrorMessage(
  Map<String, dynamic> base, {
  String fallback = 'request failed',
}) {
  final msg = base['msg'];
  if (msg is String && msg.trim().isNotEmpty) return msg.trim();

  final desc = base['desc'];
  if (desc is String && desc.trim().isNotEmpty) return desc.trim();

  return fallback;
}
