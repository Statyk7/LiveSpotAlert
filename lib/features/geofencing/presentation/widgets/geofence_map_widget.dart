import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';

/// Interactive map widget for geofence configuration
class GeofenceMapWidget extends StatefulWidget {
  const GeofenceMapWidget({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRadius = 100.0,
    required this.onLocationChanged,
    required this.onRadiusChanged,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final double initialRadius;
  final Function(double latitude, double longitude) onLocationChanged;
  final Function(double radius) onRadiusChanged;

  @override
  State<GeofenceMapWidget> createState() => _GeofenceMapWidgetState();
}

class _GeofenceMapWidgetState extends State<GeofenceMapWidget> {
  late final MapController _mapController;
  late LatLng _geofenceCenter;
  late double _geofenceRadius;
  LatLng? _currentLocation;
  StreamSubscription<bg.Location>? _locationSubscription;
  bool _isMapReady = false;

  // Default location (Apple Park) if no initial location provided
  static const LatLng _defaultLocation = LatLng(37.33233141, -122.0312186);

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _geofenceRadius = widget.initialRadius;
    
    // Set initial geofence center
    _geofenceCenter = LatLng(
      widget.initialLatitude ?? _defaultLocation.latitude,
      widget.initialLongitude ?? _defaultLocation.longitude,
    );

    _initializeLocation();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    try {
      // Get current location if available
      final location = await bg.BackgroundGeolocation.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(location.coords.latitude, location.coords.longitude);
          
          // If no initial location provided, use current location
          if (widget.initialLatitude == null || widget.initialLongitude == null) {
            _geofenceCenter = _currentLocation!;
            widget.onLocationChanged(_geofenceCenter.latitude, _geofenceCenter.longitude);
          }
        });

        // Center map on appropriate location after it's ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isMapReady) {
            _centerMapOnLocation(_geofenceCenter);
          }
        });
      }

      // Set up location updates using the correct API
      bg.BackgroundGeolocation.onLocation((bg.Location locationEvent) {
        if (mounted) {
          setState(() {
            _currentLocation = LatLng(locationEvent.coords.latitude, locationEvent.coords.longitude);
          });
        }
      });
    } catch (e) {
      // Handle location permission issues gracefully
      debugPrint('Location initialization failed: $e');
    }
  }

  void _centerMapOnLocation(LatLng location) {
    _mapController.move(location, 16.0);
  }

  void _centerOnCurrentLocation() {
    if (_currentLocation != null) {
      _centerMapOnLocation(_currentLocation!);
    }
  }

  void _centerOnGeofence() {
    _centerMapOnLocation(_geofenceCenter);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _geofenceCenter = point;
    });
    widget.onLocationChanged(point.latitude, point.longitude);
  }

  void _onGeofenceMarkerDragEnd(LatLng point) {
    setState(() {
      _geofenceCenter = point;
    });
    widget.onLocationChanged(point.latitude, point.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Map controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Tap map or drag marker to set location',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_currentLocation != null)
                IconButton(
                  onPressed: _centerOnCurrentLocation,
                  icon: const Icon(Icons.my_location, size: 20),
                  tooltip: 'Center on my location',
                  style: IconButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                ),
              IconButton(
                onPressed: _centerOnGeofence,
                icon: const Icon(Icons.center_focus_strong, size: 20),
                tooltip: 'Center on geofence',
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.surface,
                  padding: const EdgeInsets.all(8),
                  minimumSize: const Size(36, 36),
                ),
              ),
            ],
          ),
        ),

        // Map
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _geofenceCenter,
                initialZoom: 16.0,
                minZoom: 5.0,
                maxZoom: 18.0,
                onTap: _onMapTap,
                onMapReady: () {
                  setState(() {
                    _isMapReady = true;
                  });
                },
              ),
              children: [
                // Tile layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.live_spot_alert',
                  maxZoom: 18,
                ),

                // Geofence circle
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: _geofenceCenter,
                      radius: _geofenceRadius,
                      useRadiusInMeter: true,
                      color: AppColors.primary.withValues(alpha: 0.3),
                      borderColor: AppColors.primary,
                      borderStrokeWidth: 2.0,
                    ),
                  ],
                ),

                // Markers
                MarkerLayer(
                  markers: [
                    // Current location marker
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 20,
                        height: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),

                    // Geofence center marker (draggable)
                    Marker(
                      point: _geofenceCenter,
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          // Convert screen coordinates to map coordinates
                          final RenderBox renderBox = context.findRenderObject() as RenderBox;
                          final localPosition = renderBox.globalToLocal(details.globalPosition);
                          
                          // Calculate the map bounds and convert to lat/lng
                          final mapBounds = _mapController.camera.visibleBounds;
                          final mapSize = renderBox.size;
                          
                          final lat = mapBounds.north - 
                              (localPosition.dy / mapSize.height) * 
                              (mapBounds.north - mapBounds.south);
                          final lng = mapBounds.west + 
                              (localPosition.dx / mapSize.width) * 
                              (mapBounds.east - mapBounds.west);
                          
                          final newPoint = LatLng(lat, lng);
                          _onGeofenceMarkerDragEnd(newPoint);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Radius control
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Radius: ${_geofenceRadius.toInt()}m',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '10m',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '1km',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Slider(
                value: _geofenceRadius,
                min: 10.0,
                max: 1000.0,
                divisions: 99,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  setState(() {
                    _geofenceRadius = value;
                  });
                  widget.onRadiusChanged(value);
                },
              ),
            ],
          ),
        ),

        // Location info
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Location: ${_geofenceCenter.latitude.toStringAsFixed(4)}, ${_geofenceCenter.longitude.toStringAsFixed(4)}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.info,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}