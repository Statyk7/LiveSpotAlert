# LiveSpotAlert

iOS Flutter app with Live Activities triggered by geofencing - displays configurable images like QR codes when arriving at specific locations.

## Features

- 🗺️ **Geofencing**: Create location-based triggers using flutter_background_geolocation
- 📱 **Live Activities**: Display iOS Live Activities when entering geofenced areas
- 🖼️ **Media Management**: Configure custom images, QR codes, or content for each location
- 🏗️ **Clean Architecture**: Built with Feature-First Clean Architecture (FFCA)
- 🧪 **State Management**: Uses BLoC pattern for predictable state management

## Architecture

This project follows **Feature-First Clean Architecture** principles with:

- **Apps Layer**: Main application composition and routing
- **Shared Layer**: Common utilities, base classes, and UI components
- **Features Layer**: Independent features with their own Clean Architecture layers
  - `geofencing/`: Location monitoring and geofence management
  - `live_activities/`: iOS Live Activities integration
  - `media_management/`: Image storage and QR code generation

## Requirements

- Flutter 3.5.3+
- iOS 16.1+ (for Live Activities)
- Xcode 14+
- iOS device for testing (Live Activities don't work on simulator)

## Setup

1. Clone the repository:
```bash
git clone https://github.com/Statyk7/LiveSpotAlert.git
cd LiveSpotAlert
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure iOS permissions in `ios/Runner/Info.plist`:
```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to trigger alerts when you arrive at specific places.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to create location-based alerts.</string>
```

4. Enable required capabilities in Xcode:
   - Background Modes (Location updates)
   - Push Notifications
   - WidgetKit Extension (for Live Activities)

## Running the App

```bash
flutter run --flavor dev -t lib/main.dart
```

## Project Structure

```
lib/
├── apps/live_spot_alert/           # Main app composition
├── shared/                         # Shared utilities and base classes
│   ├── base_domain/               # Domain base classes
│   ├── base_data/                 # Data layer base classes
│   ├── utils/                     # Common utilities
│   ├── ui_utils/                  # Flutter-specific utilities
│   └── ui_kit/                    # Design system components
└── features/                      # Feature modules
    ├── geofencing/                # Location monitoring
    ├── live_activities/           # iOS Live Activities
    └── media_management/          # Image and QR code handling
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Follow the established FFCA patterns
4. Add tests for new functionality
5. Submit a pull request

## License

MIT License - see LICENSE file for details.