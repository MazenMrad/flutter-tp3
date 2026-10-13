import 'package:flutter/foundation.dart'; // Required for ChangeNotifier

class QueueProvider extends ChangeNotifier {
  final List<String> _clients = [];

  List<String> get clients => List.unmodifiable(_clients);

  // Convenience getters for UI.
  int get waitingCount => _clients.length;
  bool get isEmpty => _clients.isEmpty;
  bool get isNotEmpty => _clients.isNotEmpty;

  void addClient(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _clients.add(trimmed);
    notifyListeners(); // Notify listeners of the change
  }

  void removeClient(String name) {
    final removed = _clients.remove(name);
    if (removed) notifyListeners();
  }

  void nextClient() {
    if (_clients.isNotEmpty) {
      _clients.removeAt(0);
      notifyListeners();
    }
  }

  void clear() {
    if (_clients.isEmpty) return;
    _clients.clear();
    notifyListeners();
  }
}
