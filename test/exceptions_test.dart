import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'package:test/test.dart';

void main() {
  group('RemoteConfigException', () {
    test('should create exception with message', () {
      // Act
      final exception = RemoteConfigException('Test error');

      // Assert
      expect(exception.message, 'Test error');
      expect(exception.cause, isNull);
      expect(exception.toString(), contains('Test error'));
    });

    test('should create exception with message and cause', () {
      // Arrange
      final cause = Exception('Underlying error');

      // Act
      final exception = RemoteConfigException('Test error', cause);

      // Assert
      expect(exception.message, 'Test error');
      expect(exception.cause, cause);
      expect(exception.toString(), contains('Test error'));
      expect(exception.toString(), contains('Underlying error'));
    });
  });

  group('ConfigNotFoundException', () {
    test('should create exception with env', () {
      // Act
      final exception = ConfigNotFoundException('prod');

      // Assert
      expect(exception.env, 'prod');
      expect(exception.version, isNull);
      expect(exception.message, contains('prod'));
      expect(exception, isA<RemoteConfigException>());
    });

    test('should create exception with env and version', () {
      // Act
      final exception = ConfigNotFoundException('prod', '1.0.0');

      // Assert
      expect(exception.env, 'prod');
      expect(exception.version, '1.0.0');
      expect(exception.message, contains('prod'));
      expect(exception.message, contains('1.0.0'));
    });
  });

  group('ConfigSyncException', () {
    test('should create exception with message', () {
      // Act
      final exception = ConfigSyncException('Sync failed');

      // Assert
      expect(exception.message, 'Sync failed');
      expect(exception, isA<RemoteConfigException>());
    });

    test('should create exception with message and cause', () {
      // Arrange
      final cause = Exception('Network error');

      // Act
      final exception = ConfigSyncException('Sync failed', cause);

      // Assert
      expect(exception.message, 'Sync failed');
      expect(exception.cause, cause);
    });
  });

  group('ConfigDataException', () {
    test('should create exception with message', () {
      // Act
      final exception = ConfigDataException('Invalid data');

      // Assert
      expect(exception.message, 'Invalid data');
      expect(exception, isA<RemoteConfigException>());
    });

    test('should create exception with message and cause', () {
      // Arrange
      final cause = FormatException('Invalid JSON');

      // Act
      final exception = ConfigDataException('Invalid data', cause);

      // Assert
      expect(exception.message, 'Invalid data');
      expect(exception.cause, cause);
    });
  });
}

