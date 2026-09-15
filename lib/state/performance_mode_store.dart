import 'package:flutter/foundation.dart';

import '../services/performance_mode_service.dart';

// синглтон - нужен в GlassPanel (почти 130 мест использования) и в
// AppBackground одновременно, тот же приём, что и у ThemeStore
class PerformanceModeStore extends ChangeNotifier {
  PerformanceModeStore._internal();
  static final PerformanceModeStore instance = PerformanceModeStore._internal();

  final PerformanceModeService _service = PerformanceModeService();
  bool enabled = false;

  Future<void> load() async {
    enabled = await _service.load();
    notifyListeners();
  }

  Future<void> setEnabled(bool value) async {
    enabled = value;
    notifyListeners();
    await _service.save(value);
  }
}
