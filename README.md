# LiveSpotAlert

iOS Flutter app with Live Activities and Notifications triggered by geofencing - displays configurable images like QR codes when arriving at specific locations.
This is an experiment using Claude Code to build entirely an app from scratch. More details in this ![article](https://medium.com/@remy.baudet/building-a-flutter-app-with-claude-code-and-feature-first-clean-architecture-fa89fe5aa58b).

<p>
  <image alt="Main View" src="./specs/screenshots/LiveSpotAlert%20-%20Main%20View.png" width="200" />
  <image alt="Geofence Configuration" src="./specs/screenshots/LiveSpotAlert%20-%20Geofence%20Configuration.png" width="200" />
  <image alt="Notification Configuration" src="./specs/screenshots/LiveSpotAlert%20-%20Notification%20Configuration.png" width="200" />
  <image alt="Notification View" src="./specs/screenshots/LiveSpotAlert%20-%20Notification%20View.png" width="200" />
</p>

<p>
  <a href="https://apps.apple.com/us/app/livespotalert/id6748239112?itscg=30200&itsct=apps_box_link&mttnsubad=6748239112">
     <img alt="Download on the App Store" src="./specs/App%20Store%20Connect%20Assets/Link%20Card%20Preview%20Image%20-%201200x628.png" width="600">
  </a>
</p>

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/yellow_img.png)](https://www.buymeacoffee.com/remstation)

## Features

- 🗺️ **Geofencing**: Create location-based triggers using flutter_background_geolocation
- 📱 **Local Notifications**: Display local notification when entering geofenced areas
- 📱 **Live Activities (Future)**: Display iOS Live Activities when entering geofenced areas - Disabled because currently works only when the app is in the foreground...
- 🖼️ **Media Management**: Configure custom images, QR codes, or content for each location
- 🏗️ **Clean Architecture**: Built with ![Feature-First Clean Architecture (FFCA)](https://medium.com/@remy.baudet/feature-first-clean-architecture-for-flutter-246366e71c18)
- 🧪 **State Management**: Uses BLoC pattern for predictable state management

## Architecture

This project follows **Feature-First Clean Architecture** principles with:

- **Apps Layer**: Main application composition and routing
- **Shared Layer**: Common utilities, base classes, and UI components
- **Features Layer**: Independent features with their own Clean Architecture layers
  - `geofencing/`: Location monitoring and geofence management
  - `live_activities/`: iOS Live Activities integration
  - `local_notifications/`: Local Notifications integration
  - `media_management/`: Image storage and QR code generation

## Requirements

- Flutter 3.5.3+
- iOS 16.1+ (for Live Activities)
- Xcode 14+

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
    ├── local_notifications/       # Local Notifications
    └── media_management/          # Image and QR code handling
```

## Notable Flutter packages used:
- flutter_background_geolocation - True background geofencing (even when app is not running)
- flutter_map - OpenStreetMap integration
- flutter_local_notifications - Smart notification system
- bloc - State Management
- go_router - Navigation
- get_it - Dependency Injection
- slang - i18n support (EN/ES/FR)
- posthog_flutter & sentry_flutter - Analytics & monitoring
- in_app_purchase - Donation system
- shorebird (future) - Patch release updates


## License

MIT License - see LICENSE file for details.
