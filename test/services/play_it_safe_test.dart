import 'package:flutter_test/flutter_test.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/services/play_it_safe.dart';
import 'package:dressify_app/services/weather_service.dart';
import 'package:weather/weather.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized(); 

  // Clear state before each test
  setUp(() {
    Item.itemList.clear();
    Outfit.outfitList.clear();
  });

  group('PlayItSafeService', () {
    test('should return a valid outfit matching warm weather', () async {
      WeatherService.setMockWeather(75.0); // Mock warm weather

      // Arrange
      final top = Item(
        category: 'Top',
        id: 1,
        label: 'T-shirt',
        timesWorn: 5,
        url: 'url',
        weather: ['Warm'],
      );
      final bottom = Item(
        category: 'Bottom',
        id: 2,
        label: 'Shorts',
        timesWorn: 3,
        url: 'url',
        weather: ['Warm'],
      );
      final shoes = Item(
        category: 'Shoes',
        id: 3,
        label: 'Sneakers',
        timesWorn: 7,
        url: 'url',
        weather: ['Warm'],
      );
      Item.itemList.addAll([top, bottom, shoes]);

      final outfit = Outfit(
        id: 1,
        label: 'Casual Outfit',
        topItem: top,
        bottomItem: bottom,
        shoeItem: shoes,
        timesWorn: 0,
        weather: ['Warm'],
      );
      Outfit.outfitList.add(outfit);

      // Act
      final safeOutfit = await PlayItSafeService.getSafeOutfit();

      // Assert
      expect(safeOutfit, isNotNull);
      expect(safeOutfit?.topItem.label, 'T-shirt');
      expect(safeOutfit?.bottomItem.label, 'Shorts');
      expect(safeOutfit?.shoeItem.label, 'Sneakers');
    });

    test('should return null if no outfits match the weather', () async {
      WeatherService.setMockWeather(35.0); // Mock cold weather

      // Arrange
      final top = Item(
        category: 'Top',
        id: 1,
        label: 'Tank Top',
        timesWorn: 5,
        url: 'url',
        weather: ['Hot'],
      );
      final bottom = Item(
        category: 'Bottom',
        id: 2,
        label: 'Swim Shorts',
        timesWorn: 3,
        url: 'url',
        weather: ['Hot'],
      );
      final shoes = Item(
        category: 'Shoes',
        id: 3,
        label: 'Flip Flops',
        timesWorn: 7,
        url: 'url',
        weather: ['Hot'],
      );
      Item.itemList.addAll([top, bottom, shoes]);

      final outfit = Outfit(
        id: 1,
        label: 'Hot Outfit',
        topItem: top,
        bottomItem: bottom,
        shoeItem: shoes,
        timesWorn: 0,
        weather: ['Hot'],
      );
      Outfit.outfitList.add(outfit);

      // Act
      final safeOutfit = await PlayItSafeService.getSafeOutfit();

      // Assert
      expect(safeOutfit, isNull);
    });

    test('should return null if an outfit is missing items', () async {
      WeatherService.setMockWeather(75.0); // Mock warm weather

      // Arrange
      final top = Item(
        category: 'Top',
        id: 1,
        label: 'T-shirt',
        timesWorn: 5,
        url: 'url',
        weather: ['Warm'],
      );
      Item.itemList.add(top); // Only top is available, bottom and shoes missing

      final outfit = Outfit(
        id: 1,
        label: 'Incomplete Outfit',
        topItem: top,
        bottomItem: Item(
          category: 'Bottom',
          id: 2,
          label: 'Missing Bottom',
          timesWorn: 0,
          url: 'url',
          weather: ['Warm'],
        ),
        shoeItem: Item(
          category: 'Shoes',
          id: 3,
          label: 'Missing Shoes',
          timesWorn: 0,
          url: 'url',
          weather: ['Warm'],
        ),
        timesWorn: 0,
        weather: ['Warm'],
      );
      Outfit.outfitList.add(outfit);

      // Act
      final safeOutfit = await PlayItSafeService.getSafeOutfit();

      // Assert
      expect(safeOutfit, isNull);
    });

    test('should handle weather service failure gracefully', () async {
     // Arrange: Simulate a WeatherService error by using a fake class
    final failingWeatherService = _FailingWeatherService();

      // Act
      final safeOutfit = await PlayItSafeService.getSafeOutfit(weatherService: failingWeatherService);

      // Assert
      expect(safeOutfit, isNull);
    });

    
  });
  
}

class _FailingWeatherService extends WeatherService {
  _FailingWeatherService() : super.forTests(); 

  @override
  Future<Weather> getTheWeather() async {
    throw Exception('Simulated weather fetch failure');
  }
}


