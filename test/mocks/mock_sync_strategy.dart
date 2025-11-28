import 'package:flutter_remote_config/flutter_remote_config.dart';

/// Mock implementation of SyncStrategy for testing
class MockSyncStrategy implements SyncStrategy {
  SyncResult _result = SyncResult.upToDate;
  bool _shouldThrow = false;

  /// Sets the result that will be returned
  void setResult(SyncResult result) {
    _result = result;
  }

  /// Makes checkForUpdates throw an exception
  void makeThrow() {
    _shouldThrow = true;
  }

  @override
  Future<SyncResult> checkForUpdates(
    ConfigMetadata local,
    RemoteConfigService service,
    String env, [
    String? version,
  ]) async {
    if (_shouldThrow) {
      throw Exception('Sync strategy error');
    }
    return _result;
  }
}

