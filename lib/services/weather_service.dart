import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:dressify_app/services/location_service.dart';

class WeatherService {

  final WeatherFactory wf;

  WeatherService({WeatherFactory? weatherFactory})
      : wf = weatherFactory ??
            WeatherFactory(
              'bd5e378503939ddaee76f12ad7a97608',
              language: Language.ENGLISH,
            );

  // final WeatherFactory wf = WeatherFactory(
  //   'bd5e378503939ddaee76f12ad7a97608',
  //   language: Language.ENGLISH,
  // );

  // Singleton instance
  // static final WeatherService _instance = WeatherService._internal();
  // factory WeatherService() => _instance;
  // WeatherService._internal();
  // WeatherService.forTests(); // For testing only

  // Static cache shared across the app
  static Weather? _cachedWeather;
  static DateTime? _lastFetched;
  static bool _isFetching = false;

  Future<Weather> getTheWeather() async {
    // Return cached weather if within 10 minutes
    if (_cachedWeather != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 10)) {
      print('[WeatherService] Returning cached weather data');
      return _cachedWeather!;
    }

    // Prevent multiple concurrent fetches
    if (_isFetching) {
      print('[WeatherService] Already fetching, waiting for result...');
      while (_isFetching) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
      //return _cachedWeather!;
      // Re-check if cache was properly populated
      if (_cachedWeather != null) {
        return _cachedWeather!;
      } else {
        print('[WeatherService] Cache still null after waiting, using fallback.');
        return Weather({
          'main': {
            'temp': 293.15,
            'temp_min': 289.82,
            'temp_max': 295.37,
          },
          'name': 'Fallback City',
          'weather': [
            {'main': 'Clear', 'description': 'Sunny'}
          ]
        });
      }
    }

    try {
      _isFetching = true;
      print('[WeatherService] Fetching new weather data from API...');

      Position location = await determinePosition();

      Weather currentWeather = await wf.currentWeatherByLocation(
        location.latitude,
        location.longitude,
      );

      // Save to cache
      _cachedWeather = currentWeather;
      _lastFetched = DateTime.now();
      print('[WeatherService] Weather fetched and cached.');

      return currentWeather;
    } catch (e) {
      print('[WeatherService] Weather fetch failed: $e');

      // Fallback mock weather data (in Kelvin)
      return Weather({
        'main': {
          'temp': 293.15,
          'temp_min': 289.82,
          'temp_max': 295.37,
        },
        'name': 'Fallback City',
        'weather': [
          {'main': 'Clear', 'description': 'Sunny'}
        ]
      });
    } finally {
      _isFetching = false;
    }
  }

  // Testing-only helper to mock weather easily
static void setMockWeather(double tempFahrenheit) {
  _cachedWeather = Weather({
    'main': {
      'temp': ((tempFahrenheit - 32) * 5 / 9) + 273.15, // Fahrenheit to Kelvin
    },
    'name': 'Mock City',
    'weather': [
      {'main': 'Clear', 'description': 'Clear sky'}
    ]
  });
  _lastFetched = DateTime.now();
}

  //helper for testing
  void setLastFetchedForTest(DateTime time) {
  _lastFetched = time;
  }
  // TESTING ONLY HELPERS
  static void clearCacheForTest() { 
    _cachedWeather = null;
    _lastFetched = null;
    _isFetching = false;
  }

  
  // SETTERS for testing
  static set isFetchingForTestSetter(bool value) => _isFetching = value;
  static set lastFetchedForTestSetter(DateTime? value) => _lastFetched = value;
  static set cachedWeatherForTestSetter(Weather? value) => _cachedWeather = value;

  // GETTER for testing
  static bool get isFetchingForTest => _isFetching;
  static DateTime? get lastFetchedForTest => _lastFetched;

}


/*class WeatherService {
  final WeatherFactory wf = WeatherFactory('bd5e378503939ddaee76f12ad7a97608', language: Language.ENGLISH);

  Future<Weather> getTheWeather() async {
    WeatherFactory wf = WeatherFactory(
      "bd5e378503939ddaee76f12ad7a97608",
      language: Language.ENGLISH,
    );

    Position location = await determinePosition();
    Weather currentWeather = await wf.currentWeatherByLocation(
      location.latitude,
      location.longitude,
    );
  
    return currentWeather;
  }
}*/