/// A base interface for models that can be serialized into JSON.
///
/// Classes that implement [Serializable] are required to provide a
/// `toJson()` method, which returns a JSON-compatible map representation
/// of the object's current state.
///
/// This is typically used for models that are persisted locally,
/// sent over the network, or logged for debugging.
///
/// Example usage:
/// ```dart
/// class MyModel implements Serializable {
///   final String name;
///   const MyModel(this.name);
///
///   @override
///   Map<String, dynamic> toJson() => {'name': name};
/// }
/// ```
abstract interface class Serializable {
  /// Converts the implementing object into a JSON-compatible map.
  Map<String, dynamic> toJson();
}
