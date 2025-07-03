import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../models/notification_config.dart';
import '../services/local_notifications_service.dart';

/// Use case for loading notification configuration from local storage
class LoadNotificationConfigUseCase
    implements UseCase<NotificationConfig, NoParams> {
  LoadNotificationConfigUseCase(this.notificationsService);

  final LocalNotificationsService notificationsService;

  @override
  Future<Either<Failure, NotificationConfig>> call(NoParams params) async {
    return await notificationsService.getNotificationConfig();
  }
}
