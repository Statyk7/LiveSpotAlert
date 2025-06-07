import 'package:flutter/material.dart';
import '../../../../shared/ui_kit/colors.dart';
import '../../../../shared/ui_kit/text_styles.dart';
import '../../../../shared/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          AppConstants.appName,
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to LiveSpotAlert',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'Create location-based alerts with Live Activities',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _FeatureCard(
                    icon: Icons.location_on,
                    title: 'Geofences',
                    subtitle: 'Manage locations',
                    color: AppColors.geofenceActive,
                    onTap: () {
                      // TODO: Navigate to geofencing screen
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Live Activities',
                    subtitle: 'View active alerts',
                    color: AppColors.primary,
                    onTap: () {
                      // TODO: Navigate to live activities screen
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.image,
                    title: 'Media',
                    subtitle: 'Manage images & QR codes',
                    color: AppColors.secondary,
                    onTap: () {
                      // TODO: Navigate to media management screen
                    },
                  ),
                  _FeatureCard(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    color: AppColors.textSecondary,
                    onTap: () {
                      // TODO: Navigate to settings screen
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: AppTextStyles.h4,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}