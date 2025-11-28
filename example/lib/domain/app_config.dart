import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';

/// Example domain entity representing application configuration.
///
/// This is the final, runtime-ready configuration object that your app uses.
/// It implements RemoteConfig to work with the SDK's dispatch mechanism.
class AppConfig implements RemoteConfig {
  final String theme;
  final String apiUrl;
  final FeatureFlags features;
  final AppSettings settings;

  const AppConfig({
    required this.theme,
    required this.apiUrl,
    required this.features,
    required this.settings,
  });

  @override
  String toString() {
    return 'AppConfig(theme: $theme, apiUrl: $apiUrl, features: $features, settings: $settings)';
  }
}

/// Feature flags configuration
class FeatureFlags {
  final bool featureA;
  final bool featureB;
  final bool featureC;

  const FeatureFlags({
    required this.featureA,
    required this.featureB,
    required this.featureC,
  });

  @override
  String toString() {
    return 'FeatureFlags(A: $featureA, B: $featureB, C: $featureC)';
  }
}

/// Application settings
class AppSettings {
  final int timeout;
  final int retries;

  const AppSettings({
    required this.timeout,
    required this.retries,
  });

  @override
  String toString() {
    return 'AppSettings(timeout: $timeout, retries: $retries)';
  }
}

