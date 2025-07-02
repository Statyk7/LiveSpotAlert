# Main Screen Issues - Improvement Plan

Based on the requirements in `specs/requirements.md`, this document outlines the plan to address the identified issues in the main screen.

## Issues to Address

### 1. Location Monitoring Persistence
**Issue**: The Location Monitoring option should be persisted on disk and retrieved when the app restarts.

**Current State**: 
- Location monitoring state is likely stored only in memory (BLoC state)
- When app restarts, monitoring preference is lost

**Solution Plan**:
- Add monitoring preference to `SharedPreferences` storage
- Create `UserPreferencesService` in shared layer (generic service for all user preferences)
- Update `GeofencingBloc` to:
  - Load monitoring preference on app startup using `UserPreferencesService`
  - Save monitoring preference when user toggles it
- Ensure monitoring state persists across app restarts

**Files to Modify**:
- `lib/shared/services/user_preferences_service.dart` (new - generic preferences service)
- `lib/shared/di/service_locator.dart` (register new service)
- `lib/features/geofencing/presentation/controllers/geofencing_bloc.dart` (persistence logic)
- `lib/apps/live_spot_alert/presentation/screens/main_screen.dart` (initialization)

### 2. Geofence Configuration Commands Relocation
**Issue**: The command to configure the geofence should be in the corresponding geofence card instead of in the AppBar, no need to have a delete command.

**Current State**:
- Configuration/edit commands are likely in the AppBar
- Delete command exists in AppBar (should be removed)
- Commands are not contextually placed with geofence cards

**Solution Plan**:
- Remove configuration and delete commands from AppBar
- Add "Configure" button/icon to each geofence card
- Remove delete functionality entirely (as specified)
- Ensure each geofence card is self-contained for its actions

**Files to Modify**:
- `lib/apps/live_spot_alert/presentation/screens/main_screen.dart` (remove AppBar commands)
- `lib/features/geofencing/presentation/widgets/geofence_card.dart` (add configure button)

### 3. Live Activity Information Card Layout
**Issue**: The information about the Live Activity should use the same layout as the geofence with a card.

**Current State**:
- Live Activity information is likely displayed differently than geofence cards
- Inconsistent UI patterns between geofence and Live Activity sections

**Solution Plan**:
- Create `LiveActivityInfoCard` widget with same design patterns as `GeofenceCard`
- Ensure consistent styling, padding, elevation, and layout
- Use shared card components or theming for consistency
- Display Live Activity status, configuration, and controls in card format

**Files to Modify**:
- `lib/features/live_activities/presentation/widgets/live_activity_info_card.dart` (new)
- `lib/apps/live_spot_alert/presentation/screens/main_screen.dart` (use new card widget)
- `lib/shared/ui_kit/` (potential shared card styling)

### 4. Live Activity Card and Preview Separator
**Issue**: Add a separator between the Live Activity card and the Live Activity preview.

**Current State**:
- No visual separation between Live Activity card and preview sections
- May cause visual confusion or cluttered appearance

**Solution Plan**:
- Add visual separator (Divider or custom separator widget) between card and preview
- Ensure separator follows app's design system
- Maintain appropriate spacing and visual hierarchy

**Files to Modify**:
- `lib/apps/live_spot_alert/presentation/screens/main_screen.dart` (add separator)

## Implementation Priority

### Phase 1: UI/UX Improvements (Medium effort)
1. **Geofence Configuration Commands Relocation** - Move commands from AppBar to cards
2. **Live Activity Card Layout** - Create consistent card design
3. **Card and Preview Separator** - Add visual separator

### Phase 2: Data Persistence (Higher effort)
1. **Location Monitoring Persistence** - Implement disk storage and retrieval

## Technical Considerations

### Shared Components
- Consider creating reusable card components in `lib/shared/ui_kit/`
- Ensure consistent theming across all card widgets
- Follow Material Design principles for card elevation and spacing

### State Management
- Monitoring persistence will require BLoC state changes
- Ensure proper error handling for preference loading/saving
- Consider loading states during app initialization

### Testing Strategy
- Unit tests for `UserPreferencesService` (can test multiple preference types)
- Widget tests for card components
- Integration tests for monitoring persistence flow

## Architecture Compliance

This plan follows the Feature-First Clean Architecture requirements:
- New services go in appropriate shared or feature layers
- BLoC pattern maintained for state management
- GetIt used for dependency injection
- Small, composable widgets preferred
- Theming through MaterialApp rather than hardcoded values

## Success Criteria

1. ✅ Location monitoring preference survives app restarts
2. ✅ Geofence cards contain their own configuration controls
3. ✅ AppBar is cleaned of geofence-specific commands
4. ✅ Live Activity information uses consistent card layout
5. ✅ Clear visual separation between Live Activity card and preview
6. ✅ UI remains responsive across different screen sizes
7. ✅ All changes follow established architecture patterns