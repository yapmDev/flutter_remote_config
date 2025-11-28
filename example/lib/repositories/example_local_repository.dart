import 'dart:convert';
import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/example_config_data.dart';
import '../models/example_config_metadata.dart';

/// Example implementation of LocalConfigRepository using SharedPreferences.
///
/// This repository stores configuration data locally using SharedPreferences.
/// In a real app, you might use SQLite, Hive, or another storage solution.
class ExampleLocalRepository implements LocalConfigRepository {
  static const String _configsKey = 'remote_configs';
  static const String _metadataKey = 'remote_config_metadata';

  final SharedPreferences _prefs;

  ExampleLocalRepository(this._prefs);

  /// Factory constructor to create repository with SharedPreferences instance.
  static Future<ExampleLocalRepository> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ExampleLocalRepository(prefs);
  }

  @override
  bool hasData() {
    return _prefs.containsKey(_configsKey);
  }

  @override
  ConfigMetadata? getMetadata() {
    final metadataJson = _prefs.getString(_metadataKey);
    if (metadataJson == null) {
      return null;
    }

    try {
      final map = jsonDecode(metadataJson) as Map<String, dynamic>;
      return ExampleConfigMetadata.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> getConfigs() {
    final configsJson = _prefs.getString(_configsKey);
    if (configsJson == null) {
      return {};
    }

    try {
      return jsonDecode(configsJson) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<void> saveConfig(ConfigData config) async {
    if (config is ExampleConfigData) {
      // Save configuration values
      final configsJson = jsonEncode(config.configs);
      await _prefs.setString(_configsKey, configsJson);

      // Save metadata
      final metadata = config.metadata;
      if (metadata is ExampleConfigMetadata) {
        final metadataJson = jsonEncode(metadata.toJson());
        await _prefs.setString(_metadataKey, metadataJson);
      }
    } else {
      // Generic fallback for other ConfigData implementations
      final configs = config.extractConfigs();
      final configsJson = jsonEncode(configs);
      await _prefs.setString(_configsKey, configsJson);

      final metadata = config.extractMetadata();
      if (metadata != null) {
        final metadataJson = jsonEncode({'syncIdentifier': metadata.syncIdentifier});
        await _prefs.setString(_metadataKey, metadataJson);
      }
    }
  }

  @override
  Future<void> clearCache() async {
    await _prefs.remove(_configsKey);
    await _prefs.remove(_metadataKey);
  }
}

