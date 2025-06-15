import 'package:get_it/get_it.dart';

/// Extensions for GetIt to make it more convenient to use
extension GetItExtensions on GetIt {
  /// Get a service with a more concise syntax
  T get<T extends Object>() => GetIt.instance<T>();
  
  /// Check if a service is registered
  bool has<T extends Object>() => GetIt.instance.isRegistered<T>();
  
  /// Register a factory that creates a new instance every time
  void registerFactory<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
  }) {
    GetIt.instance.registerFactory<T>(factoryFunc, instanceName: instanceName);
  }
  
  /// Register a singleton instance
  void registerSingleton<T extends Object>(
    T instance, {
    String? instanceName,
    bool? signalsReady,
    DisposingFunc<T>? dispose,
  }) {
    GetIt.instance.registerSingleton<T>(
      instance,
      instanceName: instanceName,
      signalsReady: signalsReady,
      dispose: dispose,
    );
  }
  
  /// Register a lazy singleton
  void registerLazySingleton<T extends Object>(
    T Function() factoryFunc, {
    String? instanceName,
    DisposingFunc<T>? dispose,
  }) {
    GetIt.instance.registerLazySingleton<T>(
      factoryFunc,
      instanceName: instanceName,
      dispose: dispose,
    );
  }
}

/// Global shorthand for GetIt.instance
final getIt = GetIt.instance;