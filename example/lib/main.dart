import 'package:flutter/material.dart';
import 'package:flutter_remote_config/flutter_remote_config.dart';
import 'services/example_config_service.dart';
import 'repositories/example_local_repository.dart';
import 'domain/app_config.dart';
import 'domain/app_config_mapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Remote Config Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
  AppConfig? _config;
  String _status = 'Initializing...';
  bool _isLoading = false;

  late final RemoteConfigMediator _mediator;

  @override
  void initState() {
    super.initState();
    _initializeMediator();
  }

  Future<void> _initializeMediator() async {
    try {
      // Step 1: Create the service (handles remote fetching)
      // Configure with your Django API details
      final service = ExampleConfigService(
        baseUrl: 'http://localhost:8000', // Your Django server URL
        appId: 'app_demo', // Your app_id from Django Config model
      );

      // Step 2: Create the repository (handles local storage)
      final repository = await ExampleLocalRepository.create();

      // Step 3: Build the mediator using the builder pattern
      _mediator = RemoteConfigBuilder()
          .withService(service)
          .withRepository(repository)
          .withLoadMode(LoadMode.hybrid) // Check local first, sync if needed
          .enableLogging(true) // Enable logging for debugging
          .build();

      setState(() {
        _status = 'Mediator initialized. Ready to load configs.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error initializing: $e';
      });
    }
  }

  Future<void> _loadConfigs() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading configuration...';
    });

    try {
      // Step 4: Load configurations (this handles sync logic automatically)
      await _mediator.loadConfigs('staging', '3.4.2');

      // Step 5: Dispatch the configuration using the mapper
      final config = _mediator.dispatch<AppConfig>(AppConfigMapper());

      setState(() {
        _config = config;
        _status = 'Configuration loaded successfully!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading config: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _clearCache() async {
    try {
      final repository = await ExampleLocalRepository.create();
      await repository.clearCache();
      setState(() {
        _config = null;
        _status = 'Cache cleared. Next load will fetch from remote.';
      });
    } catch (e) {
      setState(() {
        _status = 'Error clearing cache: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Remote Config Example'),
        ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const LinearProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadConfigs,
                    icon: const Icon(Icons.download),
                    label: const Text('Load Config'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _clearCache,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Cache'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Configuration display
            if (_config != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Loaded Configuration',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildConfigRow('Theme', _config!.theme),
                      _buildConfigRow('API URL', _config!.apiUrl),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Feature Flags',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildConfigRow('Feature A', _config!.features.featureA.toString()),
                      _buildConfigRow('Feature B', _config!.features.featureB.toString()),
                      _buildConfigRow('Feature C', _config!.features.featureC.toString()),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildConfigRow('Timeout', '${_config!.settings.timeout}s'),
                      _buildConfigRow('Retries', _config!.settings.retries.toString()),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
