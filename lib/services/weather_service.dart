import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';
import 'package:dressify_app/services/location_service.dart';


class WeatherService {
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
}