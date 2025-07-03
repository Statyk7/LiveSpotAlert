import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class LocationFailure extends Failure {
  const LocationFailure({required super.message});
}

class PermissionFailure extends Failure {
  const PermissionFailure({required super.message});
}

class MediaFailure extends Failure {
  const MediaFailure({required super.message});
}

class LiveActivityFailure extends Failure {
  const LiveActivityFailure({required super.message});
}

class NotificationFailure extends Failure {
  const NotificationFailure({required super.message});
}