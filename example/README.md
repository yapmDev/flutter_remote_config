# BlendBerry SDK Example

This is a working example application demonstrating how to use the BlendBerry Flutter SDK with a REST backend.

## Running the Example

### Prerequisites

- Flutter SDK installed
- A backend API running (see API Requirements below)

### Steps

1. **Install dependencies**:
   ```bash
   cd example
   flutter pub get
   ```

2. **Start your backend API** (see API Requirements below)

3. **Run the web app**:
   ```bash
   flutter run -d chrome
   ```

   Or for other platforms:
   ```bash
   flutter run -d web-server  # For web server
   ```

## API Requirements

Your backend API needs to implement two endpoints:

### 1. GET `{baseUrl}/{env}?version={version}`

Fetches the full configuration for an environment.

**Query Parameters**:
- `env` (path): Environment identifier (e.g., "staging", "production")
- `version` (query, optional): Version identifier. If not provided, should return latest.

**Response** (200 OK):
```json
{
  "appId": "my-app",
  "env": "staging",
  "version": "1.0.0",
  "configs": {
    "useDarkTheme": true,
    "primaryColor": "#FF0000",
    "apiEndpoint": "https://api.example.com"
  },
  "lastModDate": "2024-01-15T10:30:00Z"
}
```

**Response** (404 Not Found): When configuration doesn't exist

### 2. GET `{baseUrl}/lookup?env={env}&version={version}&syncIdentifier={id}`

Checks if the local configuration needs to be updated.

**Query Parameters**:
- `env`: Environment identifier
- `version`: Version identifier (optional, defaults to "latest")
- `syncIdentifier`: The sync identifier from local metadata (format: `{version}-{lastModDate}`)

**Response** (200 OK):
Returns one of these strings:
- `"UP_TO_DATE"` - Local config is current
- `"NEEDS_TO_UPDATE"` - Remote has newer version
- `"NOT_FOUND"` - Configuration doesn't exist

**Response** (404 Not Found): When configuration doesn't exist

## Example Backend Implementation

### Spring Boot (Java/Kotlin)

```kotlin
@RestController
@RequestMapping("/configs")
class ConfigController {
    
    @GetMapping("/{env}")
    fun getConfig(
        @PathVariable env: String,
        @RequestParam(required = false, defaultValue = "latest") version: String
    ): ResponseEntity<ConfigResponse> {
        val config = configService.getConfig(env, version)
        return if (config != null) {
            ResponseEntity.ok(config)
        } else {
            ResponseEntity.notFound().build()
        }
    }
    
    @GetMapping("/lookup")
    fun lookup(
        @RequestParam env: String,
        @RequestParam(required = false, defaultValue = "latest") version: String,
        @RequestParam syncIdentifier: String
    ): ResponseEntity<String> {
        val result = configService.checkSync(env, version, syncIdentifier)
        return ResponseEntity.ok(result) // "UP_TO_DATE", "NEEDS_TO_UPDATE", or "NOT_FOUND"
    }
}
```

### Django (Python)

```python
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods

@require_http_methods(["GET"])
def get_config(request, env):
    version = request.GET.get('version', 'latest')
    config = ConfigService.get_config(env, version)
    
    if config:
        return JsonResponse({
            'appId': config.app_id,
            'env': config.env,
            'version': config.version,
            'configs': config.configs,
            'lastModDate': config.last_mod_date.isoformat()
        })
    return JsonResponse({'error': 'Not found'}, status=404)

@require_http_methods(["GET"])
def lookup(request):
    env = request.GET.get('env')
    version = request.GET.get('version', 'latest')
    sync_identifier = request.GET.get('syncIdentifier')
    
    result = ConfigService.check_sync(env, version, sync_identifier)
    return JsonResponse({'status': result}, status=200)
```

## Testing Without a Backend

You can test the SDK in `localOnly` mode if you have previously cached configurations. The app will use the local cache without trying to fetch from remote.

## Configuration

In the example app, you can configure:

- **Base URL**: The base URL of your backend API
- **Environment**: The environment identifier (e.g., "staging", "production")
- **Load Mode**: 
  - `Hybrid`: Check local cache, sync if needed (default)
  - `Local Only`: Use cache only, never fetch remote
  - `Remote Only`: Always fetch from remote, ignore cache

## Features Demonstrated

- ✅ Remote configuration fetching
- ✅ Local caching with SharedPreferences
- ✅ Sync checking
- ✅ Error handling
- ✅ Different load modes
- ✅ Builder pattern usage
- ✅ Logging

## Troubleshooting

### CORS Issues (Web)

If you're running the web app and getting CORS errors, make sure your backend allows CORS from your Flutter app origin:

**Spring Boot**:
```kotlin
@Configuration
class CorsConfig {
    @Bean
    fun corsFilter(): CorsFilter {
        val source = UrlBasedCorsConfigurationSource()
        val config = CorsConfiguration()
        config.allowCredentials = true
        config.addAllowedOrigin("*") // Or specific origin
        config.addAllowedHeader("*")
        config.addAllowedMethod("*")
        source.registerCorsConfiguration("/**", config)
        return CorsFilter(source)
    }
}
```

**Django**:
```python
# settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
]
```

### Network Errors

- Make sure your backend is running
- Check the base URL is correct
- Verify the endpoints match the expected format
- Check browser console for detailed error messages

