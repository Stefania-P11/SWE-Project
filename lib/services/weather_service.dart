import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:dressify_app/services/location_service.dart';

class WeatherService {
  final WeatherFactory wf = WeatherFactory(
    'bd5e378503939ddaee76f12ad7a97608',
    language: Language.ENGLISH,
  );

  // Singleton instance
  static final WeatherService _instance = WeatherService._internal();
  factory WeatherService() => _instance;
  WeatherService._internal();

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
      return _cachedWeather!;
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