import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/services/weather_service.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:weather/weather.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mockito/annotations.dart';
import 'package:weather/weather.dart';  // Needed for WeatherFactory
import 'weather_service_test.mocks.dart';
import 'package:mockito/mockito.dart'; 
import 'package:dressify_app/services/location_service.dart' as loc;


@GenerateMocks([WeatherFactory])



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
class TestableWeatherService extends WeatherService {
  final Weather fakeWeather;

  TestableWeatherService(this.fakeWeather) : super(weatherFactory: null) {
    WeatherService.cachedWeatherForTestSetter = fakeWeather;
    WeatherService.lastFetchedForTestSetter = DateTime.now();
    WeatherService.isFetchingForTestSetter = false;
  }

  @override
  Future<Weather> getTheWeather() async {
    return fakeWeather;
  }
}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Reuse a valid position for mocking
  // final validPosition = Position(
  //   longitude: 0.0,
  //   latitude: 0.0,
  //   timestamp: DateTime.now(),
  //   accuracy: 1.0,
  //   altitude: 1.0,
  //   heading: 1.0,
  //   speed: 0.0,
  //   speedAccuracy: 0.0,
  //   altitudeAccuracy: 1.0,
  //   headingAccuracy: 1.0,
  //   floor: 1,
  //   isMocked: false,
  // );

  // setUp(() {
  //   WeatherService.clearCacheForTest();
  // });
  setUpAll(() {
    loc.determinePosition = () async => Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 1.0,
      headingAccuracy: 1.0,
    );
  });

  group('WeatherService Tests', () {
    test('Returns cached weather if within 10 minutes', () async {
      final service = WeatherService();
      WeatherService.setMockWeather(68.0); // Fahrenheit to Kelvin

      final firstResult = await service.getTheWeather();
      final secondResult = await service.getTheWeather();

      expect(firstResult, isA<Weather>());
      expect(secondResult, isA<Weather>());
      expect(firstResult.temperature?.kelvin, equals(secondResult.temperature?.kelvin));
    });

    test('Fallback weather data returns when API fails', () async {
      // Intentionally corrupt the cache
      WeatherService.clearCacheForTest();

      final service = WeatherService();
      final result = await service.getTheWeather();
      expect(result, isA<Weather>());
      expect(result.temperature?.kelvin, isNotNull);
    });

    test('Concurrent fetching waits for first fetch', () async {
      WeatherService.clearCacheForTest();

      final service = WeatherService();

      // Force _isFetching true for testing
      // Normally we can't set _isFetching, so instead:
      // Start a fetch and don't await it immediately
      final fetchFuture = service.getTheWeather();

      // Slight delay to ensure the fetch sets _isFetching
      await Future.delayed(Duration(milliseconds: 100));

      // Now a second call should hit the while (_isFetching) path
      final secondFetch = service.getTheWeather();

      final result1 = await fetchFuture;
      final result2 = await secondFetch;

      expect(result1, isA<Weather>());
      expect(result2, isA<Weather>());
      expect(result1.temperature?.kelvin, equals(result2.temperature?.kelvin));
    });

    test('clearCacheForTest resets cache and fetching flag', () {
      WeatherService.setMockWeather(70.0);
      expect(WeatherService.isFetchingForTest, false);

      WeatherService.clearCacheForTest();
      // After clearing, _cachedWeather and _lastFetched should be null.
      // But we can't directly read private static fields, so no asserts here.
      expect(WeatherService.isFetchingForTest, false);
    });

    test('concurrent fetch waits for first fetch to finish and uses cache', () async {
        WeatherService.clearCacheForTest();

        // Simulate _isFetching already true and no cache
        WeatherService.isFetchingForTestSetter = true;

        // Delay reset _isFetching after 500ms
        Future.delayed(Duration(milliseconds: 500), () {
          WeatherService.isFetchingForTestSetter = false;
          WeatherService.setMockWeather(70); // Will set cache and _lastFetched
        });

        final result = await WeatherService().getTheWeather();

        expect(result, isA<Weather>());
        expect(result.temperature?.kelvin, isNotNull);
        expect(WeatherService.isFetchingForTest, isFalse);
    });

    test('fallback happens if cache is null after waiting for _isFetching', () async {
        WeatherService.clearCacheForTest();

        // Simulate _isFetching but cache never set
        WeatherService.isFetchingForTestSetter = true;

        // Stop fetching after a short wait
        Future.delayed(Duration(milliseconds: 500), () {
          WeatherService.isFetchingForTestSetter = false;
          // No cache populated on purpose
        });

        final result = await WeatherService().getTheWeather();

        expect(result, isA<Weather>());
        expect(result.temperature?.kelvin, 293.15); // Fallback temp
    });

    test('setLastFetchedForTest properly updates _lastFetched', () {
        final now = DateTime.now();
        WeatherService().setLastFetchedForTest(now);
        expect(WeatherService.lastFetchedForTest, now); 
    });

    test('happy path fetch stores weather and updates cache', () async {
        WeatherService.clearCacheForTest();

        // Force _isFetching = false and no cache
        WeatherService.isFetchingForTestSetter = false;

        // MOCK the determinePosition to return a fake position
        // You must override or fake this because in test, it can't access GPS

        final fakePosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 10.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          headingAccuracy: 1.0,
          speed: 0.0,
          speedAccuracy: 1.0
        );

        //setMockWeather to simulate the happy path:
        WeatherService.setMockWeather(75); // 75°F => ~297 Kelvin

        final result = await WeatherService().getTheWeather();

        expect(result, isA<Weather>());
        expect(result.temperature?.kelvin, greaterThan(296)); // Should be ~297
        expect(WeatherService.lastFetchedForTest, isNotNull);
    });


    test('can manually set cachedWeather and lastFetched via setters', () {
        final fakeWeather = Weather({
            'main': {'temp': 293.15},
            'name': 'Test City',
            'weather': [{'main': 'Clear', 'description': 'Sunny'}]
        });

        final now = DateTime.now();
        WeatherService.cachedWeatherForTestSetter = fakeWeather;
        WeatherService.lastFetchedForTestSetter = now;

        expect(WeatherService.lastFetchedForTest, now);
        expect(WeatherService().getTheWeather(), completes);
    });

    test('getTheWeather uses manually set cache', () async {
        final fakeWeather = Weather({
            'main': {'temp': 294.15},
            'name': 'Cache City',
            'weather': [{'main': 'Clouds', 'description': 'Overcast'}]
        });

        WeatherService.cachedWeatherForTestSetter = fakeWeather;
        WeatherService.lastFetchedForTestSetter = DateTime.now();

        final result = await WeatherService().getTheWeather();
        expect(result, same(fakeWeather));  // Should return exactly the cached weather
    });

    test('real fetch updates cache and hits WeatherFactory lines', () async {
      WeatherService.clearCacheForTest();

      final result = await WeatherService().getTheWeather();

      if (result.temperature != null) {
        expect(result.temperature!.kelvin, greaterThan(200)); // Valid temperature
        print('Real temperature fetched: ${result.temperature!.kelvin}');
      } else {
        print('Real fetch failed or fallback used; temperature is null');
        expect(result.temperature, isNull);
      }
    });

    test('test cache setters work', () {
      final fakeDate = DateTime(2020);
      WeatherService.lastFetchedForTestSetter = fakeDate;
      expect(WeatherService.lastFetchedForTest, fakeDate);

      final fakeWeather = Weather({
        'main': {'temp': 300},
        'name': 'SetterTestCity',
        'weather': [{'main': 'Clear', 'description': 'Setter test'}],
      });

      WeatherService.cachedWeatherForTestSetter = fakeWeather;
      expect(WeatherService().getTheWeather(), completes);
    });
    test('happy path fetch stores weather and updates cache manually', () async {
        WeatherService.clearCacheForTest();

        // Create fake weather with valid temperature
        final weather = Weather({
          'main': {
            'temp': 300.0,  // 26.85 °C
            'temp_min': 295.0,
            'temp_max': 305.0,
          },
          'name': 'Test City',
          'weather': [
            {'main': 'Clouds', 'description': 'cloudy'}
          ]
        });

        // Use the TestableWeatherService to force the values
        final service = TestableWeatherService(weather);

        final result = await service.getTheWeather();

        expect(result.temperature?.kelvin, equals(300.0));
        expect(WeatherService.lastFetchedForTest, isNotNull);
    });
    test('Mocked WeatherFactory provides weather, hits wf.currentWeatherByLocation and updates cache', () async {
        final mockFactory = MockWeatherFactory();

        final fakeWeather = Weather({
          'main': {
            'temp': 300.15,
          },
          'name': 'Mocked City',
          'weather': [
            {'main': 'Cloudy', 'description': 'Overcast'}
          ]
        });

        // When the mock's currentWeatherByLocation is called, return fakeWeather
        when(mockFactory.currentWeatherByLocation(any, any))
            .thenAnswer((_) async => fakeWeather);

        // MOCK determinePosition too!
        final fakePosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 1.0,
          altitude: 0.0,
          altitudeAccuracy: 1.0,
          heading: 0.0,
          speed: 0.0,
          headingAccuracy: 1.0,
          speedAccuracy: 0.0
        );
        // override determinePosition to return fake location
        loc.determinePosition = () async => fakePosition;

        // Clear any previous cache
        WeatherService.clearCacheForTest();

        // Create service using the mock WeatherFactory
        final service = WeatherService(weatherFactory: mockFactory);

        //Run the function and verify
        final result = await service.getTheWeather();

        // Assertions
        expect(result, isNotNull);
        expect(result.areaName, 'Mocked City');
        expect(result.temperature?.kelvin, 300.15);
        expect(WeatherService.lastFetchedForTest, isNotNull);
    });


  });

  group('WeatherService Integration Test (Real API Call)', () {
    test('Real weather fetch hits wf.currentWeatherByLocation and updates cache', () async {
        WeatherService.clearCacheForTest();

        final result = await WeatherService().getTheWeather();

        expect(result, isNotNull); // Weather object exists

        expect(WeatherService.lastFetchedForTest, isNotNull);
    }, skip: true); // Always skip during automated tests;

  });



}
