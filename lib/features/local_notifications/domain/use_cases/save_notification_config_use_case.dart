import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/notification_config.dart';
import '../services/local_notifications_service.dart';

/// Parameters for saving notification configuration
class SaveNotificationConfigParams extends Equatable {
  const SaveNotificationConfigParams({
    required this.config,
  });

  final NotificationConfig config;

  @override
  List<Object?> get props => [config];
}

/// Use case for saving notification configuration to local storage
class SaveNotificationConfigUseCase implements UseCase<void, SaveNotificationConfigParams> {
  SaveNotificationConfigUseCase(this.notificationsService);

  final LocalNotificationsService notificationsService;

  @override
  Future<Either<Failure, void>> call(SaveNotificationConfigParams params) async {
    return await notificationsService.saveNotificationConfig(params.config);
  }
}