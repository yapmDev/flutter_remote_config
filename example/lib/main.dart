import 'package:blendberry_flutter_sdk/blendberry_flutter_sdk.dart';
import 'package:example/impl/mapper.dart';
import 'package:example/impl/mediator.dart';
import 'package:example/impl/repository.dart';
import 'package:example/impl/service.dart';
import 'package:example/util/pref_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefsManager.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlendBerry SDK Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ConfigExamplePage(),
    );
  }
}

class ConfigExamplePage extends StatefulWidget {
  const ConfigExamplePage({super.key});

  @override
  State<ConfigExamplePage> createState() => _ConfigExamplePageState();
}

class _ConfigExamplePageState extends State<ConfigExamplePage> {
  RemoteConfigMediator? _mediator;
  bool _isLoading = false;
  String? _error;
  String? _configValue;
  String _baseUrl = 'http://localhost:8080/configs';
  String _environment = 'staging';
  LoadMode _loadMode = LoadMode.hybrid;

  @override
  void initState() {
    super.initState();
    _initializeMediator();
  }

  void _initializeMediator() {
    try {
      _mediator = RemoteConfigMediatorImpl.instance;
    } catch (e) {
      setState(() {
        _error = 'Failed to initialize mediator: $e';
      });
    }
  }

  Future<void> _loadConfigs() async {
    if (_mediator == null) {
      setState(() {
        _error = 'Mediator not initialized';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _configValue = null;
    });

    try {
      // Create mediator with current configuration
      _mediator = RemoteConfigBuilder()
          .withService(RemoteConfigServiceImpl(_baseUrl))
          .withRepository(LocalConfigRepositoryImpl())
          .withLoadMode(_loadMode)
          .enableLogging(true)
          .build();

      await _mediator!.loadConfigs(_environment);
      final config = _mediator!.dispatch(CustomMapper());

      setState(() {
        _configValue = 'useDarkTheme: ${config.useDarkTheme}';
        _isLoading = false;
      });

      if (kDebugMode) {
        print('Configuration loaded successfully: $_configValue');
      }
    } on ConfigNotFoundException catch (e) {
      setState(() {
        _error = 'Configuration not found: ${e.message}';
        _isLoading = false;
      });
    } on ConfigSyncException catch (e) {
      setState(() {
        _error = 'Sync error: ${e.message}';
        _isLoading = false;
      });
    } on ConfigDataException catch (e) {
      setState(() {
        _error = 'Data error: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    try {
      final repository = LocalConfigRepositoryImpl();
      await repository.clearCache();
      setState(() {
        _configValue = null;
        _error = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to clear cache: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BlendBerry SDK Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Configuration Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Base URL',
                        border: OutlineInputBorder(),
                        hintText: 'http://localhost:8080/configs',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _baseUrl = value;
                        });
                      },
                      controller: TextEditingController(text: _baseUrl),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Environment',
                        border: OutlineInputBorder(),
                        hintText: 'staging',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _environment = value;
                        });
                      },
                      controller: TextEditingController(text: _environment),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<LoadMode>(
                      decoration: const InputDecoration(
                        labelText: 'Load Mode',
                        border: OutlineInputBorder(),
                      ),
                      value: _loadMode,
                      items: const [
                        DropdownMenuItem(
                          value: LoadMode.hybrid,
                          child: Text('Hybrid (check local, sync if needed)'),
                        ),
                        DropdownMenuItem(
                          value: LoadMode.localOnly,
                          child: Text('Local Only (use cache only)'),
                        ),
                        DropdownMenuItem(
                          value: LoadMode.remoteOnly,
                          child: Text('Remote Only (always fetch)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _loadMode = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Actions Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _loadConfigs,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.cloud_download),
                      label: Text(_isLoading ? 'Loading...' : 'Load Configuration'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _clearCache,
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Clear Cache'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Results Section
            if (_error != null)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Error',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            if (_configValue != null)
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Configuration Loaded',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _configValue!,
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            if (_error == null && _configValue == null && !_isLoading)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Click "Load Configuration" to fetch from your backend',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              ),

            // API Info Section
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Endpoints Expected',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'GET \${baseUrl}/{env}?version={version}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Returns JSON matching RemoteConfigModel format:',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '{\n'
                      '  "appId": "string",\n'
                      '  "env": "string",\n'
                      '  "version": "string",\n'
                      '  "configs": {"useDarkTheme": true},\n'
                      '  "lastModDate": "2024-01-01T00:00:00Z"\n'
                      '}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'GET \${baseUrl}/lookup?env={env}&version={version}&syncIdentifier={id}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Returns: "UP_TO_DATE", "NEEDS_TO_UPDATE", "NOT_FOUND"',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
