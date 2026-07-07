/// Builds `Authorization: Bearer …` from a stored token.
String authorizationHeader(String token) {
  final trimmed = token.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.toLowerCase().startsWith('bearer ')) return trimmed;
  return 'Bearer $trimmed';
}
