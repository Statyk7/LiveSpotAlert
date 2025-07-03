import 'package:dartz/dartz.dart';
import '../../../../shared/base_domain/failures/failure.dart';
import '../../../../shared/base_domain/use_case.dart';
import '../services/local_notifications_service.dart';

/// Use case for requesting notification permissions
class RequestNotificationPermissionsUseCase implements UseCase<bool, NoParams> {
  RequestNotificationPermissionsUseCase(this.notificationsService);

  final LocalNotificationsService notificationsService;

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await notificationsService.requestNotificationPermissions();
  }
}