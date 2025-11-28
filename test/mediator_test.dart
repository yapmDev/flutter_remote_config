import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';
import 'package:test/test.dart';
import 'mocks/mock_config_data.dart';
import 'mocks/mock_mapper.dart';
import 'mocks/mock_repository.dart';
import 'mocks/mock_service.dart';
import 'mocks/mock_sync_strategy.dart';

void main() {
  group('RemoteConfigMediator', () {
    late MockRemoteConfigService mockService;
    late MockLocalConfigRepository mockRepository;

    setUp(() {
      mockService = MockRemoteConfigService();
      mockRepository = MockLocalConfigRepository();
    });

    group('Hybrid Mode', () {
      test('should use local cache when up-to-date', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        final localMetadata = MockConfigMetadata('sync-123');
        mockRepository.setConfigs(localConfigs);
        mockRepository.setMetadata(localMetadata);
        mockService.setSyncResult(SyncResult.upToDate);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.hybrid,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'local_value');
      });

      test('should fetch from remote when needsUpdate', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        final localMetadata = MockConfigMetadata('sync-123');
        mockRepository.setConfigs(localConfigs);
        mockRepository.setMetadata(localMetadata);
        mockService.setSyncResult(SyncResult.needsUpdate);

        final remoteConfigs = {'test': 'remote_value'};
        final remoteMetadata = MockConfigMetadata('sync-456');
        final remoteConfigData = MockConfigData(remoteConfigs, remoteMetadata);
        mockService.setConfigToReturn(remoteConfigData);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.hybrid,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'remote_value');
        expect(mockRepository.getConfigs()['test'], 'remote_value');
      });

      test('should use local cache as fallback when sync check fails', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        final localMetadata = MockConfigMetadata('sync-123');
        mockRepository.setConfigs(localConfigs);
        mockRepository.setMetadata(localMetadata);
        mockService.setSyncResult(SyncResult.error);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.hybrid,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'local_value');
      });

      test('should fetch from remote when no local data exists', () async {
        // Arrange
        mockRepository.setHasData(false);
        final remoteConfigs = {'test': 'remote_value'};
        final remoteMetadata = MockConfigMetadata('sync-456');
        final remoteConfigData = MockConfigData(remoteConfigs, remoteMetadata);
        mockService.setConfigToReturn(remoteConfigData);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.hybrid,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'remote_value');
      });
    });

    group('RemoteOnly Mode', () {
      test('should always fetch from remote', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        mockRepository.setConfigs(localConfigs);

        final remoteConfigs = {'test': 'remote_value'};
        final remoteMetadata = MockConfigMetadata('sync-456');
        final remoteConfigData = MockConfigData(remoteConfigs, remoteMetadata);
        mockService.setConfigToReturn(remoteConfigData);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.remoteOnly,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'remote_value');
      });

      test('should throw ConfigNotFoundException when remote returns null', () async {
        // Arrange
        mockService.setConfigToReturn(null);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.remoteOnly,
        );

        // Act & Assert
        expect(
          () => mediator.loadConfigs('prod'),
          throwsA(isA<ConfigNotFoundException>()),
        );
      });
    });

    group('LocalOnly Mode', () {
      test('should use local cache when available', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        mockRepository.setConfigs(localConfigs);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.localOnly,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'local_value');
      });

      test('should throw ConfigNotFoundException when no local data', () async {
        // Arrange
        mockRepository.setHasData(false);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.localOnly,
        );

        // Act & Assert
        expect(
          () => mediator.loadConfigs('prod'),
          throwsA(isA<ConfigNotFoundException>()),
        );
      });
    });

    group('Dispatch', () {
      test('should throw StateError when dispatch called before loadConfigs', () {
        // Arrange
        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
        );

        // Act & Assert
        expect(
          () => mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper()),
          throwsA(isA<StateError>()),
        );
      });

      test('should dispatch config after loading', () async {
        // Arrange
        final configs = {'test': 'dispatched_value'};
        final metadata = MockConfigMetadata('sync-123');
        final configData = MockConfigData(configs, metadata);
        mockService.setConfigToReturn(configData);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          loadMode: LoadMode.remoteOnly,
        );

        // Act
        await mediator.loadConfigs('prod');
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());

        // Assert
        expect(config.value, 'dispatched_value');
      });
    });

    group('Custom SyncStrategy', () {
      test('should use custom sync strategy when provided', () async {
        // Arrange
        final localConfigs = {'test': 'local_value'};
        final localMetadata = MockConfigMetadata('sync-123');
        mockRepository.setConfigs(localConfigs);
        mockRepository.setMetadata(localMetadata);

        final mockSyncStrategy = MockSyncStrategy();
        mockSyncStrategy.setResult(SyncResult.needsUpdate);

        final remoteConfigs = {'test': 'remote_value'};
        final remoteMetadata = MockConfigMetadata('sync-456');
        final remoteConfigData = MockConfigData(remoteConfigs, remoteMetadata);
        mockService.setConfigToReturn(remoteConfigData);

        final mediator = RemoteConfigMediator(
          mockService,
          mockRepository,
          syncStrategy: mockSyncStrategy,
          loadMode: LoadMode.hybrid,
        );

        // Act
        await mediator.loadConfigs('prod');

        // Assert
        final config = mediator.dispatch<MockRemoteConfig>(MockRemoteConfigMapper());
        expect(config.value, 'remote_value');
      });
    });
  });
}

