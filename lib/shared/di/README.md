# Dependency Injection with GetIt

This app uses [GetIt](https://pub.dev/packages/get_it) for dependency injection, providing a clean and efficient way to manage service dependencies.

## Architecture

```
ServiceLocator (setup) → GetIt (registry) → App (usage)
```

## Registration Types

### Singleton
Registered once, same instance returned every time:
```dart
getIt.registerSingleton<SharedPreferences>(sharedPreferences);
```

### Lazy Singleton  
Registered once but created only when first requested:
```dart
getIt.registerLazySingleton<GeofencingService>(
  () => GeofencingServiceImpl(...)
);
```

### Factory
Creates new instance every time:
```dart
getIt.registerFactory<GeofencingBloc>(
  () => GeofencingBloc(...)
);
```

## Usage Examples

### Getting Services
```dart
// Direct usage
final service = getIt<GeofencingService>();

// In widgets with context
final bloc = ServiceLocator.createGeofencingBloc();

// Check if registered
if (getIt.isRegistered<GeofencingService>()) {
  // Use service
}
```

### BLoC Integration
```dart
BlocProvider<GeofencingBloc>(
  create: (context) => ServiceLocator.createGeofencingBloc()
    ..add(const GeofencingStarted()),
),
```

### Adding New Services

1. **Register in ServiceLocator.init()**:
```dart
getIt.registerLazySingleton<NewService>(
  () => NewServiceImpl(getIt<Dependency>()),
);
```

2. **Use anywhere**:
```dart
final service = getIt<NewService>();
```

## Service Hierarchy

```
SharedPreferences (singleton)
├── GeofenceLocalDataSource (lazy singleton)
├── BackgroundGeolocationDataSource (lazy singleton)
├── MediaService (lazy singleton)
└── GeofencingService (lazy singleton)
    └── Use Cases (lazy singletons)
        ├── GetGeofencesUseCase
        ├── CreateGeofenceUseCase
        ├── UpdateGeofenceUseCase
        ├── DeleteGeofenceUseCase
        ├── MonitorLocationUseCase
        ├── StopMonitoringUseCase
        └── GetLocationEventsUseCase
```

## Benefits

- **Performance**: Lazy singletons are created only when needed
- **Memory**: Single instances for stateless services
- **Testing**: Easy to mock dependencies
- **Clean**: No manual dependency passing
- **Type Safe**: Compile-time type checking

## Testing Support

```dart
// Reset for tests
await ServiceLocator.reset();

// Register mocks
getIt.registerLazySingleton<GeofencingService>(
  () => MockGeofencingService(),
);
```