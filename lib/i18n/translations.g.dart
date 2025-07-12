/// Generated file. Do not edit.
///
/// Original: lib/i18n
/// To regenerate, run: `dart run slang`
///
/// Locales: 3
/// Strings: 455 (151 per locale)
///
/// Built on 2025-07-12 at 00:16 UTC

// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:flutter/widgets.dart';
import 'package:slang/builder/model/node.dart';
import 'package:slang_flutter/slang_flutter.dart';
export 'package:slang_flutter/slang_flutter.dart';

const AppLocale _baseLocale = AppLocale.en;

/// Supported locales, see extension methods below.
///
/// Usage:
/// - LocaleSettings.setLocale(AppLocale.en) // set locale
/// - Locale locale = AppLocale.en.flutterLocale // get flutter locale from enum
/// - if (LocaleSettings.currentLocale == AppLocale.en) // locale check
enum AppLocale with BaseAppLocale<AppLocale, Translations> {
	en(languageCode: 'en', build: Translations.build),
	es(languageCode: 'es', build: _TranslationsEs.build),
	fr(languageCode: 'fr', build: _TranslationsFr.build);

	const AppLocale({required this.languageCode, this.scriptCode, this.countryCode, required this.build}); // ignore: unused_element

	@override final String languageCode;
	@override final String? scriptCode;
	@override final String? countryCode;
	@override final TranslationBuilder<AppLocale, Translations> build;

	/// Gets current instance managed by [LocaleSettings].
	Translations get translations => LocaleSettings.instance.translationMap[this]!;
}

/// Method A: Simple
///
/// No rebuild after locale change.
/// Translation happens during initialization of the widget (call of t).
/// Configurable via 'translate_var'.
///
/// Usage:
/// String a = t.someKey.anotherKey;
/// String b = t['someKey.anotherKey']; // Only for edge cases!
Translations get t => LocaleSettings.instance.currentTranslations;

/// Method B: Advanced
///
/// All widgets using this method will trigger a rebuild when locale changes.
/// Use this if you have e.g. a settings page where the user can select the locale during runtime.
///
/// Step 1:
/// wrap your App with
/// TranslationProvider(
/// 	child: MyApp()
/// );
///
/// Step 2:
/// final t = Translations.of(context); // Get t variable.
/// String a = t.someKey.anotherKey; // Use t variable.
/// String b = t['someKey.anotherKey']; // Only for edge cases!
class TranslationProvider extends BaseTranslationProvider<AppLocale, Translations> {
	TranslationProvider({required super.child}) : super(settings: LocaleSettings.instance);

	static InheritedLocaleData<AppLocale, Translations> of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context);
}

/// Method B shorthand via [BuildContext] extension method.
/// Configurable via 'translate_var'.
///
/// Usage (e.g. in a widget's build method):
/// context.t.someKey.anotherKey
extension BuildContextTranslationsExtension on BuildContext {
	Translations get t => TranslationProvider.of(this).translations;
}

/// Manages all translation instances and the current locale
class LocaleSettings extends BaseFlutterLocaleSettings<AppLocale, Translations> {
	LocaleSettings._() : super(utils: AppLocaleUtils.instance);

	static final instance = LocaleSettings._();

	// static aliases (checkout base methods for documentation)
	static AppLocale get currentLocale => instance.currentLocale;
	static Stream<AppLocale> getLocaleStream() => instance.getLocaleStream();
	static AppLocale setLocale(AppLocale locale, {bool? listenToDeviceLocale = false}) => instance.setLocale(locale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale setLocaleRaw(String rawLocale, {bool? listenToDeviceLocale = false}) => instance.setLocaleRaw(rawLocale, listenToDeviceLocale: listenToDeviceLocale);
	static AppLocale useDeviceLocale() => instance.useDeviceLocale();
	@Deprecated('Use [AppLocaleUtils.supportedLocales]') static List<Locale> get supportedLocales => instance.supportedLocales;
	@Deprecated('Use [AppLocaleUtils.supportedLocalesRaw]') static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
	static void setPluralResolver({String? language, AppLocale? locale, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver}) => instance.setPluralResolver(
		language: language,
		locale: locale,
		cardinalResolver: cardinalResolver,
		ordinalResolver: ordinalResolver,
	);
}

/// Provides utility functions without any side effects.
class AppLocaleUtils extends BaseAppLocaleUtils<AppLocale, Translations> {
	AppLocaleUtils._() : super(baseLocale: _baseLocale, locales: AppLocale.values);

	static final instance = AppLocaleUtils._();

	// static aliases (checkout base methods for documentation)
	static AppLocale parse(String rawLocale) => instance.parse(rawLocale);
	static AppLocale parseLocaleParts({required String languageCode, String? scriptCode, String? countryCode}) => instance.parseLocaleParts(languageCode: languageCode, scriptCode: scriptCode, countryCode: countryCode);
	static AppLocale findDeviceLocale() => instance.findDeviceLocale();
	static List<Locale> get supportedLocales => instance.supportedLocales;
	static List<String> get supportedLocalesRaw => instance.supportedLocalesRaw;
}

// translations

// Path: <root>
class Translations implements BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	// Translations
	late final _TranslationsAppEn app = _TranslationsAppEn._(_root);
	late final _TranslationsCommonEn common = _TranslationsCommonEn._(_root);
	late final _TranslationsDefaultsEn defaults = _TranslationsDefaultsEn._(_root);
	late final _TranslationsValidationEn validation = _TranslationsValidationEn._(_root);
	late final _TranslationsErrorsEn errors = _TranslationsErrorsEn._(_root);
	late final _TranslationsGeofenceEventsEn geofenceEvents = _TranslationsGeofenceEventsEn._(_root);
	late final _TranslationsNotificationsEn notifications = _TranslationsNotificationsEn._(_root);
	late final _TranslationsMonitoringEn monitoring = _TranslationsMonitoringEn._(_root);
	late final _TranslationsGeofencingEn geofencing = _TranslationsGeofencingEn._(_root);
	late final _TranslationsDonationsEn donations = _TranslationsDonationsEn._(_root);
	late final _TranslationsLiveActivitiesEn liveActivities = _TranslationsLiveActivitiesEn._(_root);
}

// Path: app
class _TranslationsAppEn {
	_TranslationsAppEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'LiveSpotAlert';
	String get tagline => 'Location-based Live Notification';
}

// Path: common
class _TranslationsCommonEn {
	_TranslationsCommonEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get save => 'Save';
	String get cancel => 'Cancel';
	String get grant => 'Grant';
	String get loading => 'Loading...';
	String get retry => 'Retry';
	String get error => 'Error occurred';
	String get dismiss => 'Dismiss';
	String get selected => 'Selected';
	String get active => 'Active';
	String get inactive => 'Inactive';
	String get yes => 'Yes';
	String get no => 'No';
	String get stay => 'Stay';
	String get remove => 'Remove';
	late final _TranslationsCommonTimeEn time = _TranslationsCommonTimeEn._(_root);
	late final _TranslationsCommonErrorsEn errors = _TranslationsCommonErrorsEn._(_root);
}

// Path: defaults
class _TranslationsDefaultsEn {
	_TranslationsDefaultsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsDefaultsGeofenceEn geofence = _TranslationsDefaultsGeofenceEn._(_root);
	late final _TranslationsDefaultsNotificationEn notification = _TranslationsDefaultsNotificationEn._(_root);
	late final _TranslationsDefaultsLocationEn location = _TranslationsDefaultsLocationEn._(_root);
}

// Path: validation
class _TranslationsValidationEn {
	_TranslationsValidationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsValidationGeofenceEn geofence = _TranslationsValidationGeofenceEn._(_root);
}

// Path: errors
class _TranslationsErrorsEn {
	_TranslationsErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsErrorsLiveActivityEn liveActivity = _TranslationsErrorsLiveActivityEn._(_root);
	late final _TranslationsErrorsDonationsEn donations = _TranslationsErrorsDonationsEn._(_root);
	late final _TranslationsErrorsGeofencingEn geofencing = _TranslationsErrorsGeofencingEn._(_root);
	late final _TranslationsErrorsNotificationsEn notifications = _TranslationsErrorsNotificationsEn._(_root);
}

// Path: geofenceEvents
class _TranslationsGeofenceEventsEn {
	_TranslationsGeofenceEventsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsGeofenceEventsEntryEn entry = _TranslationsGeofenceEventsEntryEn._(_root);
	late final _TranslationsGeofenceEventsExitEn exit = _TranslationsGeofenceEventsExitEn._(_root);
}

// Path: notifications
class _TranslationsNotificationsEn {
	_TranslationsNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notification';
	String get localTitle => 'Local Notifications';
	late final _TranslationsNotificationsConfigEn config = _TranslationsNotificationsConfigEn._(_root);
	late final _TranslationsNotificationsStatusEn status = _TranslationsNotificationsStatusEn._(_root);
	late final _TranslationsNotificationsPermissionsEn permissions = _TranslationsNotificationsPermissionsEn._(_root);
	late final _TranslationsNotificationsPreviewEn preview = _TranslationsNotificationsPreviewEn._(_root);
	late final _TranslationsNotificationsDisplayEn display = _TranslationsNotificationsDisplayEn._(_root);
	late final _TranslationsNotificationsDialogsEn dialogs = _TranslationsNotificationsDialogsEn._(_root);
}

// Path: monitoring
class _TranslationsMonitoringEn {
	_TranslationsMonitoringEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Location Monitoring';
	late final _TranslationsMonitoringStatusEn status = _TranslationsMonitoringStatusEn._(_root);
	late final _TranslationsMonitoringPermissionsEn permissions = _TranslationsMonitoringPermissionsEn._(_root);
	String lastEvent({required Object event}) => 'Last event: ${event}';
	late final _TranslationsMonitoringEventsEn events = _TranslationsMonitoringEventsEn._(_root);
}

// Path: geofencing
class _TranslationsGeofencingEn {
	_TranslationsGeofencingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Geofence Location';
	late final _TranslationsGeofencingConfigEn config = _TranslationsGeofencingConfigEn._(_root);
	late final _TranslationsGeofencingMapEn map = _TranslationsGeofencingMapEn._(_root);
	late final _TranslationsGeofencingStatusEn status = _TranslationsGeofencingStatusEn._(_root);
	late final _TranslationsGeofencingCardEn card = _TranslationsGeofencingCardEn._(_root);
	late final _TranslationsGeofencingEventsEn events = _TranslationsGeofencingEventsEn._(_root);
	late final _TranslationsGeofencingDescriptionEn description = _TranslationsGeofencingDescriptionEn._(_root);
}

// Path: donations
class _TranslationsDonationsEn {
	_TranslationsDonationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Tip Jar';
	String get button => 'Support Development';
	String get header => 'If you are enjoying LiveSpotAlert and would like to support the app\'s future development, adding a tip would be greatly helpful.';
	String get processing => 'Processing your donation...';
	String get success => 'Thank you for your generous donation!';
	String get error => 'Unable to load donation options';
	late final _TranslationsDonationsProductsEn products = _TranslationsDonationsProductsEn._(_root);
	late final _TranslationsDonationsThankYouEn thankYou = _TranslationsDonationsThankYouEn._(_root);
}

// Path: liveActivities
class _TranslationsLiveActivitiesEn {
	_TranslationsLiveActivitiesEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final _TranslationsLiveActivitiesConfigEn config = _TranslationsLiveActivitiesConfigEn._(_root);
}

// Path: common.time
class _TranslationsCommonTimeEn {
	_TranslationsCommonTimeEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get justNow => 'just now';
	String minutesAgo({required Object minutes}) => '${minutes}m ago';
	String hoursAgo({required Object hours}) => '${hours}h ago';
	String daysAgo({required Object days}) => '${days}d ago';
}

