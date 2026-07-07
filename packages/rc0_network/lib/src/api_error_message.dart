/// Extracts a human-readable message from the backend JSON envelope.
String apiErrorMessage(Map<String, dynamic> base) {
  final message = base['message'];
  if (message is String && message.trim().isNotEmpty) return message.trim();
  final msg = base['msg'];
  if (msg is String && msg.trim().isNotEmpty) return msg.trim();
  final desc = base['desc'];
  if (desc is String && desc.trim().isNotEmpty) return desc.trim();
  return 'request failed';
}
