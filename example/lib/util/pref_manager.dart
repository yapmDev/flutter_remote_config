import 'package:shared_preferences/shared_preferences.dart';

/// This class follow the singleton pattern and is responsible for the internal control of shared
/// preferences, allowing fast and efficient access to data.
class SharedPrefsManager {

  static SharedPrefsManager? _instance;

  final SharedPreferences _prefs;

  /// Access to the class instance. Needs a previous call on [init].
  factory SharedPrefsManager() {
    assert (_instance != null, "Try initializing first using the init method.");
    return _instance!;
  }

  const SharedPrefsManager._internal(this._prefs);

  /// Enables and loads preferences.
  static Future<void> init() async {
    if(_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = SharedPrefsManager._internal(prefs);
    }
  }

  String? getString(String key) => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}