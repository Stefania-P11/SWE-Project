import 'package:weather/weather.dart';


class WeatherService {
	Weather getTheWeather() {
		WeatherFactory wf = new WeatherFactory("bd5e378503939ddaee76f12ad7a97608");
		Weather current_weather = await wf.currentWeatherByLocation(determinePosition());
		return current_weather;
	}
	
}