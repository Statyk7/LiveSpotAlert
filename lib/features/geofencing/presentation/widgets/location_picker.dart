import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import 'geofence_map_widget.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialRadius = 100.0,
    required this.onLocationSelected,
    required this.onCancel,
    this.onRadiusChanged,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final double initialRadius;
  final Function(double latitude, double longitude) onLocationSelected;
  final VoidCallback onCancel;
  final Function(double radius)? onRadiusChanged;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  void _onMapLocationChanged(double latitude, double longitude) {
    widget.onLocationSelected(latitude, longitude);
  }

  void _onMapRadiusChanged(double radius) {
    if (widget.onRadiusChanged != null) {
      widget.onRadiusChanged!(radius);
    }
  }

  @override
  Widget build(BuildContext context) {
    return
      // Map widget takes full remaining space
      Expanded(
        child: GeofenceMapWidget(
          initialLatitude: widget.initialLatitude,
          initialLongitude: widget.initialLongitude,
          initialRadius: widget.initialRadius,
          onLocationChanged: _onMapLocationChanged,
          onRadiusChanged: _onMapRadiusChanged,
        ),
      );
  }
}