// Path: common.errors
class _TranslationsCommonErrorsEn {
	_TranslationsCommonErrorsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Please enter a name';
	String get imageNotFound => 'Image not found';
	String get noImageConfigured => 'No image configured';
	String get unknownLocation => 'Unknown Location';
}

// Path: defaults.geofence
class _TranslationsDefaultsGeofenceEn {
	_TranslationsDefaultsGeofenceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get name => 'My Location';
	String get description => 'Configure this geofence by tapping the edit button';
}

// Path: defaults.notification
class _TranslationsDefaultsNotificationEn {
	_TranslationsDefaultsNotificationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Location Alert';
}

// Path: defaults.location
class _TranslationsDefaultsLocationEn {
	_TranslationsDefaultsLocationEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get unknown => 'Unknown Location';
	String get update => 'Location Update';
}

// Path: validation.geofence
class _TranslationsValidationGeofenceEn {
	_TranslationsValidationGeofenceEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get idEmpty => 'Geofence ID cannot be empty';
	String get nameEmpty => 'Geofence name cannot be empty';
	String get nameLength => 'Geofence name cannot exceed 100 characters';
	String get invalidLatitude => 'Invalid latitude. Must be between -90 and 90';
	String get invalidLongitude => 'Invalid longitude. Must be between -180 and 180';
	String get radiusPositive => 'Radius must be greater than 0';
	String get radiusMax => 'Radius cannot exceed 10,000 meters';
	String get radiusMin => 'Radius must be at least 10 meters for reliable detection';
	String get descriptionLength => 'Description cannot exceed 500 characters';
}

// Path: errors.liveActivity
class _TranslationsErrorsLiveActivityEn {
	_TranslationsErrorsLiveActivityEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get notEnabled => 'Live Activities are not enabled on this device';
	String get createFailed => 'Failed to create Live Activity';
	String get startFailed => 'Error starting Live Activity: {error}';
	String get stopFailed => 'Error stopping Live Activity: {error}';
	String get updateFailed => 'Error updating Live Activity: {error}';
	String get imageFailed => 'Failed to process image: {error}';
}

// Path: errors.donations
class _TranslationsErrorsDonationsEn {
	_TranslationsErrorsDonationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get notAvailable => 'In-app purchases are not available';
	String get productNotFound => 'Product not found: {productId}';
	String get purchaseFailed => 'Failed to initiate purchase';
	String get purchaseTimeout => 'Purchase timeout';
	String get purchaseError => 'Purchase failed: {error}';
	String get historyFailed => 'Failed to get purchase history: {error}';
	String get historyCheckFailed => 'Failed to check purchase history: {error}';
}

// Path: errors.geofencing
class _TranslationsErrorsGeofencingEn {
	_TranslationsErrorsGeofencingEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get permissionsFailed => 'Failed to request permissions: {error}';
	String get permissionsCheckFailed => 'Failed to check permissions: {error}';
	String get locationEventError => 'Location event stream error: {error}';
	String get geofenceStatusError => 'Geofence status stream error: {error}';
	String get entryNotificationFailed => 'Failed to handle geofence entry notification: {error}';
	String get exitNotificationFailed => 'Failed to handle geofence exit notification: {error}';
	String get dwellNotificationFailed => 'Failed to handle geofence dwell notification: {error}';
}

// Path: errors.notifications
class _TranslationsErrorsNotificationsEn {
	_TranslationsErrorsNotificationsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get initFailed => 'Failed to initialize notifications service: {error}';
	String get loadConfigFailed => 'Failed to load notification configuration: {error}';
	String get saveConfigFailed => 'Failed to save notification configuration: {error}';
	String get notAvailable => 'Notifications not available';
	String get showFailed => 'Failed to show geofence notification: {error}';
	String get dismissFailed => 'Failed to dismiss geofence notification: {error}';
	String get dismissAllFailed => 'Failed to dismiss all notifications: {error}';
	String get availabilityCheckFailed => 'Failed to check notifications availability: {error}';
	String get permissionsFailed => 'Failed to request notification permissions: {error}';
}

// Path: geofenceEvents.entry
class _TranslationsGeofenceEventsEntryEn {
	_TranslationsGeofenceEventsEntryEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get displayName => 'Entered';
	String get actionDescription => 'You have arrived at';
}

// Path: geofenceEvents.exit
class _TranslationsGeofenceEventsExitEn {
	_TranslationsGeofenceEventsExitEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get displayName => 'Exited';
	String get actionDescription => 'You have left';
}

// Path: notifications.config
class _TranslationsNotificationsConfigEn {
	_TranslationsNotificationsConfigEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Notification Settings';
	String get configure => 'Configure Notification';
	String get saving => 'Saving...';
	String get content => 'Notification Content';
	String get titleLabel => 'Title';
	String get titleHint => 'e.g., Arrived at location, Location alert';
	String get defaultTitle => 'Location Alert';
	String get locationSuffix => '@ Location';
	String get preview => 'Preview:';
	String get image => 'Image';
	String get changeImage => 'Change Image';
	String get noImageSelected => 'No image selected';
	String get selectFromGallery => 'Select from Gallery';
	String get selecting => 'Selecting...';
	String get imageInfo => 'Images will be displayed in notifications. Supported formats: JPG, PNG. Max size: 5MB.';
	String get permissions => 'Permissions';
	String get testNotification => 'Test Notification';
}

// Path: notifications.status
class _TranslationsNotificationsStatusEn {
	_TranslationsNotificationsStatusEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loading => 'Loading...';
	String get error => 'Error occurred';
	String get disabled => 'Notifications disabled';
	String get permissionsRequired => 'Permissions required';
	String get enabled => 'Notifications enabled';
	String titleFormat({required Object title}) => 'Title: "${title}"';
	String get customImage => 'Custom image: ';
	String get imageNotSelected => 'Image: Not selected';
}

// Path: notifications.permissions
class _TranslationsNotificationsPermissionsEn {
	_TranslationsNotificationsPermissionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Notification permissions required';
	String get granted => 'Notification permissions granted';
}

// Path: notifications.preview
class _TranslationsNotificationsPreviewEn {
	_TranslationsNotificationsPreviewEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Preview Live Spot Alert';
	String get description => 'Test how your notification will look when triggered by a geofence event.';
	String get entryButton => 'Preview Entry Alert';
	String get exitButton => 'Preview Exit Alert';
	String info({required Object name}) => 'Preview will use "${name}" geofence and your current notification settings.';
	String get noGeofence => 'No geofence configured';
	String get noGeofenceMessage => 'Configure a geofence first to preview notifications.';
}

// Path: notifications.display
class _TranslationsNotificationsDisplayEn {
	_TranslationsNotificationsDisplayEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get placeholderTitle => 'No image configured';
	String get placeholderMessage => 'Configure an image in notification settings';
}

// Path: notifications.dialogs
class _TranslationsNotificationsDialogsEn {
	_TranslationsNotificationsDialogsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get unsavedChanges => 'Unsaved Changes';
	String get unsavedMessage => 'You have unsaved changes. Are you sure you want to cancel?';
}

// Path: monitoring.status
class _TranslationsMonitoringStatusEn {
	_TranslationsMonitoringStatusEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get active => 'Actively monitoring your location';
	String get disabled => 'Monitoring is disabled';
}

// Path: monitoring.permissions
class _TranslationsMonitoringPermissionsEn {
	_TranslationsMonitoringPermissionsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get required => 'Location permissions required';
}

// Path: monitoring.events
class _TranslationsMonitoringEventsEn {
	_TranslationsMonitoringEventsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String entered({required Object name}) => 'Entered ${name}';
	String exited({required Object name}) => 'Exited ${name}';
	String get locationUpdate => 'Location update';
}

// Path: geofencing.config
class _TranslationsGeofencingConfigEn {
	_TranslationsGeofencingConfigEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Geofence Location';
	String get createTitle => 'Create Geofence';
	String get editTitle => 'Edit Geofence';
	String get configure => 'Configure Geofence';
	String get nameLabel => 'Geofence Name';
	String get nameHint => 'e.g., Home, Office, Gym';
	String get locationLabel => 'Location';
	String radiusLabel({required Object radius}) => 'Radius: ${radius}m';
	String get minRadius => '10m';
	String get maxRadius => '1km';
	String get defaultName => 'My Location';
	String get noConfigured => 'No geofence configured';
}

// Path: geofencing.map
class _TranslationsGeofencingMapEn {
	_TranslationsGeofencingMapEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get instructions => 'Tap map or drag marker to set location';
	String get centerOnLocation => 'Center on my location';
	String get centerOnGeofence => 'Center on geofence';
	String locationInfo({required Object lat, required Object lng}) => 'Location: ${lat}, ${lng}';
}

// Path: geofencing.status
class _TranslationsGeofencingStatusEn {
	_TranslationsGeofencingStatusEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get loading => 'Loading...';
	String get error => 'Error occurred';
	String get inactive => 'Geofence inactive';
	String get inside => 'Inside geofence area';
	String get outside => 'Outside geofence area';
	String get youAreInside => 'You are inside this area';
	String get youAreOutside => 'You are outside this area';
	String distance({required Object distance}) => 'Distance: ${distance}m';
	String get hasMedia => 'Has attached media';
}

// Path: geofencing.card
class _TranslationsGeofencingCardEn {
	_TranslationsGeofencingCardEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String radiusInfo({required Object radius}) => '${radius}m radius';
	String distanceInfo({required Object distance}) => '${distance}m away';
	String get recentActivity => 'Recent Activity';
}

// Path: geofencing.events
class _TranslationsGeofencingEventsEn {
	_TranslationsGeofencingEventsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get entered => 'Entered';
	String get exited => 'Exited';
	String get dwelling => 'Dwelling';
}

// Path: geofencing.description
class _TranslationsGeofencingDescriptionEn {
	_TranslationsGeofencingDescriptionEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get active => 'Geofence will trigger notifications';
	String get inactive => 'Geofence is configured but inactive';
}

// Path: donations.products
class _TranslationsDonationsProductsEn {
	_TranslationsDonationsProductsEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get smallTip => 'Small Tip';
	String get mediumTip => 'Medium Tip';
	String get largeTip => 'Large Tip';
	String get giantTip => 'Giant Tip';
}

// Path: donations.thankYou
class _TranslationsDonationsThankYouEn {
	_TranslationsDonationsThankYouEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Thank You!';
	String get message => 'Your support helps keep this app free and continuously improving. We truly appreciate your generosity!';
}

// Path: liveActivities.config
class _TranslationsLiveActivitiesConfigEn {
	_TranslationsLiveActivitiesConfigEn._(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	String get title => 'Configure Live Activity';
	String get notificationTitle => 'Notification Title';
	String get titleHint => 'e.g., You\'ve arrived!';
	String get notificationImage => 'Notification Image';
	String get addImagePrompt => 'Tap to add image';
	String get imageUnavailable => 'Image unavailable';
}

// Path: <root>
class _TranslationsEs extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsEs.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.es,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <es>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsEs _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppEs app = _TranslationsAppEs._(_root);
	@override late final _TranslationsCommonEs common = _TranslationsCommonEs._(_root);
	@override late final _TranslationsMonitoringEs monitoring = _TranslationsMonitoringEs._(_root);
	@override late final _TranslationsGeofencingEs geofencing = _TranslationsGeofencingEs._(_root);
	@override late final _TranslationsNotificationsEs notifications = _TranslationsNotificationsEs._(_root);
	@override late final _TranslationsDonationsEs donations = _TranslationsDonationsEs._(_root);
	@override late final _TranslationsDefaultsEs defaults = _TranslationsDefaultsEs._(_root);
	@override late final _TranslationsValidationEs validation = _TranslationsValidationEs._(_root);
	@override late final _TranslationsGeofenceEventsEs geofenceEvents = _TranslationsGeofenceEventsEs._(_root);
	@override late final _TranslationsLiveActivitiesEs liveActivities = _TranslationsLiveActivitiesEs._(_root);
}

