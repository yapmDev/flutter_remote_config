# BlendBerry Flutter SDK - Example App

This example demonstrates how to integrate the BlendBerry Flutter SDK with a Django REST API backend.

## Django Backend Setup

Your Django backend should have a `Config` model with the following structure:

```python
class Config(models.Model):
    class Meta:
        unique_together = [['app_id', 'env', 'version']]

    app_id = models.CharField(max_length=255)
    env = models.CharField(max_length=255)
    version = models.CharField(max_length=255)
    configs = models.JSONField(default=dict)
    created_date = models.DateTimeField(auto_now_add=True)
    last_modified_date = models.DateTimeField(auto_now=True)
```

## Django REST Framework Setup

You need to create a ViewSet or API endpoint that exposes your Config model. Example:

```python
# serializers.py
from rest_framework import serializers
from .models import Config

class ConfigSerializer(serializers.ModelSerializer):
    class Meta:
        model = Config
        fields = '__all__'

# views.py
from rest_framework import viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from .models import Config
from .serializers import ConfigSerializer

class ConfigViewSet(viewsets.ReadOnlyModelViewSet):
    queryset = Config.objects.all()
    serializer_class = ConfigSerializer
    
    @action(detail=False, methods=['get', 'head'], url_path='(?P<app_id>[^/.]+)/(?P<env>[^/.]+)/(?P<version>[^/.]+)')
    def get_by_params(self, request, app_id=None, env=None, version=None):
        try:
            config = Config.objects.get(app_id=app_id, env=env, version=version)
            serializer = self.get_serializer(config)
            return Response(serializer.data)
        except Config.DoesNotExist:
            return Response(status=404)
```

## URL Configuration

Add to your `urls.py`:

```python
from rest_framework.routers import DefaultRouter
from .views import ConfigViewSet

router = DefaultRouter()
router.register(r'configs', ConfigViewSet, basename='config')

urlpatterns = [
    path('api/', include(router.urls)),
]
```

This will create endpoints like:
- `GET /api/configs/{app_id}/{env}/{version}/` - Fetch full config
- `HEAD /api/configs/{app_id}/{env}/{version}/` - Check for updates (sync check)

## Flutter App Configuration

In `main.dart`, configure the service with your Django server details:

```dart
final service = ExampleConfigService(
  baseUrl: 'http://localhost:8000', // Your Django server URL
  appId: 'my_app', // Your app_id from Django Config model
);
```

**Note for Android Emulator**: Use `http://10.0.2.2:8000` instead of `localhost:8000`

**Note for iOS Simulator**: `localhost:8000` should work fine

## Testing

1. Start your Django server: `python manage.py runserver`
2. Create a test config in Django admin or via API:
   ```json
   {
     "app_id": "my_app",
     "env": "prod",
     "version": "1.0.0",
     "configs": {
       "theme": "dark",
       "apiUrl": "https://api.example.com",
       "features": {
         "featureA": true,
         "featureB": false,
         "featureC": true
       },
       "settings": {
         "timeout": 30,
         "retries": 3
       }
     }
   }
   ```
3. Run the Flutter app: `flutter run`
4. Tap "Load Config" to fetch from your Django API

## API Response Format

The Django API should return JSON in this format:

```json
{
  "id": 1,
  "app_id": "my_app",
  "env": "prod",
  "version": "1.0.0",
  "configs": {
    "theme": "dark",
    "apiUrl": "https://api.example.com",
    "features": {
      "featureA": true,
      "featureB": false,
      "featureC": true
    },
    "settings": {
      "timeout": 30,
      "retries": 3
    }
  },
  "created_date": "2024-01-01T00:00:00Z",
  "last_modified_date": "2024-01-01T00:00:00Z"
}
```

The SDK will extract:
- `configs` → Used as the configuration data
- `version` → Used for version tracking
- `last_modified_date` → Used for sync checking
