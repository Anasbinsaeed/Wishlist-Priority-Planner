import 'package:flutter/foundation.dart';

class WishSelectionProvider extends ChangeNotifier {
  final Set<String> _selected = {};
  bool _isSelecting = false;

  bool get isSelecting => _isSelecting;
  Set<String> get selected => Set.unmodifiable(_selected);
  int get count => _selected.length;

  void enterSelection(String firstId) {
    _isSelecting = true;
    _selected.clear();
    _selected.add(firstId);
    notifyListeners();
  }

  void toggle(String id) {
    if (_selected.contains(id)) {
      _selected.remove(id);
    } else {
      _selected.add(id);
    }
    notifyListeners();
  }

  void selectAll(List<String> ids) {
    _selected.addAll(ids);
    notifyListeners();
  }

  void deselectAll() {
    _selected.clear();
    notifyListeners();
  }

  void exitSelection() {
    _isSelecting = false;
    _selected.clear();
    notifyListeners();
  }

  bool isSelected(String id) => _selected.contains(id);
}
