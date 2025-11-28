import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'example_config_metadata.dart';

/// Example implementation of ConfigData.
///
/// This represents the configuration data structure from your backend.
/// In a real app, this would match your actual API response format.
class ExampleConfigData implements ConfigData {
  final Map<String, dynamic> configs;
  final ExampleConfigMetadata? metadata;

  ExampleConfigData({
    required this.configs,
    this.metadata,
  });

  @override
  Map<String, dynamic> extractConfigs() {
    return configs;
  }

  @override
  ConfigMetadata? extractMetadata() {
    return metadata;
  }
}

