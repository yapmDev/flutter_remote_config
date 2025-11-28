/// Defines a contract for transforming raw configuration data into domain-specific objects.
///
/// A [RemoteConfigMapper] is responsible for converting a generic `Map<String, dynamic>`
/// (typically obtained from remote sources or local storage)
/// into a structured and meaningful [RemoteConfig] implementation.
///
/// This abstraction enables a clean separation between data parsing and domain logic,
/// facilitating better testing, flexibility, and extensibility.
///
/// Type parameter [R] should represent a concrete subtype of [RemoteConfig].
///
/// Implementations of this interface are commonly paired with models that represent
/// raw remote data (e.g., from JSON), allowing them to be converted into immutable,
/// runtime-ready config entities.
///
/// Example use cases:
/// - Mapping API response data into a `CustomRemoteConfig` instance.
/// - Handling versioned or environment-specific configuration formats.
///
/// See also:
/// - [RemoteConfig] for the target configuration abstraction.
abstract interface class RemoteConfigMapper<R> {
  /// Converts a raw key-value map into a domain-specific configuration object.
  R map(Map<String, dynamic> map);
}