// Path: app
class _TranslationsAppEs extends _TranslationsAppEn {
	_TranslationsAppEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'LiveSpotAlert';
	@override String get tagline => 'Notificación en vivo basada en ubicación';
}

// Path: common
class _TranslationsCommonEs extends _TranslationsCommonEn {
	_TranslationsCommonEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get save => 'Guardar';
	@override String get cancel => 'Cancelar';
	@override String get grant => 'Conceder';
	@override String get loading => 'Cargando...';
	@override String get retry => 'Reintentar';
	@override String get error => 'Ocurrió un error';
	@override String get dismiss => 'Descartar';
	@override String get selected => 'Seleccionado';
	@override String get active => 'Activo';
	@override String get inactive => 'Inactivo';
	@override String get yes => 'Sí';
	@override String get no => 'No';
	@override String get stay => 'Quedarse';
	@override String get remove => 'Eliminar';
	@override late final _TranslationsCommonTimeEs time = _TranslationsCommonTimeEs._(_root);
	@override late final _TranslationsCommonErrorsEs errors = _TranslationsCommonErrorsEs._(_root);
}

// Path: monitoring
class _TranslationsMonitoringEs extends _TranslationsMonitoringEn {
	_TranslationsMonitoringEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Monitoreo de Ubicación';
	@override late final _TranslationsMonitoringStatusEs status = _TranslationsMonitoringStatusEs._(_root);
	@override late final _TranslationsMonitoringPermissionsEs permissions = _TranslationsMonitoringPermissionsEs._(_root);
	@override String lastEvent({required Object event}) => 'Último evento: ${event}';
	@override late final _TranslationsMonitoringEventsEs events = _TranslationsMonitoringEventsEs._(_root);
}

// Path: geofencing
class _TranslationsGeofencingEs extends _TranslationsGeofencingEn {
	_TranslationsGeofencingEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ubicación de Geocerca';
	@override late final _TranslationsGeofencingConfigEs config = _TranslationsGeofencingConfigEs._(_root);
	@override late final _TranslationsGeofencingMapEs map = _TranslationsGeofencingMapEs._(_root);
	@override late final _TranslationsGeofencingStatusEs status = _TranslationsGeofencingStatusEs._(_root);
	@override late final _TranslationsGeofencingCardEs card = _TranslationsGeofencingCardEs._(_root);
	@override late final _TranslationsGeofencingEventsEs events = _TranslationsGeofencingEventsEs._(_root);
	@override late final _TranslationsGeofencingDescriptionEs description = _TranslationsGeofencingDescriptionEs._(_root);
}

// Path: notifications
class _TranslationsNotificationsEs extends _TranslationsNotificationsEn {
	_TranslationsNotificationsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notificación';
	@override String get localTitle => 'Notificaciones Locales';
	@override late final _TranslationsNotificationsConfigEs config = _TranslationsNotificationsConfigEs._(_root);
	@override late final _TranslationsNotificationsStatusEs status = _TranslationsNotificationsStatusEs._(_root);
	@override late final _TranslationsNotificationsPermissionsEs permissions = _TranslationsNotificationsPermissionsEs._(_root);
	@override late final _TranslationsNotificationsPreviewEs preview = _TranslationsNotificationsPreviewEs._(_root);
	@override late final _TranslationsNotificationsDisplayEs display = _TranslationsNotificationsDisplayEs._(_root);
	@override late final _TranslationsNotificationsDialogsEs dialogs = _TranslationsNotificationsDialogsEs._(_root);
}

// Path: donations
class _TranslationsDonationsEs extends _TranslationsDonationsEn {
	_TranslationsDonationsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bote de Propinas';
	@override String get button => 'Apoyar el Desarrollo';
	@override String get header => 'Si está disfrutando LiveSpotAlert y le gustaría apoyar el desarrollo futuro de la aplicación, agregar una propina sería de gran ayuda.';
	@override String get processing => 'Procesando su donación...';
	@override String get success => '¡Gracias por su generosa donación!';
	@override String get error => 'No se pudieron cargar las opciones de donación';
	@override late final _TranslationsDonationsProductsEs products = _TranslationsDonationsProductsEs._(_root);
	@override late final _TranslationsDonationsThankYouEs thankYou = _TranslationsDonationsThankYouEs._(_root);
}

// Path: defaults
class _TranslationsDefaultsEs extends _TranslationsDefaultsEn {
	_TranslationsDefaultsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDefaultsGeofenceEs geofence = _TranslationsDefaultsGeofenceEs._(_root);
	@override late final _TranslationsDefaultsNotificationEs notification = _TranslationsDefaultsNotificationEs._(_root);
	@override late final _TranslationsDefaultsLocationEs location = _TranslationsDefaultsLocationEs._(_root);
}

// Path: validation
class _TranslationsValidationEs extends _TranslationsValidationEn {
	_TranslationsValidationEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsValidationGeofenceEs geofence = _TranslationsValidationGeofenceEs._(_root);
}

// Path: geofenceEvents
class _TranslationsGeofenceEventsEs extends _TranslationsGeofenceEventsEn {
	_TranslationsGeofenceEventsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsGeofenceEventsEntryEs entry = _TranslationsGeofenceEventsEntryEs._(_root);
	@override late final _TranslationsGeofenceEventsExitEs exit = _TranslationsGeofenceEventsExitEs._(_root);
}

// Path: liveActivities
class _TranslationsLiveActivitiesEs extends _TranslationsLiveActivitiesEn {
	_TranslationsLiveActivitiesEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLiveActivitiesConfigEs config = _TranslationsLiveActivitiesConfigEs._(_root);
}

// Path: common.time
class _TranslationsCommonTimeEs extends _TranslationsCommonTimeEn {
	_TranslationsCommonTimeEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get justNow => 'ahora mismo';
	@override String minutesAgo({required Object minutes}) => 'hace ${minutes} min';
	@override String hoursAgo({required Object hours}) => 'hace ${hours} h';
	@override String daysAgo({required Object days}) => 'hace ${days} días';
}

// Path: common.errors
class _TranslationsCommonErrorsEs extends _TranslationsCommonErrorsEn {
	_TranslationsCommonErrorsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get required => 'Por favor ingrese un nombre';
	@override String get imageNotFound => 'Imagen no encontrada';
	@override String get noImageConfigured => 'No hay imagen configurada';
	@override String get unknownLocation => 'Ubicación desconocida';
}

// Path: monitoring.status
class _TranslationsMonitoringStatusEs extends _TranslationsMonitoringStatusEn {
	_TranslationsMonitoringStatusEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get active => 'Monitoreando activamente su ubicación';
	@override String get disabled => 'El monitoreo está deshabilitado';
}

// Path: monitoring.permissions
class _TranslationsMonitoringPermissionsEs extends _TranslationsMonitoringPermissionsEn {
	_TranslationsMonitoringPermissionsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get required => 'Se requieren permisos de ubicación';
}

// Path: monitoring.events
class _TranslationsMonitoringEventsEs extends _TranslationsMonitoringEventsEn {
	_TranslationsMonitoringEventsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String entered({required Object name}) => 'Entró a ${name}';
	@override String exited({required Object name}) => 'Salió de ${name}';
	@override String get locationUpdate => 'Actualización de ubicación';
}

// Path: geofencing.config
class _TranslationsGeofencingConfigEs extends _TranslationsGeofencingConfigEn {
	_TranslationsGeofencingConfigEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ubicación de Geocerca';
	@override String get createTitle => 'Crear Geocerca';
	@override String get editTitle => 'Editar Geocerca';
	@override String get configure => 'Configurar Geocerca';
	@override String get nameLabel => 'Nombre de la Geocerca';
	@override String get nameHint => 'ej. Casa, Oficina, Gimnasio';
	@override String get locationLabel => 'Ubicación';
	@override String radiusLabel({required Object radius}) => 'Radio: ${radius}m';
	@override String get minRadius => '10m';
	@override String get maxRadius => '1km';
	@override String get defaultName => 'Mi Ubicación';
	@override String get noConfigured => 'No hay geocerca configurada';
}

// Path: geofencing.map
class _TranslationsGeofencingMapEs extends _TranslationsGeofencingMapEn {
	_TranslationsGeofencingMapEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get instructions => 'Toque el mapa o arrastre el marcador para establecer la ubicación';
	@override String get centerOnLocation => 'Centrar en mi ubicación';
	@override String get centerOnGeofence => 'Centrar en la geocerca';
	@override String locationInfo({required Object lat, required Object lng}) => 'Ubicación: ${lat}, ${lng}';
}

// Path: geofencing.status
class _TranslationsGeofencingStatusEs extends _TranslationsGeofencingStatusEn {
	_TranslationsGeofencingStatusEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Cargando...';
	@override String get error => 'Ocurrió un error';
	@override String get inactive => 'Geocerca inactiva';
	@override String get inside => 'Dentro del área de geocerca';
	@override String get outside => 'Fuera del área de geocerca';
	@override String get youAreInside => 'Está dentro de esta área';
	@override String get youAreOutside => 'Está fuera de esta área';
	@override String distance({required Object distance}) => 'Distancia: ${distance}m';
	@override String get hasMedia => 'Tiene medios adjuntos';
}

// Path: geofencing.card
class _TranslationsGeofencingCardEs extends _TranslationsGeofencingCardEn {
	_TranslationsGeofencingCardEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String radiusInfo({required Object radius}) => 'Radio de ${radius}m';
	@override String distanceInfo({required Object distance}) => 'A ${distance}m de distancia';
	@override String get recentActivity => 'Actividad Reciente';
}

// Path: geofencing.events
class _TranslationsGeofencingEventsEs extends _TranslationsGeofencingEventsEn {
	_TranslationsGeofencingEventsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get entered => 'Entró';
	@override String get exited => 'Salió';
	@override String get dwelling => 'Permaneciendo';
}

// Path: geofencing.description
class _TranslationsGeofencingDescriptionEs extends _TranslationsGeofencingDescriptionEn {
	_TranslationsGeofencingDescriptionEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get active => 'La geocerca activará notificaciones';
	@override String get inactive => 'La geocerca está configurada pero inactiva';
}

// Path: notifications.config
class _TranslationsNotificationsConfigEs extends _TranslationsNotificationsConfigEn {
	_TranslationsNotificationsConfigEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configuración de Notificaciones';
	@override String get configure => 'Configurar Notificación';
	@override String get saving => 'Guardando...';
	@override String get content => 'Contenido de la Notificación';
	@override String get titleLabel => 'Título';
	@override String get titleHint => 'ej. Llegó a la ubicación, Alerta de ubicación';
	@override String get defaultTitle => 'Alerta de Ubicación';
	@override String get locationSuffix => '@ Ubicación';
	@override String get preview => 'Vista previa:';
	@override String get image => 'Imagen';
	@override String get changeImage => 'Cambiar Imagen';
	@override String get noImageSelected => 'No se ha seleccionado imagen';
	@override String get selectFromGallery => 'Seleccionar de la Galería';
	@override String get selecting => 'Seleccionando...';
	@override String get imageInfo => 'Las imágenes se mostrarán en las notificaciones. Formatos compatibles: JPG, PNG. Tamaño máximo: 5MB.';
	@override String get permissions => 'Permisos';
	@override String get testNotification => 'Probar Notificación';
}

// Path: notifications.status
class _TranslationsNotificationsStatusEs extends _TranslationsNotificationsStatusEn {
	_TranslationsNotificationsStatusEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Cargando...';
	@override String get error => 'Ocurrió un error';
	@override String get disabled => 'Notificaciones deshabilitadas';
	@override String get permissionsRequired => 'Se requieren permisos';
	@override String get enabled => 'Notificaciones habilitadas';
	@override String titleFormat({required Object title}) => 'Título: "${title}"';
	@override String get customImage => 'Imagen personalizada: ';
	@override String get imageNotSelected => 'Imagen: No seleccionada';
}

