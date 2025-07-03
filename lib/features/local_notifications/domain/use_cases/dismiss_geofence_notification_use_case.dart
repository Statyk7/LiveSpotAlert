import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/local_notifications_service.dart';

/// Parameters for dismissing a geofence notification
class DismissGeofenceNotificationParams extends Equatable {
  const DismissGeofenceNotificationParams({
    required this.geofenceId,
  });

  final String geofenceId;

  @override
  List<Object?> get props => [geofenceId];
}

/// Use case for dismissing a geofence notification
class DismissGeofenceNotificationUseCase implements UseCase<void, DismissGeofenceNotificationParams> {
  DismissGeofenceNotificationUseCase(this.notificationsService);

  final LocalNotificationsService notificationsService;

  @override
  Future<Either<Failure, void>> call(DismissGeofenceNotificationParams params) async {
    return await notificationsService.dismissGeofenceNotification(params.geofenceId);
  }
}