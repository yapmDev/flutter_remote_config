import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';

/// Mock implementation of ConfigData for testing
class MockConfigData implements ConfigData {
  final Map<String, dynamic> _configs;
  final ConfigMetadata? _metadata;

  MockConfigData(this._configs, [this._metadata]);

  @override
  Map<String, dynamic> extractConfigs() => _configs;

  @override
  ConfigMetadata? extractMetadata() => _metadata;
}

/// Mock implementation of ConfigMetadata for testing
class MockConfigMetadata implements ConfigMetadata {
  final String _syncIdentifier;

  MockConfigMetadata(this._syncIdentifier);

  @override
  String get syncIdentifier => _syncIdentifier;
}

