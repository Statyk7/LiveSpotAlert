import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dartz/dartz.dart';
import '../../../../../shared/base_domain/failures/failure.dart';
import '../../../domain/models/notification_config.dart';

/// Data source for storing and retrieving notification configuration from local storage
abstract class NotificationConfigLocalDataSource {
  /// Save notification configuration to SharedPreferences
  Future<Either<Failure, void>> saveNotificationConfig(
      NotificationConfig config);

  /// Load notification configuration from SharedPreferences
  /// Returns default config if no saved config exists
  Future<Either<Failure, NotificationConfig>> loadNotificationConfig();

  /// Clear saved notification configuration
  Future<Either<Failure, void>> clearNotificationConfig();
}

class NotificationConfigLocalDataSourceImpl
    implements NotificationConfigLocalDataSource {
  NotificationConfigLocalDataSourceImpl(this.sharedPreferences);

  final SharedPreferences sharedPreferences;

  static const String _notificationConfigKey = 'notification_config';

  @override
  Future<Either<Failure, void>> saveNotificationConfig(
      NotificationConfig config) async {
    try {
      final jsonString = jsonEncode(config.toJson());
      final success =
          await sharedPreferences.setString(_notificationConfigKey, jsonString);

      if (success) {
        return const Right(null);
      } else {
        return Left(
            CacheFailure(message: 'Failed to save notification configuration'));
      }
    } catch (e) {
      return Left(
          CacheFailure(message: 'Error saving notification configuration: $e'));
    }
  }

  @override
  Future<Either<Failure, NotificationConfig>> loadNotificationConfig() async {
    try {
      final jsonString = sharedPreferences.getString(_notificationConfigKey);

      if (jsonString == null) {
        // Return default configuration if no saved config exists
        return Right(NotificationConfig.defaultConfig());
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      final config = NotificationConfig.fromJson(jsonMap);

      return Right(config);
    } catch (e) {
      // Return default configuration if there's an error loading
      return Right(NotificationConfig.defaultConfig());
    }
  }

  @override
  Future<Either<Failure, void>> clearNotificationConfig() async {
    try {
      final success = await sharedPreferences.remove(_notificationConfigKey);

      if (success) {
        return const Right(null);
      } else {
        return Left(CacheFailure(
            message: 'Failed to clear notification configuration'));
      }
    } catch (e) {
      return Left(CacheFailure(
          message: 'Error clearing notification configuration: $e'));
    }
  }
}
