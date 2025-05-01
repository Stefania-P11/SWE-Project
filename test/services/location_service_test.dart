import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:dressify_app/services/location_service.dart';
import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride, TargetPlatform;

/// A mock platform that overrides GeolocatorPlatform methods.
class MockPlatform extends GeolocatorPlatform {
  final bool serviceEnabled;
  final LocationPermission permission;
  final Position position;

  MockPlatform({
    required this.serviceEnabled,
    required this.permission,
    required this.position,
  });

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async => position;
}

/// Platform stub that simulates initial denied then granted on request.
class TwoStepPlatform extends GeolocatorPlatform {
  final bool serviceEnabled;
  final LocationPermission initialPermission;
  final LocationPermission requestPermissionReturn;
  final Position position;

  TwoStepPlatform({
    required this.serviceEnabled,
    required this.initialPermission,
    required this.requestPermissionReturn,
    required this.position,
  });

  bool _requested = false;

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async {
    if (!_requested) return initialPermission;
    return requestPermissionReturn;
  }

  @override
  Future<LocationPermission> requestPermission() async {
    _requested = true;
    return requestPermissionReturn;
  }

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async => position;
}

/// Platform stub that records the LocationSettings passed.
class RecordingPlatform extends GeolocatorPlatform {
  final bool serviceEnabled;
  final LocationPermission permission;
  final Position position;
  LocationSettings? passedSettings;

  RecordingPlatform({
    required this.serviceEnabled,
    required this.permission,
    required this.position,
  });

  @override
  Future<bool> isLocationServiceEnabled() async => serviceEnabled;

  @override
  Future<LocationPermission> checkPermission() async => permission;

  @override
  Future<LocationPermission> requestPermission() async => permission;

  @override
  Future<Position> getCurrentPosition({LocationSettings? locationSettings}) async {
    passedSettings = locationSettings;
    return position;
  }
}

