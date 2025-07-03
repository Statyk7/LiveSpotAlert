import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Helper class to write to iOS App Group UserDefaults
/// Required for sharing data between the main app and Live Activity widgets
class SharedUserDefaults {
  static const MethodChannel _channel = MethodChannel('shared_user_defaults');
  static const String _appGroupId = 'group.livespotalert.liveactivities';

  /// Store a string value in the shared UserDefaults
  static Future<bool> setString(String key, String value) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) {
      debugPrint('SharedUserDefaults: Skipping on non-iOS platform');
      return true;
    }

    try {
      final result = await _channel.invokeMethod('setString', {
        'appGroupId': _appGroupId,
        'key': key,
        'value': value,
      });
      debugPrint('SharedUserDefaults: Stored $key = $value (success: $result)');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('SharedUserDefaults: Error storing $key: $e');
      return false;
    }
  }

  /// Remove a value from the shared UserDefaults
  static Future<bool> remove(String key) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) {
      debugPrint('SharedUserDefaults: Skipping on non-iOS platform');
      return true;
    }

    try {
      final result = await _channel.invokeMethod('remove', {
        'appGroupId': _appGroupId,
        'key': key,
      });
      debugPrint('SharedUserDefaults: Removed $key (success: $result)');
      return result as bool? ?? false;
    } catch (e) {
      debugPrint('SharedUserDefaults: Error removing $key: $e');
      return false;
    }
  }

  /// Get a string value from the shared UserDefaults
  static Future<String?> getString(String key) async {
    if (!defaultTargetPlatform.name.toLowerCase().contains('ios')) {
      debugPrint('SharedUserDefaults: Skipping on non-iOS platform');
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getString', {
        'appGroupId': _appGroupId,
        'key': key,
      });
      debugPrint('SharedUserDefaults: Retrieved $key = $result');
      return result as String?;
    } catch (e) {
      debugPrint('SharedUserDefaults: Error retrieving $key: $e');
      return null;
    }
  }
}
