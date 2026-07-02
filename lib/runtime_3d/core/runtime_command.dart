/// JSON command envelope (Flutter → Unity, v1).
class RuntimeCommand {
  const RuntimeCommand({
    required this.sessionId,
    required this.module,
    required this.action,
    this.payload = const {},
    this.version = 1,
  });

  final int version;
  final String sessionId;
  final String module;
  final String action;
  final Map<String, dynamic> payload;

  Map<String, dynamic> toJson() => {
        'v': version,
        'sessionId': sessionId,
        'module': module,
        'action': action,
        'payload': payload,
      };
}
