import 'package:posthog_flutter/posthog_flutter.dart';


/// Service for recording user behaviors to be used for product usage analytics.
abstract class AnalyticsService {
  Future<void> identify({
    required String userId,
    Map<String, Object>? userProperties,
  });

  Future<void> screen({
    required String screenName,
    Map<String, Object>? properties,
  });

  Future<void> event({
    required String eventName,
    Map<String, Object>? properties,
  });
}

/// Implementation of the AnalyticsService with Posthog.
class AnalyticsServicePosthog implements AnalyticsService {
  @override
  Future<void> screen({required String screenName, Map<String, Object>? properties}) async {
    return await Posthog().screen(
      screenName: screenName,
      properties: properties
    );
  }

  @override
  Future<void> event({required String eventName, Map<String, Object>? properties}) async {
    return await Posthog().capture(
        eventName: eventName,
        properties: properties
    );
  }

  @override
  Future<void> identify({required String userId, Map<String, Object>? userProperties}) async {
    return await Posthog().identify(
        userId: userId,
        userProperties: userProperties
    );
  }

}
