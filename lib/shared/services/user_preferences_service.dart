import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../base_domain/failures/failure.dart';

/// Service for managing user preferences across the application
abstract class UserPreferencesService {
  Future<Either<Failure, bool>> getMonitoringEnabled();
  Future<Either<Failure, void>> setMonitoringEnabled(bool enabled);
  
  // Future methods for other preferences can be added here
  // Future<Either<Failure, String>> getThemeMode();
  // Future<Either<Failure, void>> setThemeMode(String theme);
}

class UserPreferencesServiceImpl implements UserPreferencesService {
  UserPreferencesServiceImpl(this._sharedPreferences);
  
  final SharedPreferences _sharedPreferences;
  
  // Preference keys
  static const String _monitoringEnabledKey = 'monitoring_enabled';
  
  @override
  Future<Either<Failure, bool>> getMonitoringEnabled() async {
    try {
      final enabled = _sharedPreferences.getBool(_monitoringEnabledKey) ?? false;
      return Right(enabled);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get monitoring preference: $e'));
    }
  }
  
  @override
  Future<Either<Failure, void>> setMonitoringEnabled(bool enabled) async {
    try {
      await _sharedPreferences.setBool(_monitoringEnabledKey, enabled);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save monitoring preference: $e'));
    }
  }
}