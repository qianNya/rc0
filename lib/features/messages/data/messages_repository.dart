import 'package:flutter/foundation.dart';

/// Placeholder messages repository — API wiring reserved for backend.
class MessageThread {
  const MessageThread({
    required this.id,
    required this.title,
    required this.preview,
    required this.updatedAt,
    this.unread = 0,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime updatedAt;
  final int unread;
}

class MessagesRepository extends ChangeNotifier {
  MessagesRepository._();

  static final MessagesRepository instance = MessagesRepository._();

  bool _loading = false;
  String? _error;
  final List<MessageThread> _threads = [];

  bool get loading => _loading;
  String? get error => _error;
  List<MessageThread> get threads => List.unmodifiable(_threads);

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 300));

    _threads.clear();
    _loading = false;
    notifyListeners();
  }
}
