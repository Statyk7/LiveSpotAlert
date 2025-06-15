# Navigation Flow Documentation

## Complete Navigation Structure

### 🏠 Home Screen (`/home`)
- **Navigation In**: From splash screen
- **Navigation Out**: 
  - Tap "Geofences" → `/geofences`
  - Tap "Live Activities" → `/status` (debug page)
  - Tap "Media" → Not implemented yet

### 📍 Geofences List (`/geofences`)
- **Navigation In**: From home screen
- **Navigation Out**:
  - Back button (←) → `/home`
  - FAB (+) → `/geofences/create`
  - Refresh button (🔄) → Reload data
- **Actions**:
  - View geofence details in expandable cards
  - Delete geofences via confirmation dialog

### ➕ Create Geofence (`/geofences/create`)
- **Navigation In**: From geofences list
- **Navigation Out**:
  - Close button (✕) → `/geofences`
  - Save success → `/geofences` (automatic)
- **Actions**:
  - Fill form and save new geofence
  - Pick location from predefined list or manual coordinates

### 📊 App Status (`/status`)
- **Navigation In**: From home screen (via "Live Activities" card)
- **Navigation Out**:
  - Back button (←) → `/home`
  - "Test Geofencing Features" button → `/geofences`

## Navigation Patterns

### Back Button Behavior
```dart
// Geofences List
leading: IconButton(
  icon: const Icon(Icons.arrow_back, color: Colors.white),
  onPressed: () => context.go('/home'),
),

// Create Geofence
leading: IconButton(
  icon: const Icon(Icons.close, color: Colors.white),
  onPressed: () => context.go('/geofences'),
),

// App Status
leading: IconButton(
  icon: const Icon(Icons.arrow_back),
  onPressed: () => context.go('/home'),
),
```

### Route Structure
```
/splash (initial)
└── /home
    ├── /geofences
    │   ├── /geofences/create
    │   └── /geofences/edit/:id (future)
    └── /status
```

### Navigation Methods Used
- **GoRouter**: `context.go('/route')` for direct navigation
- **AppBar leading**: Manual back buttons for custom behavior
- **FloatingActionButton**: Quick actions (create geofence)
- **Card onTap**: Navigate to features from home

### User Experience Flow

1. **App Launch**: Splash → Home
2. **View Geofences**: Home → Geofences List
3. **Create Geofence**: Geofences List → Create Form → Back to List
4. **Debug Info**: Home → Status → Back to Home
5. **Return Home**: Any screen → Home (via back buttons)

### Accessibility Features
- Clear visual hierarchy with consistent AppBar styling
- Intuitive icon usage (← for back, ✕ for close, + for create)
- Consistent color scheme (white icons on primary background)
- Logical navigation flow that matches user expectations

### Future Enhancements
- [ ] Breadcrumb navigation for deep nesting
- [ ] Bottom navigation bar for main sections
- [ ] Swipe gestures for mobile-friendly navigation
- [ ] Deep linking support for specific geofences