import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';

class LocationPicker extends StatefulWidget {
  const LocationPicker({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    required this.onLocationSelected,
    required this.onCancel,
  });

  final double? initialLatitude;
  final double? initialLongitude;
  final Function(double latitude, double longitude) onLocationSelected;
  final VoidCallback onCancel;

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final _latController = TextEditingController();
  final _lngController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Predefined locations for demo purposes
  final List<_PredefinedLocation> _predefinedLocations = [
    _PredefinedLocation('Apple (iOS Simulator)', 37.33233141, -122.0312186),
    _PredefinedLocation('TAE Preescolar', 19.3837389, -99.1655118),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _latController.text = widget.initialLatitude!.toStringAsFixed(6);
      _lngController.text = widget.initialLongitude!.toStringAsFixed(6);
    }
  }

  @override
  void dispose() {
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Select Location',
                  style: AppTextStyles.h3,
                ),
                const Spacer(),
                TextButton(
                  onPressed: widget.onCancel,
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.button
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manual Coordinates Entry
                    Text(
                      'Enter Coordinates',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _latController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Latitude',
                              hintText: 'e.g., 37.7749',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final lat = double.tryParse(value);
                              if (lat == null) {
                                return 'Invalid';
                              }
                              if (lat < -90 || lat > 90) {
                                return 'Must be between -90 and 90';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _lngController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Longitude',
                              hintText: 'e.g., -122.4194',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.primary, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final lng = double.tryParse(value);
                              if (lng == null) {
                                return 'Invalid';
                              }
                              if (lng < -180 || lng > 180) {
                                return 'Must be between -180 and 180';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectManualCoordinates,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Use These Coordinates'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Predefined Locations
                    Text(
                      'Or Choose a Predefined Location',
                      style:
                          AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),

                    ..._predefinedLocations.map(
                      (location) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          child: ListTile(
                            leading: const Icon(
                              Icons.location_city,
                              color: AppColors.primary,
                            ),
                            title: Text(
                              location.name,
                              style: AppTextStyles.bodyMedium,
                            ),
                            subtitle: Text(
                              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}',
                              style: AppTextStyles.caption,
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            onTap: () {
                              widget.onLocationSelected(
                                  location.latitude, location.longitude);
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info Box
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 26),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.info.withValues(alpha: 77)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Location Tips',
                                style: AppTextStyles.label
                                    .copyWith(color: AppColors.info),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• You can find coordinates using Google Maps\n'
                            '• Right-click on any location and select "What\'s here?"\n'
                            '• Coordinates appear at the bottom of the screen\n'
                            '• For testing, you can use the predefined locations above',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.info),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectManualCoordinates() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final lat = double.parse(_latController.text);
    final lng = double.parse(_lngController.text);

    widget.onLocationSelected(lat, lng);
  }
}

class _PredefinedLocation {
  const _PredefinedLocation(this.name, this.latitude, this.longitude);

  final String name;
  final double latitude;
  final double longitude;
}
