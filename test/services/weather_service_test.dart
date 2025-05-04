import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/services/weather_service.dart';
//import 'package:dressify_app/services/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'package:http/http.dart' as http;
//import 'package:weather/weather.dart';
//import 'surprise_me_service_test.mocks.dart';
//import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
//import 'package:mockito/mockito.dart';
//import 'package:dressify_app/test/services/location_service_test.dart';

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


class FakeHttpClient extends http.BaseClient {
  final Future<http.Response> Function(http.Request) _handler;
  FakeHttpClient(this._handler);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _handler(request as http.Request);
    return http.StreamedResponse(
      Stream.value(response.bodyBytes),
      response.statusCode,
      headers: response.headers,
    );
  }
}


//@override
//Future<bool> isLocationServiceEnabled() async => true;
/*
class _BrokenWeatherService extends WeatherService {
  _BrokenWeatherService() : super.forTests(); 

  @override
  Future<Weather> getTheWeather() async {
    throw Exception('Simulated weather fetch failure');
  }
}
*/

@GenerateMocks([http.Client])
void main() {
  
  //IntegrationTestWidgetsFlutterBinding.ensureInitialized();
	
	group('getTheWeather', () {
		test('cache test', () async {
			TestWidgetsFlutterBinding.ensureInitialized();
			final testService = WeatherService();
			
      final weather = await testService.getTheWeather();
			final weather2 = await testService.getTheWeather();
      expect(weather.temperature?.kelvin, equals(weather2.temperature?.kelvin));
    	});
	});
	
	
	group('Fallback for failure', () {
    test('thing breaks', () async {
			TestWidgetsFlutterBinding.ensureInitialized();
			final brokenService = WeatherService();
			final brokeWeather = await brokenService.getTheWeather();
			expect(brokeWeather.temperature?.kelvin, equals(293.15));
			expect(brokeWeather.tempMin?.kelvin, equals(289.82));
			expect(brokeWeather.tempMax?.kelvin, equals(295.37));
		});
	});
	//DateTime
	/*
	group('WeatherFactory API call', () {
    test('API call is unsuccessful', () async {
		
			final weather = await WeatherService().getTheWeather();
			expect(weather.temperature?.kelvin, equals(293.15));
			expect(weather.tempMin?.kelvin, equals(289.82));
			expect(weather.tempMax?.kelvin, equals(295.37));
		});
	
	
	});
	*/
	
	/*
	group('determinePosition call', () {
	
	
	
	
	
	
	});
	*/
}