// Path: notifications.permissions
class _TranslationsNotificationsPermissionsEs extends _TranslationsNotificationsPermissionsEn {
	_TranslationsNotificationsPermissionsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get required => 'Se requieren permisos de notificación';
	@override String get granted => 'Permisos de notificación concedidos';
}

// Path: notifications.preview
class _TranslationsNotificationsPreviewEs extends _TranslationsNotificationsPreviewEn {
	_TranslationsNotificationsPreviewEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Vista Previa de Notificación';
	@override String get description => 'Pruebe cómo se verá su notificación cuando sea activada por un evento de geocerca.';
	@override String get entryButton => 'Vista Previa de Alerta de Entrada';
	@override String get exitButton => 'Vista Previa de Alerta de Salida';
	@override String info({required Object name}) => 'La vista previa usará la geocerca "${name}" y su configuración actual de notificaciones.';
	@override String get noGeofence => 'No hay geocerca configurada';
	@override String get noGeofenceMessage => 'Configure una geocerca primero para ver las notificaciones.';
}

// Path: notifications.display
class _TranslationsNotificationsDisplayEs extends _TranslationsNotificationsDisplayEn {
	_TranslationsNotificationsDisplayEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get placeholderTitle => 'No hay imagen configurada';
	@override String get placeholderMessage => 'Configure una imagen en la configuración de notificaciones';
}

// Path: notifications.dialogs
class _TranslationsNotificationsDialogsEs extends _TranslationsNotificationsDialogsEn {
	_TranslationsNotificationsDialogsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get unsavedChanges => 'Cambios No Guardados';
	@override String get unsavedMessage => 'Tiene cambios no guardados. ¿Está seguro de que quiere cancelar?';
}

// Path: donations.products
class _TranslationsDonationsProductsEs extends _TranslationsDonationsProductsEn {
	_TranslationsDonationsProductsEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get smallTip => 'Propina Pequeña';
	@override String get mediumTip => 'Propina Mediana';
	@override String get largeTip => 'Propina Grande';
	@override String get giantTip => 'Propina Gigante';
}

// Path: donations.thankYou
class _TranslationsDonationsThankYouEs extends _TranslationsDonationsThankYouEn {
	_TranslationsDonationsThankYouEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => '¡Gracias!';
	@override String get message => 'Su apoyo ayuda a mantener esta aplicación gratuita y en continua mejora. ¡Realmente apreciamos su generosidad!';
}

// Path: defaults.geofence
class _TranslationsDefaultsGeofenceEs extends _TranslationsDefaultsGeofenceEn {
	_TranslationsDefaultsGeofenceEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get name => 'Mi Ubicación';
	@override String get description => 'Configura esta geocerca tocando el botón de editar';
}

// Path: defaults.notification
class _TranslationsDefaultsNotificationEs extends _TranslationsDefaultsNotificationEn {
	_TranslationsDefaultsNotificationEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Alerta de Ubicación';
}

// Path: defaults.location
class _TranslationsDefaultsLocationEs extends _TranslationsDefaultsLocationEn {
	_TranslationsDefaultsLocationEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'Ubicación Desconocida';
	@override String get update => 'Actualización de Ubicación';
}

// Path: validation.geofence
class _TranslationsValidationGeofenceEs extends _TranslationsValidationGeofenceEn {
	_TranslationsValidationGeofenceEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get idEmpty => 'El ID de geocerca no puede estar vacío';
	@override String get nameEmpty => 'El nombre de geocerca no puede estar vacío';
	@override String get nameLength => 'El nombre de geocerca no puede exceder 100 caracteres';
	@override String get invalidLatitude => 'Latitud inválida. Debe estar entre -90 y 90';
	@override String get invalidLongitude => 'Longitud inválida. Debe estar entre -180 y 180';
	@override String get radiusPositive => 'El radio debe ser mayor que 0';
	@override String get radiusMax => 'El radio no puede exceder 10,000 metros';
	@override String get radiusMin => 'El radio debe ser al menos 10 metros para detección confiable';
	@override String get descriptionLength => 'La descripción no puede exceder 500 caracteres';
}

// Path: geofenceEvents.entry
class _TranslationsGeofenceEventsEntryEs extends _TranslationsGeofenceEventsEntryEn {
	_TranslationsGeofenceEventsEntryEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get displayName => 'Entró';
	@override String get actionDescription => 'Has llegado a';
}

// Path: geofenceEvents.exit
class _TranslationsGeofenceEventsExitEs extends _TranslationsGeofenceEventsExitEn {
	_TranslationsGeofenceEventsExitEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get displayName => 'Salió';
	@override String get actionDescription => 'Has salido de';
}

// Path: liveActivities.config
class _TranslationsLiveActivitiesConfigEs extends _TranslationsLiveActivitiesConfigEn {
	_TranslationsLiveActivitiesConfigEs._(_TranslationsEs root) : this._root = root, super._(root);

	@override final _TranslationsEs _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurar Actividad en Vivo';
	@override String get notificationTitle => 'Título de la Notificación';
	@override String get titleHint => 'ej. ¡Has llegado!';
	@override String get notificationImage => 'Imagen de la Notificación';
	@override String get addImagePrompt => 'Toque para agregar imagen';
	@override String get imageUnavailable => 'Imagen no disponible';
}

