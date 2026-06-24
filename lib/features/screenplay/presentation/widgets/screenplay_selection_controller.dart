import 'package:flutter/foundation.dart';

class ScreenplaySelectionController extends ChangeNotifier {
  bool _selectionMode = false;
  final Set<String> _selectedLocalIds = {};

  bool get selectionMode => _selectionMode;
  Set<String> get selectedLocalIds => Set.unmodifiable(_selectedLocalIds);
  int get selectedCount => _selectedLocalIds.length;

  void enterSelection({String? initialLocalId}) {
    _selectionMode = true;
    _selectedLocalIds.clear();
    if (initialLocalId != null) {
      _selectedLocalIds.add(initialLocalId);
    }
    notifyListeners();
  }

  void exitSelection() {
    _selectionMode = false;
    _selectedLocalIds.clear();
    notifyListeners();
  }

  void toggle(String localId) {
    if (!_selectionMode) return;
    if (_selectedLocalIds.contains(localId)) {
      _selectedLocalIds.remove(localId);
    } else {
      _selectedLocalIds.add(localId);
    }
    notifyListeners();
  }

  void selectAll(Iterable<String> localIds) {
    if (!_selectionMode) return;
    _selectedLocalIds
      ..clear()
      ..addAll(localIds);
    notifyListeners();
  }

  bool isSelected(String localId) => _selectedLocalIds.contains(localId);
}
