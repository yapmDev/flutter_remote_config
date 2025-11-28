import 'package:meta/meta.dart';

/// Marker interface for domain-level remote configuration entities.
///
/// This abstraction allows different implementations of remote config
/// depending on app needs (e.g. theming, feature toggles, permissions).
@immutable
abstract interface class RemoteConfig {}
