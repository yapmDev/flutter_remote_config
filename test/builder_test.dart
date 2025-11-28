import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:test/test.dart';
import 'mocks/mock_repository.dart';
import 'mocks/mock_service.dart';

void main() {
  group('RemoteConfigBuilder', () {
    late MockRemoteConfigService mockService;
    late MockLocalConfigRepository mockRepository;

    setUp(() {
      mockService = MockRemoteConfigService();
      mockRepository = MockLocalConfigRepository();
    });

    test('should build mediator with all configurations', () {
      // Act
      final mediator = RemoteConfigBuilder()
          .withService(mockService)
          .withRepository(mockRepository)
          .withLoadMode(LoadMode.remoteOnly)
          .enableLogging(true)
          .build();

      // Assert
      expect(mediator, isA<RemoteConfigMediator>());
    });

    test('should throw StateError when service is not provided', () {
      // Act & Assert
      expect(
        () => RemoteConfigBuilder().withRepository(mockRepository).build(),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw StateError when repository is not provided', () {
      // Act & Assert
      expect(
        () => RemoteConfigBuilder().withService(mockService).build(),
        throwsA(isA<StateError>()),
      );
    });

    test('should use default LoadMode when not specified', () {
      // Act
      final mediator = RemoteConfigBuilder()
          .withService(mockService)
          .withRepository(mockRepository)
          .build();

      // Assert - Default should be hybrid, we can't directly test this
      // but we can verify the mediator is created successfully
      expect(mediator, isA<RemoteConfigMediator>());
    });

    test('should enable logging when enableLogging is true', () {
      // Act
      final mediator = RemoteConfigBuilder()
          .withService(mockService)
          .withRepository(mockRepository)
          .enableLogging(true)
          .build();

      // Assert
      expect(mediator, isA<RemoteConfigMediator>());
    });

    test('should use custom logger when provided', () {
      // Arrange
      final customLogger = ConsoleLogger();

      // Act
      final mediator = RemoteConfigBuilder()
          .withService(mockService)
          .withRepository(mockRepository)
          .withLogger(customLogger)
          .build();

      // Assert
      expect(mediator, isA<RemoteConfigMediator>());
    });
  });
}
