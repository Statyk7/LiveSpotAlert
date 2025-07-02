# LiveSpotAlert
I would like to create a mobile application using Flutter that displays a Live Activity on iOS, when arriving at a specific location, using Geofencing. That Live Activity would be configurable to display an image like a QR code.

# Functional Requirements
## 1. Geofencing
- Pick location from a map
- Show a radius on the map and allows the user to change it
- Allow the user to give the Geofence a friendly name
- Save and Exit options

## 2. Live Activities


# Non-Functional Requirements
## Architecture
- Use the Feature-First Clean Architecture approach that I have defined in this article: https://medium.com/@remy.baudet/feature-first-clean-architecture-for-flutter-246366e71c18
- Use BLoC as the State Management.
- Use GetIt and service locator for Dependency Injection.
- Prefer small composable widgets over large ones.
- Prefer using flex values over hardcoded sizes when creating widgets inside rows/columns, ensuring the UI adapts to various screen sizes.
- Use 'log' from 'dart:developer' rather than 'print' or 'debugPrint' for logging.

## Theming
- Theming should be done by setting the theme in the MaterialApp, rather than hardcoding colors and sizes in the widgets themselves.


# Issues in Main Screen
- The Location Monitoring option should be persisted on disk and retrieve when the app restart
- The command to configure the geofence should be in the corresponding geofence card instead of in the AppBar, no need to have a delete command
- The information about the Live Activity should use the same layout as the geofence with a card
- Add a separator between the Live Activity card and the Live Activity preview
