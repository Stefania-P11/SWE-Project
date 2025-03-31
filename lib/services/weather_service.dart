import 'package:weather/weather.dart';
import 'package:dressify_app/services/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:geolocator_apple/geolocator_apple.dart';

Future<Weather> getTheWeather() async {
		WeatherFactory wf = new WeatherFactory("bd5e378503939ddaee76f12ad7a97608");
		Position location = await determinePosition();
		Weather current_weather = await wf.currentWeatherByLocation(location.latitude, location.longitude);
		return current_weather;
}