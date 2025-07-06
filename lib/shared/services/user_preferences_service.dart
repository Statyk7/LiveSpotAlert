import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base_domain/failures/failure.dart';

/// Service for managing user preferences across the application
abstract class UserPreferencesService {
  Future<Either<Failure, bool>> getMonitoringEnabled();
  Future<Either<Failure, void>> setMonitoringEnabled(bool enabled);

  // Notification image storage
  Future<Either<Failure, String?>> getNotificationImageBase64();
  Future<Either<Failure, void>> setNotificationImageBase64(String? imageBase64Data);
  Future<Either<Failure, void>> clearNotificationImageBase64();

  // Future methods for other preferences can be added here
  // Future<Either<Failure, String>> getThemeMode();
  // Future<Either<Failure, void>> setThemeMode(String theme);
}

class UserPreferencesServiceImpl implements UserPreferencesService {
  UserPreferencesServiceImpl(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  // Preference keys
  static const String _monitoringEnabledKey = 'monitoring_enabled';
  static const String _notificationImageBase64Key = 'notification_image_base64';

  @override
  Future<Either<Failure, bool>> getMonitoringEnabled() async {
    try {
      final enabled =
          _sharedPreferences.getBool(_monitoringEnabledKey) ?? false;
      return Right(enabled);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to get monitoring preference: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setMonitoringEnabled(bool enabled) async {
    try {
      await _sharedPreferences.setBool(_monitoringEnabledKey, enabled);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to save monitoring preference: $e'));
    }
  }

  @override
  Future<Either<Failure, String?>> getNotificationImageBase64() async {
    try {
      final imageBase64Data = _sharedPreferences.getString(_notificationImageBase64Key);
      return Right(imageBase64Data);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to get notification image data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setNotificationImageBase64(String? imageBase64Data) async {
    try {
      if (imageBase64Data == null) {
        await _sharedPreferences.remove(_notificationImageBase64Key);
      } else {
        await _sharedPreferences.setString(_notificationImageBase64Key, imageBase64Data);
      }
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to save notification image data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearNotificationImageBase64() async {
    try {
      await _sharedPreferences.remove(_notificationImageBase64Key);
      return const Right(null);
    } catch (e) {
      return Left(
          CacheFailure(message: 'Failed to clear notification image data: $e'));
    }
  }
}
