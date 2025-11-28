import 'package:flutter_remote_config/src/domain/entity.dart';
import 'package:flutter_remote_config/src/domain/mapper.dart';

/// Defines a contract for delivering runtime-ready remote configuration objects.
///
/// [RemoteConfigDispatcher] is the interface that abstracts how raw configuration
/// data is converted and dispatched into a usable [RemoteConfig] entity.
///
/// Consumers provide a [RemoteConfigMapper] capable of transforming a generic key-value map
/// into a specific implementation of [RemoteConfig]. This allows for flexibility in how
/// configurations are structured or evolved over time.
///
/// This interface is typically implemented at the presentation layer, allowing
/// views or controllers to retrieve domain-specific configuration in a decoupled way.
///
/// Example usage:
/// ```dart
/// final config = dispatcher.dispatch(CustomMapper());
/// if (config.useDarkTheme) {
///   applyDarkTheme();
/// }
/// ```
abstract class RemoteConfigDispatcher {
  /// Converts and returns the appropriate [RemoteConfig] using the provided [mapper].
  ///
  /// The returned instance is typed as [T], which must extend [RemoteConfig].
  /// The [RemoteConfigMapper] is responsible for interpreting the raw configuration structure.
  T dispatch<T extends RemoteConfig>(RemoteConfigMapper<T> mapper);
}