// Path: <root>
class _TranslationsFr extends Translations {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	_TranslationsFr.build({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = TranslationMetadata(
		    locale: AppLocale.fr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super.build(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <fr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	@override late final _TranslationsFr _root = this; // ignore: unused_field

	// Translations
	@override late final _TranslationsAppFr app = _TranslationsAppFr._(_root);
	@override late final _TranslationsCommonFr common = _TranslationsCommonFr._(_root);
	@override late final _TranslationsMonitoringFr monitoring = _TranslationsMonitoringFr._(_root);
	@override late final _TranslationsGeofencingFr geofencing = _TranslationsGeofencingFr._(_root);
	@override late final _TranslationsNotificationsFr notifications = _TranslationsNotificationsFr._(_root);
	@override late final _TranslationsDonationsFr donations = _TranslationsDonationsFr._(_root);
	@override late final _TranslationsDefaultsFr defaults = _TranslationsDefaultsFr._(_root);
	@override late final _TranslationsValidationFr validation = _TranslationsValidationFr._(_root);
	@override late final _TranslationsGeofenceEventsFr geofenceEvents = _TranslationsGeofenceEventsFr._(_root);
	@override late final _TranslationsLiveActivitiesFr liveActivities = _TranslationsLiveActivitiesFr._(_root);
}

// Path: app
class _TranslationsAppFr extends _TranslationsAppEn {
	_TranslationsAppFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'LiveSpotAlert';
	@override String get tagline => 'Notification en direct basée sur la localisation';
}

// Path: common
class _TranslationsCommonFr extends _TranslationsCommonEn {
	_TranslationsCommonFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get save => 'Enregistrer';
	@override String get cancel => 'Annuler';
	@override String get grant => 'Accorder';
	@override String get loading => 'Chargement...';
	@override String get retry => 'Réessayer';
	@override String get error => 'Une erreur s\'est produite';
	@override String get dismiss => 'Ignorer';
	@override String get selected => 'Sélectionné';
	@override String get active => 'Actif';
	@override String get inactive => 'Inactif';
	@override String get yes => 'Oui';
	@override String get no => 'Non';
	@override String get stay => 'Rester';
	@override String get remove => 'Supprimer';
	@override late final _TranslationsCommonTimeFr time = _TranslationsCommonTimeFr._(_root);
	@override late final _TranslationsCommonErrorsFr errors = _TranslationsCommonErrorsFr._(_root);
}

// Path: monitoring
class _TranslationsMonitoringFr extends _TranslationsMonitoringEn {
	_TranslationsMonitoringFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Surveillance de Localisation';
	@override late final _TranslationsMonitoringStatusFr status = _TranslationsMonitoringStatusFr._(_root);
	@override late final _TranslationsMonitoringPermissionsFr permissions = _TranslationsMonitoringPermissionsFr._(_root);
	@override String lastEvent({required Object event}) => 'Dernier événement : ${event}';
	@override late final _TranslationsMonitoringEventsFr events = _TranslationsMonitoringEventsFr._(_root);
}

// Path: geofencing
class _TranslationsGeofencingFr extends _TranslationsGeofencingEn {
	_TranslationsGeofencingFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Emplacement de Géofence';
	@override late final _TranslationsGeofencingConfigFr config = _TranslationsGeofencingConfigFr._(_root);
	@override late final _TranslationsGeofencingMapFr map = _TranslationsGeofencingMapFr._(_root);
	@override late final _TranslationsGeofencingStatusFr status = _TranslationsGeofencingStatusFr._(_root);
	@override late final _TranslationsGeofencingCardFr card = _TranslationsGeofencingCardFr._(_root);
	@override late final _TranslationsGeofencingEventsFr events = _TranslationsGeofencingEventsFr._(_root);
	@override late final _TranslationsGeofencingDescriptionFr description = _TranslationsGeofencingDescriptionFr._(_root);
}

// Path: notifications
class _TranslationsNotificationsFr extends _TranslationsNotificationsEn {
	_TranslationsNotificationsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notification';
	@override String get localTitle => 'Notifications Locales';
	@override late final _TranslationsNotificationsConfigFr config = _TranslationsNotificationsConfigFr._(_root);
	@override late final _TranslationsNotificationsStatusFr status = _TranslationsNotificationsStatusFr._(_root);
	@override late final _TranslationsNotificationsPermissionsFr permissions = _TranslationsNotificationsPermissionsFr._(_root);
	@override late final _TranslationsNotificationsPreviewFr preview = _TranslationsNotificationsPreviewFr._(_root);
	@override late final _TranslationsNotificationsDisplayFr display = _TranslationsNotificationsDisplayFr._(_root);
	@override late final _TranslationsNotificationsDialogsFr dialogs = _TranslationsNotificationsDialogsFr._(_root);
}

// Path: donations
class _TranslationsDonationsFr extends _TranslationsDonationsEn {
	_TranslationsDonationsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pot à Pourboires';
	@override String get button => 'Soutenir le Développement';
	@override String get header => 'Si vous appréciez LiveSpotAlert et souhaitez soutenir le développement futur de l\'application, ajouter un pourboire serait d\'une grande aide.';
	@override String get processing => 'Traitement de votre don...';
	@override String get success => 'Merci pour votre généreux don !';
	@override String get error => 'Impossible de charger les options de don';
	@override late final _TranslationsDonationsProductsFr products = _TranslationsDonationsProductsFr._(_root);
	@override late final _TranslationsDonationsThankYouFr thankYou = _TranslationsDonationsThankYouFr._(_root);
}

// Path: defaults
class _TranslationsDefaultsFr extends _TranslationsDefaultsEn {
	_TranslationsDefaultsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsDefaultsGeofenceFr geofence = _TranslationsDefaultsGeofenceFr._(_root);
	@override late final _TranslationsDefaultsNotificationFr notification = _TranslationsDefaultsNotificationFr._(_root);
	@override late final _TranslationsDefaultsLocationFr location = _TranslationsDefaultsLocationFr._(_root);
}

// Path: validation
class _TranslationsValidationFr extends _TranslationsValidationEn {
	_TranslationsValidationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsValidationGeofenceFr geofence = _TranslationsValidationGeofenceFr._(_root);
}

// Path: geofenceEvents
class _TranslationsGeofenceEventsFr extends _TranslationsGeofenceEventsEn {
	_TranslationsGeofenceEventsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsGeofenceEventsEntryFr entry = _TranslationsGeofenceEventsEntryFr._(_root);
	@override late final _TranslationsGeofenceEventsExitFr exit = _TranslationsGeofenceEventsExitFr._(_root);
}

// Path: liveActivities
class _TranslationsLiveActivitiesFr extends _TranslationsLiveActivitiesEn {
	_TranslationsLiveActivitiesFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLiveActivitiesConfigFr config = _TranslationsLiveActivitiesConfigFr._(_root);
}

// Path: common.time
class _TranslationsCommonTimeFr extends _TranslationsCommonTimeEn {
	_TranslationsCommonTimeFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get justNow => 'à l\'instant';
	@override String minutesAgo({required Object minutes}) => 'il y a ${minutes} min';
	@override String hoursAgo({required Object hours}) => 'il y a ${hours} h';
	@override String daysAgo({required Object days}) => 'il y a ${days} jours';
}

// Path: common.errors
class _TranslationsCommonErrorsFr extends _TranslationsCommonErrorsEn {
	_TranslationsCommonErrorsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get required => 'Veuillez saisir un nom';
	@override String get imageNotFound => 'Image introuvable';
	@override String get noImageConfigured => 'Aucune image configurée';
	@override String get unknownLocation => 'Emplacement inconnu';
}

// Path: monitoring.status
class _TranslationsMonitoringStatusFr extends _TranslationsMonitoringStatusEn {
	_TranslationsMonitoringStatusFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get active => 'Surveillance active de votre localisation';
	@override String get disabled => 'La surveillance est désactivée';
}

// Path: monitoring.permissions
class _TranslationsMonitoringPermissionsFr extends _TranslationsMonitoringPermissionsEn {
	_TranslationsMonitoringPermissionsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get required => 'Autorisations de localisation requises';
}

// Path: monitoring.events
class _TranslationsMonitoringEventsFr extends _TranslationsMonitoringEventsEn {
	_TranslationsMonitoringEventsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String entered({required Object name}) => 'Entré dans ${name}';
	@override String exited({required Object name}) => 'Sorti de ${name}';
	@override String get locationUpdate => 'Mise à jour de localisation';
}

// Path: geofencing.config
class _TranslationsGeofencingConfigFr extends _TranslationsGeofencingConfigEn {
	_TranslationsGeofencingConfigFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Emplacement de Géofence';
	@override String get createTitle => 'Créer une Géofence';
	@override String get editTitle => 'Modifier la Géofence';
	@override String get configure => 'Configurer la Géofence';
	@override String get nameLabel => 'Nom de la Géofence';
	@override String get nameHint => 'ex. Maison, Bureau, Salle de sport';
	@override String get locationLabel => 'Emplacement';
	@override String radiusLabel({required Object radius}) => 'Rayon : ${radius}m';
	@override String get minRadius => '10m';
	@override String get maxRadius => '1km';
	@override String get defaultName => 'Mon Emplacement';
	@override String get noConfigured => 'Aucune géofence configurée';
}

// Path: geofencing.map
class _TranslationsGeofencingMapFr extends _TranslationsGeofencingMapEn {
	_TranslationsGeofencingMapFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get instructions => 'Touchez la carte ou faites glisser le marqueur pour définir l\'emplacement';
	@override String get centerOnLocation => 'Centrer sur ma localisation';
	@override String get centerOnGeofence => 'Centrer sur la géofence';
	@override String locationInfo({required Object lat, required Object lng}) => 'Emplacement : ${lat}, ${lng}';
}

// Path: geofencing.status
class _TranslationsGeofencingStatusFr extends _TranslationsGeofencingStatusEn {
	_TranslationsGeofencingStatusFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Chargement...';
	@override String get error => 'Une erreur s\'est produite';
	@override String get inactive => 'Géofence inactive';
	@override String get inside => 'À l\'intérieur de la zone de géofence';
	@override String get outside => 'À l\'extérieur de la zone de géofence';
	@override String get youAreInside => 'Vous êtes dans cette zone';
	@override String get youAreOutside => 'Vous êtes hors de cette zone';
	@override String distance({required Object distance}) => 'Distance : ${distance}m';
	@override String get hasMedia => 'A des médias attachés';
}

// Path: geofencing.card
class _TranslationsGeofencingCardFr extends _TranslationsGeofencingCardEn {
	_TranslationsGeofencingCardFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String radiusInfo({required Object radius}) => 'Rayon de ${radius}m';
	@override String distanceInfo({required Object distance}) => 'À ${distance}m de distance';
	@override String get recentActivity => 'Activité Récente';
}

// Path: geofencing.events
class _TranslationsGeofencingEventsFr extends _TranslationsGeofencingEventsEn {
	_TranslationsGeofencingEventsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get entered => 'Entré';
	@override String get exited => 'Sorti';
	@override String get dwelling => 'En séjour';
}

// Path: geofencing.description
class _TranslationsGeofencingDescriptionFr extends _TranslationsGeofencingDescriptionEn {
	_TranslationsGeofencingDescriptionFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get active => 'La géofence déclenchera des notifications';
	@override String get inactive => 'La géofence est configurée mais inactive';
}

// Path: notifications.config
class _TranslationsNotificationsConfigFr extends _TranslationsNotificationsConfigEn {
	_TranslationsNotificationsConfigFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Paramètres de Notification';
	@override String get configure => 'Configurer la Notification';
	@override String get saving => 'Enregistrement...';
	@override String get content => 'Contenu de la Notification';
	@override String get titleLabel => 'Titre';
	@override String get titleHint => 'ex. Arrivé à l\'emplacement, Alerte de localisation';
	@override String get defaultTitle => 'Alerte de Localisation';
	@override String get locationSuffix => '@ Emplacement';
	@override String get preview => 'Aperçu :';
	@override String get image => 'Image';
	@override String get changeImage => 'Changer l\'Image';
	@override String get noImageSelected => 'Aucune image sélectionnée';
	@override String get selectFromGallery => 'Sélectionner depuis la Galerie';
	@override String get selecting => 'Sélection...';
	@override String get imageInfo => 'Les images seront affichées dans les notifications. Formats pris en charge : JPG, PNG. Taille maximale : 5 Mo.';
	@override String get permissions => 'Autorisations';
	@override String get testNotification => 'Tester la Notification';
}

// Path: notifications.status
class _TranslationsNotificationsStatusFr extends _TranslationsNotificationsStatusEn {
	_TranslationsNotificationsStatusFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Chargement...';
	@override String get error => 'Une erreur s\'est produite';
	@override String get disabled => 'Notifications désactivées';
	@override String get permissionsRequired => 'Autorisations requises';
	@override String get enabled => 'Notifications activées';
	@override String titleFormat({required Object title}) => 'Titre : "${title}"';
	@override String get customImage => 'Image personnalisée : ';
	@override String get imageNotSelected => 'Image : Non sélectionnée';
}

// Path: notifications.permissions
class _TranslationsNotificationsPermissionsFr extends _TranslationsNotificationsPermissionsEn {
	_TranslationsNotificationsPermissionsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get required => 'Autorisations de notification requises';
	@override String get granted => 'Autorisations de notification accordées';
}

// Path: notifications.preview
class _TranslationsNotificationsPreviewFr extends _TranslationsNotificationsPreviewEn {
	_TranslationsNotificationsPreviewFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Aperçu de Notification';
	@override String get description => 'Testez comment votre notification apparaîtra lorsqu\'elle sera déclenchée par un événement de géofence.';
	@override String get entryButton => 'Aperçu d\'Alerte d\'Entrée';
	@override String get exitButton => 'Aperçu d\'Alerte de Sortie';
	@override String info({required Object name}) => 'L\'aperçu utilisera la géofence "${name}" et vos paramètres de notification actuels.';
	@override String get noGeofence => 'Aucune géofence configurée';
	@override String get noGeofenceMessage => 'Configurez d\'abord une géofence pour prévisualiser les notifications.';
}

// Path: notifications.display
class _TranslationsNotificationsDisplayFr extends _TranslationsNotificationsDisplayEn {
	_TranslationsNotificationsDisplayFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get placeholderTitle => 'Aucune image configurée';
	@override String get placeholderMessage => 'Configurez une image dans les paramètres de notification';
}

// Path: notifications.dialogs
class _TranslationsNotificationsDialogsFr extends _TranslationsNotificationsDialogsEn {
	_TranslationsNotificationsDialogsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get unsavedChanges => 'Modifications Non Enregistrées';
	@override String get unsavedMessage => 'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir annuler ?';
}

// Path: donations.products
class _TranslationsDonationsProductsFr extends _TranslationsDonationsProductsEn {
	_TranslationsDonationsProductsFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get smallTip => 'Petit Pourboire';
	@override String get mediumTip => 'Pourboire Moyen';
	@override String get largeTip => 'Gros Pourboire';
	@override String get giantTip => 'Pourboire Géant';
}

// Path: donations.thankYou
class _TranslationsDonationsThankYouFr extends _TranslationsDonationsThankYouEn {
	_TranslationsDonationsThankYouFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Merci !';
	@override String get message => 'Votre soutien aide à maintenir cette application gratuite et en amélioration continue. Nous apprécions vraiment votre générosité !';
}

// Path: defaults.geofence
class _TranslationsDefaultsGeofenceFr extends _TranslationsDefaultsGeofenceEn {
	_TranslationsDefaultsGeofenceFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get name => 'Mon Emplacement';
	@override String get description => 'Configurez cette géofence en touchant le bouton d\'édition';
}

// Path: defaults.notification
class _TranslationsDefaultsNotificationFr extends _TranslationsDefaultsNotificationEn {
	_TranslationsDefaultsNotificationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Alerte de Localisation';
}

// Path: defaults.location
class _TranslationsDefaultsLocationFr extends _TranslationsDefaultsLocationEn {
	_TranslationsDefaultsLocationFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get unknown => 'Emplacement Inconnu';
	@override String get update => 'Mise à jour d\'Emplacement';
}

// Path: validation.geofence
class _TranslationsValidationGeofenceFr extends _TranslationsValidationGeofenceEn {
	_TranslationsValidationGeofenceFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get idEmpty => 'L\'ID de géofence ne peut pas être vide';
	@override String get nameEmpty => 'Le nom de géofence ne peut pas être vide';
	@override String get nameLength => 'Le nom de géofence ne peut pas dépasser 100 caractères';
	@override String get invalidLatitude => 'Latitude invalide. Doit être entre -90 et 90';
	@override String get invalidLongitude => 'Longitude invalide. Doit être entre -180 et 180';
	@override String get radiusPositive => 'Le rayon doit être supérieur à 0';
	@override String get radiusMax => 'Le rayon ne peut pas dépasser 10 000 mètres';
	@override String get radiusMin => 'Le rayon doit être d\'au moins 10 mètres pour une détection fiable';
	@override String get descriptionLength => 'La description ne peut pas dépasser 500 caractères';
}

// Path: geofenceEvents.entry
class _TranslationsGeofenceEventsEntryFr extends _TranslationsGeofenceEventsEntryEn {
	_TranslationsGeofenceEventsEntryFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get displayName => 'Entré';
	@override String get actionDescription => 'Vous êtes arrivé à';
}

// Path: geofenceEvents.exit
class _TranslationsGeofenceEventsExitFr extends _TranslationsGeofenceEventsExitEn {
	_TranslationsGeofenceEventsExitFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get displayName => 'Sorti';
	@override String get actionDescription => 'Vous avez quitté';
}

// Path: liveActivities.config
class _TranslationsLiveActivitiesConfigFr extends _TranslationsLiveActivitiesConfigEn {
	_TranslationsLiveActivitiesConfigFr._(_TranslationsFr root) : this._root = root, super._(root);

	@override final _TranslationsFr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Configurer l\'Activité en Direct';
	@override String get notificationTitle => 'Titre de la Notification';
	@override String get titleHint => 'ex. Vous êtes arrivé !';
	@override String get notificationImage => 'Image de la Notification';
	@override String get addImagePrompt => 'Touchez pour ajouter une image';
	@override String get imageUnavailable => 'Image indisponible';
}

/// Flat map(s) containing all translations.
/// Only for edge cases! For simple maps, use the map function of this library.

extension on Translations {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.name': return 'LiveSpotAlert';
			case 'app.tagline': return 'Location-based Live Notification';
			case 'common.save': return 'Save';
			case 'common.cancel': return 'Cancel';
			case 'common.grant': return 'Grant';
			case 'common.loading': return 'Loading...';
			case 'common.retry': return 'Retry';
			case 'common.error': return 'Error occurred';
			case 'common.dismiss': return 'Dismiss';
			case 'common.selected': return 'Selected';
			case 'common.active': return 'Active';
			case 'common.inactive': return 'Inactive';
			case 'common.yes': return 'Yes';
			case 'common.no': return 'No';
			case 'common.stay': return 'Stay';
			case 'common.remove': return 'Remove';
			case 'common.time.justNow': return 'just now';
			case 'common.time.minutesAgo': return ({required Object minutes}) => '${minutes}m ago';
			case 'common.time.hoursAgo': return ({required Object hours}) => '${hours}h ago';
			case 'common.time.daysAgo': return ({required Object days}) => '${days}d ago';
			case 'common.errors.required': return 'Please enter a name';
			case 'common.errors.imageNotFound': return 'Image not found';
			case 'common.errors.noImageConfigured': return 'No image configured';
			case 'common.errors.unknownLocation': return 'Unknown Location';
			case 'defaults.geofence.name': return 'My Location';
			case 'defaults.geofence.description': return 'Configure this geofence by tapping the edit button';
			case 'defaults.notification.title': return 'Location Alert';
			case 'defaults.location.unknown': return 'Unknown Location';
			case 'defaults.location.update': return 'Location Update';
			case 'validation.geofence.idEmpty': return 'Geofence ID cannot be empty';
			case 'validation.geofence.nameEmpty': return 'Geofence name cannot be empty';
			case 'validation.geofence.nameLength': return 'Geofence name cannot exceed 100 characters';
			case 'validation.geofence.invalidLatitude': return 'Invalid latitude. Must be between -90 and 90';
			case 'validation.geofence.invalidLongitude': return 'Invalid longitude. Must be between -180 and 180';
			case 'validation.geofence.radiusPositive': return 'Radius must be greater than 0';
			case 'validation.geofence.radiusMax': return 'Radius cannot exceed 10,000 meters';
			case 'validation.geofence.radiusMin': return 'Radius must be at least 10 meters for reliable detection';
			case 'validation.geofence.descriptionLength': return 'Description cannot exceed 500 characters';
			case 'errors.liveActivity.notEnabled': return 'Live Activities are not enabled on this device';
			case 'errors.liveActivity.createFailed': return 'Failed to create Live Activity';
			case 'errors.liveActivity.startFailed': return 'Error starting Live Activity: {error}';
			case 'errors.liveActivity.stopFailed': return 'Error stopping Live Activity: {error}';
			case 'errors.liveActivity.updateFailed': return 'Error updating Live Activity: {error}';
			case 'errors.liveActivity.imageFailed': return 'Failed to process image: {error}';
			case 'errors.donations.notAvailable': return 'In-app purchases are not available';
			case 'errors.donations.productNotFound': return 'Product not found: {productId}';
			case 'errors.donations.purchaseFailed': return 'Failed to initiate purchase';
			case 'errors.donations.purchaseTimeout': return 'Purchase timeout';
			case 'errors.donations.purchaseError': return 'Purchase failed: {error}';
			case 'errors.donations.historyFailed': return 'Failed to get purchase history: {error}';
			case 'errors.donations.historyCheckFailed': return 'Failed to check purchase history: {error}';
			case 'errors.geofencing.permissionsFailed': return 'Failed to request permissions: {error}';
			case 'errors.geofencing.permissionsCheckFailed': return 'Failed to check permissions: {error}';
			case 'errors.geofencing.locationEventError': return 'Location event stream error: {error}';
			case 'errors.geofencing.geofenceStatusError': return 'Geofence status stream error: {error}';
			case 'errors.geofencing.entryNotificationFailed': return 'Failed to handle geofence entry notification: {error}';
			case 'errors.geofencing.exitNotificationFailed': return 'Failed to handle geofence exit notification: {error}';
			case 'errors.geofencing.dwellNotificationFailed': return 'Failed to handle geofence dwell notification: {error}';
			case 'errors.notifications.initFailed': return 'Failed to initialize notifications service: {error}';
			case 'errors.notifications.loadConfigFailed': return 'Failed to load notification configuration: {error}';
			case 'errors.notifications.saveConfigFailed': return 'Failed to save notification configuration: {error}';
			case 'errors.notifications.notAvailable': return 'Notifications not available';
			case 'errors.notifications.showFailed': return 'Failed to show geofence notification: {error}';
			case 'errors.notifications.dismissFailed': return 'Failed to dismiss geofence notification: {error}';
			case 'errors.notifications.dismissAllFailed': return 'Failed to dismiss all notifications: {error}';
			case 'errors.notifications.availabilityCheckFailed': return 'Failed to check notifications availability: {error}';
			case 'errors.notifications.permissionsFailed': return 'Failed to request notification permissions: {error}';
			case 'geofenceEvents.entry.displayName': return 'Entered';
			case 'geofenceEvents.entry.actionDescription': return 'You have arrived at';
			case 'geofenceEvents.exit.displayName': return 'Exited';
			case 'geofenceEvents.exit.actionDescription': return 'You have left';
			case 'notifications.title': return 'Notification';
			case 'notifications.localTitle': return 'Local Notifications';
			case 'notifications.config.title': return 'Notification Settings';
			case 'notifications.config.configure': return 'Configure Notification';
			case 'notifications.config.saving': return 'Saving...';
			case 'notifications.config.content': return 'Notification Content';
			case 'notifications.config.titleLabel': return 'Title';
			case 'notifications.config.titleHint': return 'e.g., Arrived at location, Location alert';
			case 'notifications.config.defaultTitle': return 'Location Alert';
			case 'notifications.config.locationSuffix': return '@ Location';
			case 'notifications.config.preview': return 'Preview:';
			case 'notifications.config.image': return 'Image';
			case 'notifications.config.changeImage': return 'Change Image';
			case 'notifications.config.noImageSelected': return 'No image selected';
			case 'notifications.config.selectFromGallery': return 'Select from Gallery';
			case 'notifications.config.selecting': return 'Selecting...';
			case 'notifications.config.imageInfo': return 'Images will be displayed in notifications. Supported formats: JPG, PNG. Max size: 5MB.';
			case 'notifications.config.permissions': return 'Permissions';
			case 'notifications.config.testNotification': return 'Test Notification';
			case 'notifications.status.loading': return 'Loading...';
			case 'notifications.status.error': return 'Error occurred';
			case 'notifications.status.disabled': return 'Notifications disabled';
			case 'notifications.status.permissionsRequired': return 'Permissions required';
			case 'notifications.status.enabled': return 'Notifications enabled';
			case 'notifications.status.titleFormat': return ({required Object title}) => 'Title: "${title}"';
			case 'notifications.status.customImage': return 'Custom image: ';
			case 'notifications.status.imageNotSelected': return 'Image: Not selected';
			case 'notifications.permissions.required': return 'Notification permissions required';
			case 'notifications.permissions.granted': return 'Notification permissions granted';
			case 'notifications.preview.title': return 'Preview Live Spot Alert';
			case 'notifications.preview.description': return 'Test how your notification will look when triggered by a geofence event.';
			case 'notifications.preview.entryButton': return 'Preview Entry Alert';
			case 'notifications.preview.exitButton': return 'Preview Exit Alert';
			case 'notifications.preview.info': return ({required Object name}) => 'Preview will use "${name}" geofence and your current notification settings.';
			case 'notifications.preview.noGeofence': return 'No geofence configured';
			case 'notifications.preview.noGeofenceMessage': return 'Configure a geofence first to preview notifications.';
			case 'notifications.display.placeholderTitle': return 'No image configured';
			case 'notifications.display.placeholderMessage': return 'Configure an image in notification settings';
			case 'notifications.dialogs.unsavedChanges': return 'Unsaved Changes';
			case 'notifications.dialogs.unsavedMessage': return 'You have unsaved changes. Are you sure you want to cancel?';
			case 'monitoring.title': return 'Location Monitoring';
			case 'monitoring.status.active': return 'Actively monitoring your location';
			case 'monitoring.status.disabled': return 'Monitoring is disabled';
			case 'monitoring.permissions.required': return 'Location permissions required';
			case 'monitoring.lastEvent': return ({required Object event}) => 'Last event: ${event}';
			case 'monitoring.events.entered': return ({required Object name}) => 'Entered ${name}';
			case 'monitoring.events.exited': return ({required Object name}) => 'Exited ${name}';
			case 'monitoring.events.locationUpdate': return 'Location update';
			case 'geofencing.title': return 'Geofence Location';
			case 'geofencing.config.title': return 'Geofence Location';
			case 'geofencing.config.createTitle': return 'Create Geofence';
			case 'geofencing.config.editTitle': return 'Edit Geofence';
			case 'geofencing.config.configure': return 'Configure Geofence';
			case 'geofencing.config.nameLabel': return 'Geofence Name';
			case 'geofencing.config.nameHint': return 'e.g., Home, Office, Gym';
			case 'geofencing.config.locationLabel': return 'Location';
			case 'geofencing.config.radiusLabel': return ({required Object radius}) => 'Radius: ${radius}m';
			case 'geofencing.config.minRadius': return '10m';
			case 'geofencing.config.maxRadius': return '1km';
			case 'geofencing.config.defaultName': return 'My Location';
			case 'geofencing.config.noConfigured': return 'No geofence configured';
			case 'geofencing.map.instructions': return 'Tap map or drag marker to set location';
			case 'geofencing.map.centerOnLocation': return 'Center on my location';
			case 'geofencing.map.centerOnGeofence': return 'Center on geofence';
			case 'geofencing.map.locationInfo': return ({required Object lat, required Object lng}) => 'Location: ${lat}, ${lng}';
			case 'geofencing.status.loading': return 'Loading...';
			case 'geofencing.status.error': return 'Error occurred';
			case 'geofencing.status.inactive': return 'Geofence inactive';
			case 'geofencing.status.inside': return 'Inside geofence area';
			case 'geofencing.status.outside': return 'Outside geofence area';
			case 'geofencing.status.youAreInside': return 'You are inside this area';
			case 'geofencing.status.youAreOutside': return 'You are outside this area';
			case 'geofencing.status.distance': return ({required Object distance}) => 'Distance: ${distance}m';
			case 'geofencing.status.hasMedia': return 'Has attached media';
			case 'geofencing.card.radiusInfo': return ({required Object radius}) => '${radius}m radius';
			case 'geofencing.card.distanceInfo': return ({required Object distance}) => '${distance}m away';
			case 'geofencing.card.recentActivity': return 'Recent Activity';
			case 'geofencing.events.entered': return 'Entered';
			case 'geofencing.events.exited': return 'Exited';
			case 'geofencing.events.dwelling': return 'Dwelling';
			case 'geofencing.description.active': return 'Geofence will trigger notifications';
			case 'geofencing.description.inactive': return 'Geofence is configured but inactive';
			case 'donations.title': return 'Tip Jar';
			case 'donations.button': return 'Support Development';
			case 'donations.header': return 'If you are enjoying LiveSpotAlert and would like to support the app\'s future development, adding a tip would be greatly helpful.';
			case 'donations.processing': return 'Processing your donation...';
			case 'donations.success': return 'Thank you for your generous donation!';
			case 'donations.error': return 'Unable to load donation options';
			case 'donations.products.smallTip': return 'Small Tip';
			case 'donations.products.mediumTip': return 'Medium Tip';
			case 'donations.products.largeTip': return 'Large Tip';
			case 'donations.products.giantTip': return 'Giant Tip';
			case 'donations.thankYou.title': return 'Thank You!';
			case 'donations.thankYou.message': return 'Your support helps keep this app free and continuously improving. We truly appreciate your generosity!';
			case 'liveActivities.config.title': return 'Configure Live Activity';
			case 'liveActivities.config.notificationTitle': return 'Notification Title';
			case 'liveActivities.config.titleHint': return 'e.g., You\'ve arrived!';
			case 'liveActivities.config.notificationImage': return 'Notification Image';
			case 'liveActivities.config.addImagePrompt': return 'Tap to add image';
			case 'liveActivities.config.imageUnavailable': return 'Image unavailable';
			default: return null;
		}
	}
}

extension on _TranslationsEs {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.name': return 'LiveSpotAlert';
			case 'app.tagline': return 'Notificación en vivo basada en ubicación';
			case 'common.save': return 'Guardar';
			case 'common.cancel': return 'Cancelar';
			case 'common.grant': return 'Conceder';
			case 'common.loading': return 'Cargando...';
			case 'common.retry': return 'Reintentar';
			case 'common.error': return 'Ocurrió un error';
			case 'common.dismiss': return 'Descartar';
			case 'common.selected': return 'Seleccionado';
			case 'common.active': return 'Activo';
			case 'common.inactive': return 'Inactivo';
			case 'common.yes': return 'Sí';
			case 'common.no': return 'No';
			case 'common.stay': return 'Quedarse';
			case 'common.remove': return 'Eliminar';
			case 'common.time.justNow': return 'ahora mismo';
			case 'common.time.minutesAgo': return ({required Object minutes}) => 'hace ${minutes} min';
			case 'common.time.hoursAgo': return ({required Object hours}) => 'hace ${hours} h';
			case 'common.time.daysAgo': return ({required Object days}) => 'hace ${days} días';
			case 'common.errors.required': return 'Por favor ingrese un nombre';
			case 'common.errors.imageNotFound': return 'Imagen no encontrada';
			case 'common.errors.noImageConfigured': return 'No hay imagen configurada';
			case 'common.errors.unknownLocation': return 'Ubicación desconocida';
			case 'monitoring.title': return 'Monitoreo de Ubicación';
			case 'monitoring.status.active': return 'Monitoreando activamente su ubicación';
			case 'monitoring.status.disabled': return 'El monitoreo está deshabilitado';
			case 'monitoring.permissions.required': return 'Se requieren permisos de ubicación';
			case 'monitoring.lastEvent': return ({required Object event}) => 'Último evento: ${event}';
			case 'monitoring.events.entered': return ({required Object name}) => 'Entró a ${name}';
			case 'monitoring.events.exited': return ({required Object name}) => 'Salió de ${name}';
			case 'monitoring.events.locationUpdate': return 'Actualización de ubicación';
			case 'geofencing.title': return 'Ubicación de Geocerca';
			case 'geofencing.config.title': return 'Ubicación de Geocerca';
			case 'geofencing.config.createTitle': return 'Crear Geocerca';
			case 'geofencing.config.editTitle': return 'Editar Geocerca';
			case 'geofencing.config.configure': return 'Configurar Geocerca';
			case 'geofencing.config.nameLabel': return 'Nombre de la Geocerca';
			case 'geofencing.config.nameHint': return 'ej. Casa, Oficina, Gimnasio';
			case 'geofencing.config.locationLabel': return 'Ubicación';
			case 'geofencing.config.radiusLabel': return ({required Object radius}) => 'Radio: ${radius}m';
			case 'geofencing.config.minRadius': return '10m';
			case 'geofencing.config.maxRadius': return '1km';
			case 'geofencing.config.defaultName': return 'Mi Ubicación';
			case 'geofencing.config.noConfigured': return 'No hay geocerca configurada';
			case 'geofencing.map.instructions': return 'Toque el mapa o arrastre el marcador para establecer la ubicación';
			case 'geofencing.map.centerOnLocation': return 'Centrar en mi ubicación';
			case 'geofencing.map.centerOnGeofence': return 'Centrar en la geocerca';
			case 'geofencing.map.locationInfo': return ({required Object lat, required Object lng}) => 'Ubicación: ${lat}, ${lng}';
			case 'geofencing.status.loading': return 'Cargando...';
			case 'geofencing.status.error': return 'Ocurrió un error';
			case 'geofencing.status.inactive': return 'Geocerca inactiva';
			case 'geofencing.status.inside': return 'Dentro del área de geocerca';
			case 'geofencing.status.outside': return 'Fuera del área de geocerca';
			case 'geofencing.status.youAreInside': return 'Está dentro de esta área';
			case 'geofencing.status.youAreOutside': return 'Está fuera de esta área';
			case 'geofencing.status.distance': return ({required Object distance}) => 'Distancia: ${distance}m';
			case 'geofencing.status.hasMedia': return 'Tiene medios adjuntos';
			case 'geofencing.card.radiusInfo': return ({required Object radius}) => 'Radio de ${radius}m';
			case 'geofencing.card.distanceInfo': return ({required Object distance}) => 'A ${distance}m de distancia';
			case 'geofencing.card.recentActivity': return 'Actividad Reciente';
			case 'geofencing.events.entered': return 'Entró';
			case 'geofencing.events.exited': return 'Salió';
			case 'geofencing.events.dwelling': return 'Permaneciendo';
			case 'geofencing.description.active': return 'La geocerca activará notificaciones';
			case 'geofencing.description.inactive': return 'La geocerca está configurada pero inactiva';
			case 'notifications.title': return 'Notificación';
			case 'notifications.localTitle': return 'Notificaciones Locales';
			case 'notifications.config.title': return 'Configuración de Notificaciones';
			case 'notifications.config.configure': return 'Configurar Notificación';
			case 'notifications.config.saving': return 'Guardando...';
			case 'notifications.config.content': return 'Contenido de la Notificación';
			case 'notifications.config.titleLabel': return 'Título';
			case 'notifications.config.titleHint': return 'ej. Llegó a la ubicación, Alerta de ubicación';
			case 'notifications.config.defaultTitle': return 'Alerta de Ubicación';
			case 'notifications.config.locationSuffix': return '@ Ubicación';
			case 'notifications.config.preview': return 'Vista previa:';
			case 'notifications.config.image': return 'Imagen';
			case 'notifications.config.changeImage': return 'Cambiar Imagen';
			case 'notifications.config.noImageSelected': return 'No se ha seleccionado imagen';
			case 'notifications.config.selectFromGallery': return 'Seleccionar de la Galería';
			case 'notifications.config.selecting': return 'Seleccionando...';
			case 'notifications.config.imageInfo': return 'Las imágenes se mostrarán en las notificaciones. Formatos compatibles: JPG, PNG. Tamaño máximo: 5MB.';
			case 'notifications.config.permissions': return 'Permisos';
			case 'notifications.config.testNotification': return 'Probar Notificación';
			case 'notifications.status.loading': return 'Cargando...';
			case 'notifications.status.error': return 'Ocurrió un error';
			case 'notifications.status.disabled': return 'Notificaciones deshabilitadas';
			case 'notifications.status.permissionsRequired': return 'Se requieren permisos';
			case 'notifications.status.enabled': return 'Notificaciones habilitadas';
			case 'notifications.status.titleFormat': return ({required Object title}) => 'Título: "${title}"';
			case 'notifications.status.customImage': return 'Imagen personalizada: ';
			case 'notifications.status.imageNotSelected': return 'Imagen: No seleccionada';
			case 'notifications.permissions.required': return 'Se requieren permisos de notificación';
			case 'notifications.permissions.granted': return 'Permisos de notificación concedidos';
			case 'notifications.preview.title': return 'Vista Previa de Notificación';
			case 'notifications.preview.description': return 'Pruebe cómo se verá su notificación cuando sea activada por un evento de geocerca.';
			case 'notifications.preview.entryButton': return 'Vista Previa de Alerta de Entrada';
			case 'notifications.preview.exitButton': return 'Vista Previa de Alerta de Salida';
			case 'notifications.preview.info': return ({required Object name}) => 'La vista previa usará la geocerca "${name}" y su configuración actual de notificaciones.';
			case 'notifications.preview.noGeofence': return 'No hay geocerca configurada';
			case 'notifications.preview.noGeofenceMessage': return 'Configure una geocerca primero para ver las notificaciones.';
			case 'notifications.display.placeholderTitle': return 'No hay imagen configurada';
			case 'notifications.display.placeholderMessage': return 'Configure una imagen en la configuración de notificaciones';
			case 'notifications.dialogs.unsavedChanges': return 'Cambios No Guardados';
			case 'notifications.dialogs.unsavedMessage': return 'Tiene cambios no guardados. ¿Está seguro de que quiere cancelar?';
			case 'donations.title': return 'Bote de Propinas';
			case 'donations.button': return 'Apoyar el Desarrollo';
			case 'donations.header': return 'Si está disfrutando LiveSpotAlert y le gustaría apoyar el desarrollo futuro de la aplicación, agregar una propina sería de gran ayuda.';
			case 'donations.processing': return 'Procesando su donación...';
			case 'donations.success': return '¡Gracias por su generosa donación!';
			case 'donations.error': return 'No se pudieron cargar las opciones de donación';
			case 'donations.products.smallTip': return 'Propina Pequeña';
			case 'donations.products.mediumTip': return 'Propina Mediana';
			case 'donations.products.largeTip': return 'Propina Grande';
			case 'donations.products.giantTip': return 'Propina Gigante';
			case 'donations.thankYou.title': return '¡Gracias!';
			case 'donations.thankYou.message': return 'Su apoyo ayuda a mantener esta aplicación gratuita y en continua mejora. ¡Realmente apreciamos su generosidad!';
			case 'defaults.geofence.name': return 'Mi Ubicación';
			case 'defaults.geofence.description': return 'Configura esta geocerca tocando el botón de editar';
			case 'defaults.notification.title': return 'Alerta de Ubicación';
			case 'defaults.location.unknown': return 'Ubicación Desconocida';
			case 'defaults.location.update': return 'Actualización de Ubicación';
			case 'validation.geofence.idEmpty': return 'El ID de geocerca no puede estar vacío';
			case 'validation.geofence.nameEmpty': return 'El nombre de geocerca no puede estar vacío';
			case 'validation.geofence.nameLength': return 'El nombre de geocerca no puede exceder 100 caracteres';
			case 'validation.geofence.invalidLatitude': return 'Latitud inválida. Debe estar entre -90 y 90';
			case 'validation.geofence.invalidLongitude': return 'Longitud inválida. Debe estar entre -180 y 180';
			case 'validation.geofence.radiusPositive': return 'El radio debe ser mayor que 0';
			case 'validation.geofence.radiusMax': return 'El radio no puede exceder 10,000 metros';
			case 'validation.geofence.radiusMin': return 'El radio debe ser al menos 10 metros para detección confiable';
			case 'validation.geofence.descriptionLength': return 'La descripción no puede exceder 500 caracteres';
			case 'geofenceEvents.entry.displayName': return 'Entró';
			case 'geofenceEvents.entry.actionDescription': return 'Has llegado a';
			case 'geofenceEvents.exit.displayName': return 'Salió';
			case 'geofenceEvents.exit.actionDescription': return 'Has salido de';
			case 'liveActivities.config.title': return 'Configurar Actividad en Vivo';
			case 'liveActivities.config.notificationTitle': return 'Título de la Notificación';
			case 'liveActivities.config.titleHint': return 'ej. ¡Has llegado!';
			case 'liveActivities.config.notificationImage': return 'Imagen de la Notificación';
			case 'liveActivities.config.addImagePrompt': return 'Toque para agregar imagen';
			case 'liveActivities.config.imageUnavailable': return 'Imagen no disponible';
			default: return null;
		}
	}
}

