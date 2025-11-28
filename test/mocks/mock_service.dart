import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';

/// Mock implementation of RemoteConfigService for testing
class MockRemoteConfigService implements RemoteConfigService {
  ConfigData? _configToReturn;
  SyncResult _syncResult = SyncResult.upToDate;
  bool _shouldThrowOnFetch = false;
  bool _shouldThrowOnSync = false;

  /// Sets the config that will be returned by fetchConfig
  void setConfigToReturn(ConfigData? config) {
    _configToReturn = config;
  }

  /// Sets the sync result that will be returned by checkForUpdates
  void setSyncResult(SyncResult result) {
    _syncResult = result;
  }

  /// Makes fetchConfig throw an exception
  void makeFetchThrow() {
    _shouldThrowOnFetch = true;
  }

  /// Makes checkForUpdates throw an exception
  void makeSyncThrow() {
    _shouldThrowOnSync = true;
  }

  @override
  Future<ConfigData?> fetchConfig(String env, [String? version]) async {
    if (_shouldThrowOnFetch) {
      throw Exception('Network error');
    }
    return _configToReturn;
  }

  @override
  Future<SyncResult> checkForUpdates(
    ConfigMetadata local,
    String env, [
    String? version,
  ]) async {
    if (_shouldThrowOnSync) {
      throw Exception('Sync error');
    }
    return _syncResult;
  }
}