/// Helper to create a Position with all required fields.
Position makePosition(double lat, double lon) => Position(
      latitude: lat,
      longitude: lon,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

void main() {
  group('getLocationSettings', () {
    test('returns LocationSettings with correct defaults', () {
      final settings = getLocationSettings();
      expect(settings.accuracy, equals(LocationAccuracy.high));
      expect(settings.distanceFilter, equals(100));
    });

    test('AndroidSettings fields are correct', () {
      final settings = AndroidSettings(
        accuracy: LocationAccuracy.low,
        distanceFilter: 50,
        forceLocationManager: false,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: 'Text',
          notificationTitle: 'Title',
          enableWakeLock: false,
        ),
      );
      expect(settings.accuracy, equals(LocationAccuracy.low));
      expect(settings.distanceFilter, equals(50));
      expect(settings.forceLocationManager, isFalse);
      expect(settings.intervalDuration, equals(const Duration(seconds: 5)));
      expect(settings.foregroundNotificationConfig!.notificationTitle, equals('Title'));
    });

    test('AppleSettings fields are correct', () {
      final settings = AppleSettings(
        accuracy: LocationAccuracy.medium,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 75,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
      expect(settings.accuracy, equals(LocationAccuracy.medium));
      expect(settings.activityType, equals(ActivityType.automotiveNavigation));
      expect(settings.distanceFilter, equals(75));
      expect(settings.pauseLocationUpdatesAutomatically, isFalse);
      expect(settings.showBackgroundLocationIndicator, isTrue);
    });

    test('WebSettings fields are correct', () {
      final settings = WebSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 150,
        maximumAge: const Duration(minutes: 1),
      );
      expect(settings.accuracy, equals(LocationAccuracy.high));
      expect(settings.distanceFilter, equals(150));
      expect(settings.maximumAge, equals(const Duration(minutes: 1)));
    });

    test('AppleSettings branch override', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      final settings = getLocationSettings();
      expect(settings, isA<AppleSettings>());
      final apple = settings as AppleSettings;
      expect(apple.pauseLocationUpdatesAutomatically, isTrue);
      expect(apple.showBackgroundLocationIndicator, isFalse);
      debugDefaultTargetPlatformOverride = null;
    });

    test('WebSettings branch via override', () {
      final settings = getLocationSettings(
        overridePlatform: TargetPlatform.fuchsia,
        overrideIsWeb: true,
      );
      expect(settings, isA<WebSettings>());
      expect((settings as WebSettings).maximumAge, equals(Duration(minutes: 5)));
    });

    test('Fallback branch via override', () {
      final settings = getLocationSettings(
        overridePlatform: TargetPlatform.linux,
        overrideIsWeb: false,
      );
      expect(settings, isA<LocationSettings>());
      expect(settings.accuracy, equals(LocationAccuracy.high));
    });
  });

  group('determinePosition', () {
    test('throws when services disabled', () async {
      final mockPlatform = MockPlatform(
        serviceEnabled: false,
        permission: LocationPermission.always,
        position: makePosition(0, 0),
      );
      GeolocatorPlatform.instance = mockPlatform;

      await expectLater(
        determinePosition(),
        throwsA(equals('Location services are disabled.')),
      );
    });

    test('throws when permission denied twice', () async {
      final mockPlatform = MockPlatform(
        serviceEnabled: true,
        permission: LocationPermission.denied,
        position: makePosition(0, 0),
      );
      GeolocatorPlatform.instance = mockPlatform;

      await expectLater(
        determinePosition(),
        throwsA(equals('Location permissions are denied')),
      );
    });

    test('throws when permission deniedForever', () async {
      final mockPlatform = MockPlatform(
        serviceEnabled: true,
        permission: LocationPermission.deniedForever,
        position: makePosition(0, 0),
      );
      GeolocatorPlatform.instance = mockPlatform;

      await expectLater(
        determinePosition(),
        throwsA(equals(
          'Location permissions are permanently denied, we cannot request permissions.'
        )),
      );
    });

    test('initially denied then granted returns Position', () async {
      final expected = makePosition(3.21, 4.56);
      final twoStep = TwoStepPlatform(
        serviceEnabled: true,
        initialPermission: LocationPermission.denied,
        requestPermissionReturn: LocationPermission.whileInUse,
        position: expected,
      );
      GeolocatorPlatform.instance = twoStep;

      final result = await determinePosition();
      expect(result.latitude, equals(expected.latitude));
      expect(result.longitude, equals(expected.longitude));
    });

    test('passes correct LocationSettings to getCurrentPosition', () async {
      final expected = makePosition(7.89, 0.12);
      final recorder = RecordingPlatform(
        serviceEnabled: true,
        permission: LocationPermission.always,
        position: expected,
      );
      GeolocatorPlatform.instance = recorder;

      final result = await determinePosition();
      expect(result, equals(expected));

      final expectedSettings = getLocationSettings();
      expect(recorder.passedSettings, isA<LocationSettings>());
      expect(
        recorder.passedSettings.runtimeType,
        equals(expectedSettings.runtimeType),
      );
    });

    test('returns Position when service enabled and permission granted', () async {
      final expected = makePosition(12.34, 56.78);
      final mockPlatform = MockPlatform(
        serviceEnabled: true,
        permission: LocationPermission.whileInUse,
        position: expected,
      );
      GeolocatorPlatform.instance = mockPlatform;

      final result = await determinePosition();
      expect(result.latitude, equals(expected.latitude));
      expect(result.longitude, equals(expected.longitude));
    });
  });

  group('makePosition', () {
    test('sets latitude correctly', () {
      final pos = makePosition(1.23, 4.56);
      expect(pos.latitude, equals(1.23));
    });

    test('sets longitude correctly', () {
      final pos = makePosition(7.89, 0.12);
      expect(pos.longitude, equals(0.12));
    });

    test('initializes other fields to 0.0', () {
      final pos = makePosition(0.0, 0.0);
      expect(pos.accuracy, equals(0.0));
      expect(pos.altitude, equals(0.0));
      expect(pos.speed, equals(0.0));
    });
  });
}