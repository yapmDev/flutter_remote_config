import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';

/// Mock implementation of RemoteConfig for testing
class MockRemoteConfig implements RemoteConfig {
  final String value;

  MockRemoteConfig(this.value);
}

/// Mock implementation of RemoteConfigMapper for testing
class MockRemoteConfigMapper implements RemoteConfigMapper<MockRemoteConfig> {
  @override
  MockRemoteConfig map(Map<String, dynamic> map) {
    return MockRemoteConfig(map['test'] as String? ?? 'default');
  }
}

