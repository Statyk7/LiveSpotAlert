# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LiveSpotAlert is an iOS Flutter app that triggers Live Activities through geofencing. Users can create location-based triggers that display configurable images (like QR codes) when arriving at specific locations.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Run the app (iOS only)
flutter run --flavor dev -t lib/main.dart

# Build for iOS
flutter build ios

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .
```

### iOS Development
```bash
# Open Xcode workspace
open ios/Runner.xcworkspace

# Clean build files
flutter clean && flutter pub get
```

## Architecture

### Feature-First Clean Architecture (FFCA)

The project follows FFCA with three main layers:

#### 1. Apps Layer (`lib/apps/live_spot_alert/`)
- Main application composition and routing
- App-wide configuration and theme
- BLoC provider setup

#### 2. Shared Layer (`lib/shared/`)
- **base_domain/**: Base domain entities, failures, and use case abstractions
- **di/**: Dependency injection with GetIt service locator
- **ui_kit/**: Design system (colors, text styles, custom widgets)
- **utils/**: Common utilities and constants

#### 3. Features Layer (`lib/features/`)
Each feature follows Clean Architecture:
- **data/** (Data sources, DTOs, mappers, service implementations)
- **domain/** (Models, services interfaces, use cases)
- **presentation/** (BLoC controllers, screens, widgets)

### Current Features
- `geofencing/`: Location monitoring and geofence management (fully implemented)
- `live_activities/`: iOS Live Activities integration (domain models incomplete)
- `media_management/`: Image storage and QR code handling (mock implementation)

## Dependency Injection

Uses GetIt for service registration:

```dart
// Initialize (called in main.dart)
await ServiceLocator.init();

// Create BLoC instances
ServiceLocator.createGeofencingBloc()

// Access services directly (avoid in UI, use BLoC instead)
getIt<GeofencingService>()
```

**Registration Pattern:**
- Singletons: `getIt.registerSingleton<T>(instance)`
- Lazy Singletons: `getIt.registerLazySingleton<T>(() => factory)`
- Factories: `getIt.registerFactory<T>(() => factory)`

## State Management

Uses BLoC pattern with flutter_bloc:

### BLoC Structure
```dart
// Events: User actions and system events
abstract class GeofencingEvent extends Equatable

// States: UI state representations  
abstract class GeofencingState extends Equatable

// BLoC: Business logic and state transitions
class GeofencingBloc extends Bloc<GeofencingEvent, GeofencingState>
```

### BLoC Usage in UI
```dart
BlocBuilder<GeofencingBloc, GeofencingState>(
  builder: (context, state) {
    return switch (state) {
      GeofencingLoading() => CircularProgressIndicator(),
      GeofencingLoaded() => GeofenceList(state.geofences),
      GeofencingError() => ErrorWidget(state.message),
    };
  },
)
```

## Navigation

Uses GoRouter for navigation:

### Route Structure
```
/splash (initial)
└── /main
```

**Note:** Navigation was recently simplified. The NAVIGATION_FLOW.md and INTEGRATION.md docs reference a more complex routing structure that was consolidated into a single main screen.

## Key Dependencies

### Core
- `flutter_bloc: ^9.1.1` - State management
- `get_it: ^8.0.3` - Dependency injection  
- `go_router: ^15.1.2` - Navigation

### Geofencing
- `flutter_background_geolocation: ^4.15.0` - Background location monitoring

### Live Activities
- `live_activities: ^2.4.0+2` - iOS Live Activities integration

### Utilities
- `dartz: ^0.10.1` - Functional programming (Either, Option)
- `equatable: ^2.0.5` - Value equality
- `shared_preferences: ^2.2.0` - Local storage

## iOS Configuration

### Requirements
- iOS 16.1+ (for Live Activities)
- Physical device (Live Activities don't work on simulator)
- Apple Developer Account (for background location and Live Activities)

### Key Capabilities Required
- Background Modes (location updates)
- Push Notifications
- Live Activities
- WidgetKit Extension

### Entitlements
The app includes proper entitlements for:
- Background location access
- Live Activities support  
- Push notifications

## Development Guidelines

### Code Organization
- Follow existing FFCA patterns when adding features
- Place shared utilities in `lib/shared/`
- Keep features independent and self-contained
- Use BLoC for state management in presentation layer

### Error Handling
- Use `Either<Failure, T>` for service layer error handling
- Emit appropriate error states in BLoC
- Handle errors gracefully in UI with user-friendly messages

### Testing
- Use `bloc_test` for BLoC unit tests
- Use `mocktail` for mocking dependencies
- Test files should be in `test/` directory

## Current Development Status

### Completed
- ✅ Geofencing feature fully implemented
- ✅ GetIt dependency injection migration
- ✅ Flutter 3.32.4 upgrade
- ✅ iOS Live Activities widget support added

### In Progress / Incomplete
- ⚠️ Live Activities domain models incomplete
- ⚠️ Media management uses mock implementation
- ⚠️ Simplified navigation (main screen only)

### Known Issues
- Navigation routing was recently simplified - some documentation may reference old routing structure
- Live Activities integration temporarily uses mock services
- 43 style warnings exist (non-blocking)

## Important Files to Understand

- `lib/main.dart` - App entry point and BLoC setup
- `lib/shared/di/service_locator.dart` - Dependency injection configuration
- `lib/apps/live_spot_alert/router/app_router.dart` - Navigation setup
- `lib/features/geofencing/` - Complete feature implementation example
- `pubspec.yaml` - Dependencies and project configuration

## Development Memories

- Always use a concise description when doing a commit