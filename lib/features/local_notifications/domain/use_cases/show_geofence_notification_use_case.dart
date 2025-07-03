import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/local_notifications_service.dart';

/// Parameters for showing a geofence notification
class ShowGeofenceNotificationParams extends Equatable {
  const ShowGeofenceNotificationParams({
    required this.geofenceId,
    required this.geofenceName,
    required this.customTitle,
    this.isEntry = true,
  });

  final String geofenceId;
  final String geofenceName;
  final String customTitle;
  final bool isEntry;

  @override
  List<Object?> get props => [geofenceId, geofenceName, customTitle, isEntry];
}

/// Use case for showing a geofence-triggered notification
class ShowGeofenceNotificationUseCase
    implements UseCase<void, ShowGeofenceNotificationParams> {
  ShowGeofenceNotificationUseCase(this.notificationsService);

  final LocalNotificationsService notificationsService;

  @override
  Future<Either<Failure, void>> call(
      ShowGeofenceNotificationParams params) async {
    return await notificationsService.showGeofenceNotification(
      geofenceId: params.geofenceId,
      geofenceName: params.geofenceName,
      customTitle: params.customTitle,
      isEntry: params.isEntry,
    );
  }
}
