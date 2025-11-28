import 'package:flutter_remote_config/flutter_remote_config.dart';

/// Example implementation of ConfigMetadata.
///
/// This represents the metadata used for sync checking.
/// The syncIdentifier can be a version, ETag, timestamp, or any identifier
/// that your backend uses to detect changes.
class ExampleConfigMetadata implements ConfigMetadata {
  final String version;
  final DateTime lastModified;

  ExampleConfigMetadata({
    required this.version,
    required this.lastModified,
  });

  @override
  String get syncIdentifier => '$version-${lastModified.millisecondsSinceEpoch}';

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Create from JSON
  factory ExampleConfigMetadata.fromJson(Map<String, dynamic> json) {
    return ExampleConfigMetadata(
      version: json['version'] as String,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }
}

