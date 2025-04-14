import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:dressify_app/services/location_service.dart';

class WeatherService {
  final WeatherFactory wf = WeatherFactory(
    'bd5e378503939ddaee76f12ad7a97608',
    language: Language.ENGLISH,
  );

  // ADD THESE STATIC VARIABLES
  static Weather? _cachedWeather;
  static DateTime? _lastFetched;

  Future<Weather> getTheWeather() async {
    // Use cached weather if it's less than 10 minutes old
    if (_cachedWeather != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < const Duration(minutes: 10)) {
      print('Returning cached weather data');
      return _cachedWeather!;
    }

    try {
      Position location = await determinePosition();

      Weather currentWeather = await wf.currentWeatherByLocation(
        location.latitude,
        location.longitude,
      );

      // Save to cache
      _cachedWeather = currentWeather;
      _lastFetched = DateTime.now();
      print('Fetched new weather data from API');

      return currentWeather;
    } catch (e) {
      print(' Weather fetch failed: $e');

      // Fallback to mocked response using fake JSON (Kelvin = °F + 273.15)
      return Weather({
        'main': {
          'temp': 293.15,       // ≈ 68°F
          'temp_min': 289.82,   // ≈ 62°F
          'temp_max': 295.37    // ≈ 72°F
        },
        'name': 'Fallback City',
        'weather': [
          {'main': 'Clear', 'description': 'Sunny'}
        ]
      });
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