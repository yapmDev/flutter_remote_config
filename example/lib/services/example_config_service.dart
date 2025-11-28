import 'dart:convert';
import 'dart:io';
import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import '../models/example_config_data.dart';
import '../models/example_config_metadata.dart';

/// Implementation of RemoteConfigService that connects to a Django REST API.
///
/// This service connects to a Django backend with a Config model.
/// Expected API structure:
/// - GET /api/configs/{app_id}/{env}/{version}/ - Fetch full config
/// - HEAD /api/configs/{app_id}/{env}/{version}/ - Check for updates
class ExampleConfigService implements RemoteConfigService {
  final String baseUrl;
  final String appId;
  final http.Client _client;

  ExampleConfigService({
    this.baseUrl = 'http://localhost:8000',
    required this.appId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  @override
  Future<ConfigData?> fetchConfig(String env, [String? version]) async {
    try {
      // Build URL: /api/configs/{app_id}/{env}/{version}/
      final versionParam = version ?? 'latest';
      final url = Uri.parse('$baseUrl/api/configs/$appId/$env/$versionParam/');
      
      final response = await _client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        
        // Extract configs from Django response
        final configs = jsonData['configs'] as Map<String, dynamic>? ?? {};
        
        // Extract metadata from Django model fields
        final versionFromApi = jsonData['version'] as String? ?? versionParam;
        final lastModifiedStr = jsonData['last_modified_date'] as String?;
        
        if (lastModifiedStr == null) {
          // If no last_modified_date, use current time as fallback
          return ExampleConfigData(
            configs: configs,
            metadata: ExampleConfigMetadata(
              version: versionFromApi,
              lastModified: DateTime.now(),
            ),
          );
        }

        final lastModified = DateTime.parse(lastModifiedStr);
        
        final metadata = ExampleConfigMetadata(
          version: versionFromApi,
          lastModified: lastModified,
        );

        return ExampleConfigData(
          configs: configs,
          metadata: metadata,
        );
      } else if (response.statusCode == 404) {
        return null; // Config not found
      } else {
        // On error, return null (service should handle errors gracefully)
        return null;
      }
    } catch (e) {
      // Handle network errors gracefully
      return null;
    }
  }

  @override
  Future<SyncResult> checkForUpdates(
    ConfigMetadata local,
    String env, [
    String? version,
  ]) async {
    try {
      // Build URL: /api/configs/{app_id}/{env}/{version}/
      final versionParam = version ?? 'latest';
      final url = Uri.parse('$baseUrl/api/configs/$appId/$env/$versionParam/');
      
      // Use HEAD request for lightweight sync check
      final response = await _client.head(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Get Last-Modified header from Django response
        final lastModifiedHeader = response.headers['last-modified'];
        
        if (lastModifiedHeader != null) {
          // Parse the Last-Modified header
          final remoteLastModified = HttpDate.parse(lastModifiedHeader);
          
          // Compare with local metadata
          // If local metadata is ExampleConfigMetadata, use its lastModified
          if (local is ExampleConfigMetadata) {
            // Compare timestamps to determine if update is needed
            if (remoteLastModified.isAfter(local.lastModified)) {
              return SyncResult.needsUpdate;
            } else {
              return SyncResult.upToDate;
            }
          } else {
            // Fallback: compare sync identifiers
            // Try to extract timestamp from local syncIdentifier
            final localId = local.syncIdentifier;
            final remoteId = '$versionParam-${remoteLastModified.millisecondsSinceEpoch}';
            
            if (remoteId != localId) {
              return SyncResult.needsUpdate;
            } else {
              return SyncResult.upToDate;
            }
          }
        } else {
          // No Last-Modified header, fetch full config to compare
          // This is less efficient but necessary if header is missing
          final configData = await fetchConfig(env, version);
          if (configData != null) {
            final remoteMetadata = configData.extractMetadata();
            if (remoteMetadata != null && remoteMetadata.syncIdentifier != local.syncIdentifier) {
              return SyncResult.needsUpdate;
            } else {
              return SyncResult.upToDate;
            }
          } else {
            return SyncResult.error;
          }
        }
      } else if (response.statusCode == 404) {
        return SyncResult.notFound;
      } else {
        return SyncResult.error;
      }
    } catch (e) {
      // Network error during sync check
      return SyncResult.error;
    }
  }
}

