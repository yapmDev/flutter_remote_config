import 'package:flutter_remote_config/flutter_remote_config.dart';

/// Mock implementation of LocalConfigRepository for testing
class MockLocalConfigRepository implements LocalConfigRepository {
  bool _hasData = false;
  Map<String, dynamic> _configs = {};
  ConfigMetadata? _metadata;
  bool _shouldThrowOnSave = false;

  /// Sets whether the repository has data
  void setHasData(bool hasData) {
    _hasData = hasData;
  }

  /// Sets the configs that will be returned
  void setConfigs(Map<String, dynamic> configs) {
    _configs = configs;
    _hasData = true;
  }

  /// Sets the metadata that will be returned
  void setMetadata(ConfigMetadata? metadata) {
    _metadata = metadata;
  }

  /// Makes saveConfig throw an exception
  void makeSaveThrow() {
    _shouldThrowOnSave = true;
  }

  /// Resets the mock to initial state
  void reset() {
    _hasData = false;
    _configs = {};
    _metadata = null;
    _shouldThrowOnSave = false;
  }

  @override
  bool hasData() => _hasData;

  @override
  ConfigMetadata? getMetadata() => _metadata;

  @override
  Map<String, dynamic> getConfigs() => Map<String, dynamic>.from(_configs);

  @override
  Future<void> saveConfig(ConfigData config) async {
    if (_shouldThrowOnSave) {
      throw Exception('Save error');
    }
    _configs = config.extractConfigs();
    _metadata = config.extractMetadata();
    _hasData = true;
  }

  @override
  Future<void> clearCache() async {
    _hasData = false;
    _configs = {};
    _metadata = null;
  }
}
