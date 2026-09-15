import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed local storage for assessment history.
class LocalStorageService {
  static const _boxName = 'msk_assessments';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Box<String> get _box => Hive.box<String>(_boxName);

  Future<void> save(String key, String json) async {
    await _box.put(key, json);
  }

  String? read(String key) => _box.get(key);

  List<String> readAll() => _box.values.toList();

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