extension on _TranslationsFr {
	dynamic _flatMapFunction(String path) {
		switch (path) {
			case 'app.name': return 'LiveSpotAlert';
			case 'app.tagline': return 'Notification en direct basée sur la localisation';
			case 'common.save': return 'Enregistrer';
			case 'common.cancel': return 'Annuler';
			case 'common.grant': return 'Accorder';
			case 'common.loading': return 'Chargement...';
			case 'common.retry': return 'Réessayer';
			case 'common.error': return 'Une erreur s\'est produite';
			case 'common.dismiss': return 'Ignorer';
			case 'common.selected': return 'Sélectionné';
			case 'common.active': return 'Actif';
			case 'common.inactive': return 'Inactif';
			case 'common.yes': return 'Oui';
			case 'common.no': return 'Non';
			case 'common.stay': return 'Rester';
			case 'common.remove': return 'Supprimer';
			case 'common.time.justNow': return 'à l\'instant';
			case 'common.time.minutesAgo': return ({required Object minutes}) => 'il y a ${minutes} min';
			case 'common.time.hoursAgo': return ({required Object hours}) => 'il y a ${hours} h';
			case 'common.time.daysAgo': return ({required Object days}) => 'il y a ${days} jours';
			case 'common.errors.required': return 'Veuillez saisir un nom';
			case 'common.errors.imageNotFound': return 'Image introuvable';
			case 'common.errors.noImageConfigured': return 'Aucune image configurée';
			case 'common.errors.unknownLocation': return 'Emplacement inconnu';
			case 'monitoring.title': return 'Surveillance de Localisation';
			case 'monitoring.status.active': return 'Surveillance active de votre localisation';
			case 'monitoring.status.disabled': return 'La surveillance est désactivée';
			case 'monitoring.permissions.required': return 'Autorisations de localisation requises';
			case 'monitoring.lastEvent': return ({required Object event}) => 'Dernier événement : ${event}';
			case 'monitoring.events.entered': return ({required Object name}) => 'Entré dans ${name}';
			case 'monitoring.events.exited': return ({required Object name}) => 'Sorti de ${name}';
			case 'monitoring.events.locationUpdate': return 'Mise à jour de localisation';
			case 'geofencing.title': return 'Emplacement de Géofence';
			case 'geofencing.config.title': return 'Emplacement de Géofence';
			case 'geofencing.config.createTitle': return 'Créer une Géofence';
			case 'geofencing.config.editTitle': return 'Modifier la Géofence';
			case 'geofencing.config.configure': return 'Configurer la Géofence';
			case 'geofencing.config.nameLabel': return 'Nom de la Géofence';
			case 'geofencing.config.nameHint': return 'ex. Maison, Bureau, Salle de sport';
			case 'geofencing.config.locationLabel': return 'Emplacement';
			case 'geofencing.config.radiusLabel': return ({required Object radius}) => 'Rayon : ${radius}m';
			case 'geofencing.config.minRadius': return '10m';
			case 'geofencing.config.maxRadius': return '1km';
			case 'geofencing.config.defaultName': return 'Mon Emplacement';
			case 'geofencing.config.noConfigured': return 'Aucune géofence configurée';
			case 'geofencing.map.instructions': return 'Touchez la carte ou faites glisser le marqueur pour définir l\'emplacement';
			case 'geofencing.map.centerOnLocation': return 'Centrer sur ma localisation';
			case 'geofencing.map.centerOnGeofence': return 'Centrer sur la géofence';
			case 'geofencing.map.locationInfo': return ({required Object lat, required Object lng}) => 'Emplacement : ${lat}, ${lng}';
			case 'geofencing.status.loading': return 'Chargement...';
			case 'geofencing.status.error': return 'Une erreur s\'est produite';
			case 'geofencing.status.inactive': return 'Géofence inactive';
			case 'geofencing.status.inside': return 'À l\'intérieur de la zone de géofence';
			case 'geofencing.status.outside': return 'À l\'extérieur de la zone de géofence';
			case 'geofencing.status.youAreInside': return 'Vous êtes dans cette zone';
			case 'geofencing.status.youAreOutside': return 'Vous êtes hors de cette zone';
			case 'geofencing.status.distance': return ({required Object distance}) => 'Distance : ${distance}m';
			case 'geofencing.status.hasMedia': return 'A des médias attachés';
			case 'geofencing.card.radiusInfo': return ({required Object radius}) => 'Rayon de ${radius}m';
			case 'geofencing.card.distanceInfo': return ({required Object distance}) => 'À ${distance}m de distance';
			case 'geofencing.card.recentActivity': return 'Activité Récente';
			case 'geofencing.events.entered': return 'Entré';
			case 'geofencing.events.exited': return 'Sorti';
			case 'geofencing.events.dwelling': return 'En séjour';
			case 'geofencing.description.active': return 'La géofence déclenchera des notifications';
			case 'geofencing.description.inactive': return 'La géofence est configurée mais inactive';
			case 'notifications.title': return 'Notification';
			case 'notifications.localTitle': return 'Notifications Locales';
			case 'notifications.config.title': return 'Paramètres de Notification';
			case 'notifications.config.configure': return 'Configurer la Notification';
			case 'notifications.config.saving': return 'Enregistrement...';
			case 'notifications.config.content': return 'Contenu de la Notification';
			case 'notifications.config.titleLabel': return 'Titre';
			case 'notifications.config.titleHint': return 'ex. Arrivé à l\'emplacement, Alerte de localisation';
			case 'notifications.config.defaultTitle': return 'Alerte de Localisation';
			case 'notifications.config.locationSuffix': return '@ Emplacement';
			case 'notifications.config.preview': return 'Aperçu :';
			case 'notifications.config.image': return 'Image';
			case 'notifications.config.changeImage': return 'Changer l\'Image';
			case 'notifications.config.noImageSelected': return 'Aucune image sélectionnée';
			case 'notifications.config.selectFromGallery': return 'Sélectionner depuis la Galerie';
			case 'notifications.config.selecting': return 'Sélection...';
			case 'notifications.config.imageInfo': return 'Les images seront affichées dans les notifications. Formats pris en charge : JPG, PNG. Taille maximale : 5 Mo.';
			case 'notifications.config.permissions': return 'Autorisations';
			case 'notifications.config.testNotification': return 'Tester la Notification';
			case 'notifications.status.loading': return 'Chargement...';
			case 'notifications.status.error': return 'Une erreur s\'est produite';
			case 'notifications.status.disabled': return 'Notifications désactivées';
			case 'notifications.status.permissionsRequired': return 'Autorisations requises';
			case 'notifications.status.enabled': return 'Notifications activées';
			case 'notifications.status.titleFormat': return ({required Object title}) => 'Titre : "${title}"';
			case 'notifications.status.customImage': return 'Image personnalisée : ';
			case 'notifications.status.imageNotSelected': return 'Image : Non sélectionnée';
			case 'notifications.permissions.required': return 'Autorisations de notification requises';
			case 'notifications.permissions.granted': return 'Autorisations de notification accordées';
			case 'notifications.preview.title': return 'Aperçu de Notification';
			case 'notifications.preview.description': return 'Testez comment votre notification apparaîtra lorsqu\'elle sera déclenchée par un événement de géofence.';
			case 'notifications.preview.entryButton': return 'Aperçu d\'Alerte d\'Entrée';
			case 'notifications.preview.exitButton': return 'Aperçu d\'Alerte de Sortie';
			case 'notifications.preview.info': return ({required Object name}) => 'L\'aperçu utilisera la géofence "${name}" et vos paramètres de notification actuels.';
			case 'notifications.preview.noGeofence': return 'Aucune géofence configurée';
			case 'notifications.preview.noGeofenceMessage': return 'Configurez d\'abord une géofence pour prévisualiser les notifications.';
			case 'notifications.display.placeholderTitle': return 'Aucune image configurée';
			case 'notifications.display.placeholderMessage': return 'Configurez une image dans les paramètres de notification';
			case 'notifications.dialogs.unsavedChanges': return 'Modifications Non Enregistrées';
			case 'notifications.dialogs.unsavedMessage': return 'Vous avez des modifications non enregistrées. Êtes-vous sûr de vouloir annuler ?';
			case 'donations.title': return 'Pot à Pourboires';
			case 'donations.button': return 'Soutenir le Développement';
			case 'donations.header': return 'Si vous appréciez LiveSpotAlert et souhaitez soutenir le développement futur de l\'application, ajouter un pourboire serait d\'une grande aide.';
			case 'donations.processing': return 'Traitement de votre don...';
			case 'donations.success': return 'Merci pour votre généreux don !';
			case 'donations.error': return 'Impossible de charger les options de don';
			case 'donations.products.smallTip': return 'Petit Pourboire';
			case 'donations.products.mediumTip': return 'Pourboire Moyen';
			case 'donations.products.largeTip': return 'Gros Pourboire';
			case 'donations.products.giantTip': return 'Pourboire Géant';
			case 'donations.thankYou.title': return 'Merci !';
			case 'donations.thankYou.message': return 'Votre soutien aide à maintenir cette application gratuite et en amélioration continue. Nous apprécions vraiment votre générosité !';
			case 'defaults.geofence.name': return 'Mon Emplacement';
			case 'defaults.geofence.description': return 'Configurez cette géofence en touchant le bouton d\'édition';
			case 'defaults.notification.title': return 'Alerte de Localisation';
			case 'defaults.location.unknown': return 'Emplacement Inconnu';
			case 'defaults.location.update': return 'Mise à jour d\'Emplacement';
			case 'validation.geofence.idEmpty': return 'L\'ID de géofence ne peut pas être vide';
			case 'validation.geofence.nameEmpty': return 'Le nom de géofence ne peut pas être vide';
			case 'validation.geofence.nameLength': return 'Le nom de géofence ne peut pas dépasser 100 caractères';
			case 'validation.geofence.invalidLatitude': return 'Latitude invalide. Doit être entre -90 et 90';
			case 'validation.geofence.invalidLongitude': return 'Longitude invalide. Doit être entre -180 et 180';
			case 'validation.geofence.radiusPositive': return 'Le rayon doit être supérieur à 0';
			case 'validation.geofence.radiusMax': return 'Le rayon ne peut pas dépasser 10 000 mètres';
			case 'validation.geofence.radiusMin': return 'Le rayon doit être d\'au moins 10 mètres pour une détection fiable';
			case 'validation.geofence.descriptionLength': return 'La description ne peut pas dépasser 500 caractères';
			case 'geofenceEvents.entry.displayName': return 'Entré';
			case 'geofenceEvents.entry.actionDescription': return 'Vous êtes arrivé à';
			case 'geofenceEvents.exit.displayName': return 'Sorti';
			case 'geofenceEvents.exit.actionDescription': return 'Vous avez quitté';
			case 'liveActivities.config.title': return 'Configurer l\'Activité en Direct';
			case 'liveActivities.config.notificationTitle': return 'Titre de la Notification';
			case 'liveActivities.config.titleHint': return 'ex. Vous êtes arrivé !';
			case 'liveActivities.config.notificationImage': return 'Image de la Notification';
			case 'liveActivities.config.addImagePrompt': return 'Touchez pour ajouter une image';
			case 'liveActivities.config.imageUnavailable': return 'Image indisponible';
			default: return null;
		}
	}
}
