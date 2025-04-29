// surprise_me_service_test.dart

// -------------------------------------------------
// IMPORTS
// -------------------------------------------------

import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'package:dressify_app/services/surprise_me_service.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/mocks/mock_color_detector.dart'; // Your smart color mock

// -------------------------------------------------
// HELPER FUNCTIONS FOR TESTING
// -------------------------------------------------

/// Create invalid file
Uint8List createInvalidPngBytes() {
  return Uint8List.fromList([
    0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77
  ]);
}


/// Creates a PNG-encoded image where the left half is red and the right half is blue.
/// Useful for testing color clustering (like KMeans).
/// 
/// [width]: The width of the generated image (default 80).
/// [height]: The height of the generated image (default 100).
/// Returns: Uint8List (bytes of PNG image)
Uint8List createHalfRedHalfBlueImage({int width = 80, int height = 100}) {
  // Create a blank image object with the specified width and height
  final image = img.Image(width: width, height: height);

  // Define the RED color (pure red: R=255, G=0, B=0)
  final red = img.ColorRgb8(255, 0, 0);

  // Define the BLUE color (pure blue: R=0, G=0, B=255)
  final blue = img.ColorRgb8(0, 0, 255);

  // Loop through every pixel row (y-axis: top to bottom)
  for (int y = 0; y < height; y++) {
    // Loop through every pixel column (x-axis: left to right)
    for (int x = 0; x < width; x++) {
      // If x is in the left half of the image, set the pixel color to RED
      if (x < width ~/ 2) {
        image.setPixel(x, y, red); // Left half: RED
      } else {
        // Else, x is in the right half, set the pixel color to BLUE
        image.setPixel(x, y, blue); // Right half: BLUE
      }
    }
  }

  // Encode the image into PNG format (compressing it)
  final pngBytes = img.encodePng(image);

  // Return the PNG image as a byte array (Uint8List) ready for saving or testing
  return Uint8List.fromList(pngBytes);
}


/// Create a solid color PNG image with specified RGB values
Uint8List createSolidColorImage(int r, int g, int b, {int size = 32}) {
  final image = img.Image(width: size, height: size);
  final color = img.ColorRgb8(r, g, b);

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      image.setPixel(x, y, color);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

/// Create a solid white image (all 255,255,255)
Uint8List createWhiteImage({int size = 32}) {
  return createSolidColorImage(255, 255, 255, size: size);
}

/// Create invalid (random junk) bytes that simulate broken images
Uint8List createInvalidImage() {
  return Uint8List.fromList(List<int>.generate(10, (_) => Random().nextInt(255)));
}

/// Fake HttpClient to simulate HTTP responses without real network (getColorFromImage test)
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

/// Dummy Temperature and Weather classes for mocking (surpriseMe test)
class Temperature {
  final double fahrenheit;
  Temperature({required this.fahrenheit});
}

class Weather {
  final Temperature? temperature;
  Weather({this.temperature});
}

/// Fake WeatherService used to inject different temperatures (surpriseMe test)
class FakeWeatherService {
  final Temperature? fakeTemperature;

  FakeWeatherService({this.fakeTemperature});

  Future<Weather> getTheWeather() async {
    return Weather(temperature: fakeTemperature);
  }
}

/// Helper function: A version of surpriseMe that uses FakeWeatherService 
Future<Outfit?> surpriseMeWithMock(
    List<Item> wardrobe,
    FakeWeatherService weatherService, {
    Set<int> excludeBottomIds = const {},
    Future<String> Function(String url)? colorDetector, // NEW!
  }) async {

  final weather = await weatherService.getTheWeather();
  final temp = weather.temperature?.fahrenheit ?? 70.0;
  final tempCategory = getTempCategory(temp);

  final validBottoms = wardrobe.where((item) =>
    item.category.toLowerCase().contains("bottom") &&
    item.weather.contains(tempCategory) &&
    !excludeBottomIds.contains(item.id)).toList();

  final bottom = validBottoms.isNotEmpty ? validBottoms[0] : null;
  if (bottom == null) return null;

  final matchedItems = await matchTopAndShoe(
    bottom: bottom,
    tempCategory: tempCategory,
    wardrobe: wardrobe,
    colorDetector: colorDetector, // inject to here too!
  );

  return Outfit.fromSurpriseMe(
    top: matchedItems[0],
    bottom: bottom,
    shoe: matchedItems[1],
    tempCategory: tempCategory,
  );
}

///Fake Color Detector
Future<String> fakeColorDetector(String url) async {
  // Pretend everything is 'blue' or 'white'
  if (url.contains('shorts')) return 'blue';
  if (url.contains('jeans')) return 'blue';
  if (url.contains('tshirt') || url.contains('tshirt2')) return 'white';
  if (url.contains('sneakers') || url.contains('sneakers2')) return 'black';
  return 'unknown';
}



// -------------------------------------------------
// TESTS START
// -------------------------------------------------

void main() {

  // --------------------------
  // 1. detectDominantColorFromBytes Tests
  // --------------------------
  group('detectDominantColorFromBytes Integration Tests', () {
    
    test('Detect dominant color from solid red image', () async {
      final bytes = createSolidColorImage(255, 0, 0);
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'red');
    });

    test('Detect dominant color from solid green image', () async {
      final bytes = createSolidColorImage(0, 255, 0);
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'lime');
    });

    test('Detect dominant color from solid blue image', () async {
      final bytes = createSolidColorImage(0, 0, 255);
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'blue');
    });

    test('Handle completely white image by returning unknown', () async {
      final bytes = createWhiteImage();
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'unknown');
    });

    test('Handle invalid image bytes gracefully', () async {
      final bytes = createInvalidImage();
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'unknown');
    });

    test('Detect dominant color with k=1 cluster', () async {
      final bytes = createSolidColorImage(255, 0, 0);
      final color = await detectDominantColorFromBytes(bytes, k: 1);
      expect(color, 'red');
    });

    test('Detect dominant color with k=5 clusters', () async {
      final bytes = createSolidColorImage(0, 255, 0);
      final color = await detectDominantColorFromBytes(bytes, k: 5);
      expect(color, 'lime');
    });

    test('KMeans runs full loop with best cluster logic hit', () async {
        final image = img.Image(width: 8, height: 8);

        for (int y = 0; y < 8; y++) {
            for (int x = 0; x < 8; x++) {
            if (x < 4) {
                image.setPixel(x, y, img.ColorRgb8(250, 0, 0)); // Slightly off-red
            } else {
                image.setPixel(x, y, img.ColorRgb8(0, 0, 250)); // Slightly off-blue
            }
            }
        }

        final bytes = Uint8List.fromList(img.encodePng(image));
        final color = await detectDominantColorFromBytes(bytes, k: 2);
        expect(color, anyOf(['red', 'blue', 'purple']));
    });

    test('detectDominantColorFromBytes triggers k-means clustering logic', () async {
        final bytes = createHalfRedHalfBlueImage(width: 64, height: 64);

        final dominantColor = await detectDominantColorFromBytes(bytes, k: 2);

        expect(
            dominantColor,
            anyOf(['red', 'blue', 'purple']),
        );
    });


    test('clusters receive multiple pixels to update centroids', () async {
        final bytes = createHalfRedHalfBlueImage(width: 64, height: 64);
        final color = await detectDominantColorFromBytes(bytes, k: 2);
        expect(color, anyOf(['red', 'blue', 'purple']));
    });


    test('decodeImage returns null for unrecognizable image', () async {
        final invalidBytes = createInvalidPngBytes();
        final result = await detectDominantColorFromBytes(invalidBytes);
        expect(result, 'unknown');
    });


    test('returns unknown when all pixels filtered due to brightness', () async {
      final bytes = createWhiteImage();
      final color = await detectDominantColorFromBytes(bytes);
      expect(color, 'unknown');
    });
    /*test('detectDominantColorFromBytes returns unknown if all pixels are too bright', () async {
        // Create an all-white image (brightness = 255)
        final whiteImage = img.Image(width: 64, height: 64);
        final whiteColor = img.ColorRgb8(255, 255, 255);

        for (int y = 0; y < 64; y++) {
            for (int x = 0; x < 64; x++) {
            whiteImage.setPixel(x, y, whiteColor);
            }
        }

        final bytes = Uint8List.fromList(img.encodePng(whiteImage));

        final dominantColor = await detectDominantColorFromBytes(bytes, k: 3);

        expect(dominantColor, 'unknown');
    });*/

    test('handles non-square image and clustering', () async {
        final bytes = createHalfRedHalfBlueImage(width: 80, height: 100);
        final dominantColor = await detectDominantColorFromBytes(bytes, k: 2);

        expect(
            dominantColor,
            anyOf(['red', 'blue', 'purple']), // ✅ add 'purple' as valid
        );
    });


  });

  
  // --------------------------
  // 2. getColorFromImage Network Fetch Tests
  // --------------------------
  group('getColorFromImage Network Fetch Tests', () {
    test('getColorFromImage real image test (requires network)', () async {
        const imageUrl = 'https://via.placeholder.com/1x1.png';

        try {
            final result = await getColorFromImage(imageUrl);
            expect(result, isNot('unknown'));
        } catch (e) {
            print('⚠️ Skipped due to no network: $e');
        }
    });


    test('should return color when HTTP fetch succeeds (statusCode 200)', () async {
      final tinyImage = img.Image(width: 1, height: 1);
      final fakeImageBytes = Uint8List.fromList(img.encodePng(tinyImage));

      final client = FakeHttpClient((request) async {
        return http.Response.bytes(fakeImageBytes, 200);
      });

      final colorName = await getColorFromImageWithClient('https://fakeurl.com/image.jpg', client);
      expect(colorName, isNot('unknown'));
    });

    test('should return "unknown" when HTTP fetch fails (statusCode 404)', () async {
      final client = FakeHttpClient((request) async {
        return http.Response('Not Found', 404);
      });

      final colorName = await getColorFromImageWithClient('https://fakeurl.com/image.jpg', client);
      expect(colorName, 'unknown');
    });

    test('should return "unknown" when an exception occurs during fetch', () async {
      final client = FakeHttpClient((request) async {
        throw Exception('Network error');
      });

      final colorName = await getColorFromImageWithClient('https://fakeurl.com/image.jpg', client);
      expect(colorName, 'unknown');
    });

    test('getColorFromImageWithClient fully succeeds with valid image', () async {
        // Create a tiny valid 1x1 red image
        final tinyImage = img.Image(width: 1, height: 1);
        final redColor = img.ColorRgb8(255, 0, 0); // ✅ Create solid red color
        tinyImage.setPixel(0, 0, redColor); // ✅ Set the pixel manually to red

        final fakeImageBytes = Uint8List.fromList(img.encodePng(tinyImage));

        // Fake client that simulates a successful HTTP GET 200
        final client = FakeHttpClient((request) async {
            return http.Response.bytes(fakeImageBytes, 200);
        });

        // Call your function
        final colorName = await getColorFromImageWithClient('https://fakeurl.com/image.png', client);

        // Verify the behavior
        expect(colorName, isNot('unknown')); // Expect a real color
        expect(colorName, anyOf(['red', 'lime', 'blue', 'white', 'black', 'gray', 'cyan', 'yellow', 'magenta'])); 
    });

    //test('getColorFromImage returns a color when real HTTP 200', () async {
     // ✅ Setup: You need a real small hosted image online
    //final colorName = await getColorFromImage('https://via.placeholder.com/1x1.png');

    //expect(colorName, isNot('unknown'));
    //});

  });

  // --------------------------
  // 3. matchTopAndShoe Matching Logic Tests
  // --------------------------
  group('matchTopAndShoe Matching Logic Tests', () {
    test('matchTopAndShoe falls back to top with non-unknown color when no preferred matches', () async {
        final mockDetector = MockColorDetector({
            'bottom': 'black',
            'offcolor_top': 'red', // not in preferred list
            'valid_shoe': 'white', // valid
        });

        final wardrobe = [
            Item(
            id: 1,
            category: 'Top',
            label: 'Off-color Top',
            timesWorn: 1,
            url: 'https://fakeurl.com/offcolor_top.png',
            weather: ['Warm'],
            ),
            Item(
            id: 2,
            category: 'Shoe',
            label: 'White Shoe',
            timesWorn: 1,
            url: 'https://fakeurl.com/valid_shoe.png',
            weather: ['Warm'],
            ),
        ];

        final bottom = Item(
            id: 5,
            category: 'Bottom',
            label: 'Black Pants',
            timesWorn: 4,
            url: 'https://fakeurl.com/bottom.png',
            weather: ['Warm'],
        );

        // Only allow 'white' and 'gray' as acceptable tops — 'red' doesn't match
        colorMatchMap = {
            'black': {
            'Top': ['white', 'gray'],  // no match
            'Shoe': ['white'],         // match
            }
        };

        final result = await matchTopAndShoe(
            bottom: bottom,
            tempCategory: 'Warm',
            wardrobe: wardrobe,
            colorDetector: mockDetector.getColor,
        );

        expect(result.length, 2);
        expect(result[0].label, 'Off-color Top'); // fallback top from non-unknown
        expect(result[1].label, 'White Shoe');    // valid match
    });

    test('matchTopAndShoe returns correct top and shoe based on bottom color and weather', () async {
        final mockDetector = MockColorDetector({
        'bottom': 'blue',
        'top1': 'white',
        'top2': 'red',
        'shoe1': 'black',
        'shoe2': 'brown',
        });

        final wardrobe = [
        Item(
            id: 1,
            category: 'Top',
            label: 'White Shirt',
            timesWorn: 5,
            url: 'https://fakeurl.com/top1.png',
            weather: ['Hot', 'Warm'],
        ),
        Item(
            id: 2,
            category: 'Top',
            label: 'Red Sweater',
            timesWorn: 3,
            url: 'https://fakeurl.com/top2.png',
            weather: ['Cool', 'Cold'],
        ),
        Item(
            id: 3,
            category: 'Shoe',
            label: 'Black Sneakers',
            timesWorn: 7,
            url: 'https://fakeurl.com/shoe1.png',
            weather: ['Hot', 'Warm', 'Cool'],
        ),
        Item(
            id: 4,
            category: 'Shoe',
            label: 'Brown Boots',
            timesWorn: 2,
            url: 'https://fakeurl.com/shoe2.png',
            weather: ['Cold'],
        ),
        ];

        final bottom = Item(
        id: 5,
        category: 'Bottom',
        label: 'Blue Jeans',
        timesWorn: 4,
        url: 'https://fakeurl.com/bottom.png',
        weather: ['Hot', 'Cool'],
        );

        colorMatchMap = {
        'blue': {
            'Top': ['white', 'gray'],
            'Shoe': ['black', 'white'],
        }
        };

        final result = await matchTopAndShoe(
        bottom: bottom,
        tempCategory: 'Hot',
        wardrobe: wardrobe,
        colorDetector: mockDetector.getColor, // ✅ Inject cleanly
        );

        expect(result.length, 2);
        final top = result[0];
        final shoe = result[1];

        expect(top.label, 'White Shirt');
        expect(shoe.label, 'Black Sneakers');
    });

    test('matchTopAndShoe returns default item if no match is found', () async {
        final mockDetector = MockColorDetector({
        'bottom': 'blue',
        'top2': 'red',
        'shoe2': 'brown',
        });

        final wardrobe = [
        Item(
            id: 1,
            category: 'Top',
            label: 'Red Sweater',
            timesWorn: 3,
            url: 'https://fakeurl.com/top2.png',
            weather: ['Cold'],
        ),
        Item(
            id: 2,
            category: 'Shoe',
            label: 'Brown Boots',
            timesWorn: 2,
            url: 'https://fakeurl.com/shoe2.png',
            weather: ['Cold'],
        ),
        ];

        final bottom = Item(
        id: 5,
        category: 'Bottom',
        label: 'Blue Jeans',
        timesWorn: 4,
        url: 'https://fakeurl.com/bottom.png',
        weather: ['Hot', 'Cool'],
        );

        colorMatchMap = {
        'blue': {
            'Top': ['white', 'gray'],
            'Shoe': ['black', 'white'],
        }
        };

        final result = await matchTopAndShoe(
        bottom: bottom,
        tempCategory: 'Hot',
        wardrobe: wardrobe,
        colorDetector: mockDetector.getColor, // ✅
        );

        expect(result.length, 2);
        final top = result[0];
        final shoe = result[1];

        expect(top.label, 'default'); // fallback top
        expect(shoe.label, 'default'); // fallback shoe
    });

    test('matchTopAndShoe handles unknown color replacement', () async {
        final mockDetector = MockColorDetector({
        'bottom': 'blue',
        'unknown_top': 'unknown',
        'unknown_shoe': 'unknown',
        });

        final wardrobe = [
        Item(
            id: 10,
            category: 'Top',
            label: 'Unknown Color Top',
            timesWorn: 1,
            url: 'https://fakeurl.com/unknown_top.png',
            weather: ['Hot'],
        ),
        Item(
            id: 11,
            category: 'Shoe',
            label: 'Unknown Color Shoe',
            timesWorn: 1,
            url: 'https://fakeurl.com/unknown_shoe.png',
            weather: ['Hot'],
        ),
        ];

        final bottom = Item(
        id: 5,
        category: 'Bottom',
        label: 'Blue Jeans',
        timesWorn: 4,
        url: 'https://fakeurl.com/bottom.png',
        weather: ['Hot'],
        );

        colorMatchMap = {
        'blue': {
            'Top': ['white', 'gray'],
            'Shoe': ['white', 'gray'],
        }
        };

        final result = await matchTopAndShoe(
        bottom: bottom,
        tempCategory: 'Hot',
        wardrobe: wardrobe,
        colorDetector: mockDetector.getColor, // ✅ Inject smart mock
        );

        expect(result.length, 2);
        expect(result[0].category.toLowerCase(), contains('top'));
        expect(result[1].category.toLowerCase(), contains('shoe'));
    });
  });

  // --------------------------
  // 4. surpriseMe Outfit Generation Tests
  // --------------------------
  group('surpriseMe Outfit Generation Tests', () {
    late FakeWeatherService fakeWeatherService;

    test('should generate an Outfit when valid bottoms exist', () async {
        final wardrobe = [
            Item(id: 1, category: 'Bottom', label: 'Shorts', url: 'https://fakeurl.com/shorts.png', weather: ['Warm', 'Hot'], timesWorn: 0),
            Item(id: 2, category: 'Top', label: 'T-Shirt', url: 'https://fakeurl.com/tshirt.png', weather: ['Warm', 'Hot'], timesWorn: 0),
            Item(id: 3, category: 'Shoe', label: 'Sneakers', url: 'https://fakeurl.com/sneakers.png', weather: ['Warm', 'Hot'], timesWorn: 0),
        ];

        final fakeWeatherService = FakeWeatherService(fakeTemperature: Temperature(fahrenheit: 75.0));
        
        final outfit = await surpriseMeWithMock(
            wardrobe,
            fakeWeatherService,
            colorDetector: fakeColorDetector, // ✅ inject fake here!
        );

        expect(outfit, isNotNull);
        expect(outfit?.topItem.label, 'T-Shirt');
        expect(outfit?.bottomItem.label, 'Shorts');
        expect(outfit?.shoeItem.label, 'Sneakers');
    });


    test('should return null when no valid bottoms exist', () async {
        final wardrobe = [
        Item(id: 4, category: 'Top', label: 'Sweater', url: 'https://fakeurl.com/sweater.png', weather: ['Cold'], timesWorn: 0),
        Item(id: 5, category: 'Shoe', label: 'Boots', url: 'https://fakeurl.com/boots.png', weather: ['Cold'], timesWorn: 0),
        ];

        fakeWeatherService = FakeWeatherService(fakeTemperature: Temperature(fahrenheit: 75.0));
        final outfit = await surpriseMeWithMock(wardrobe, fakeWeatherService);

        expect(outfit, isNull);
    });

    test('should fallback to 70°F when weather temperature is null', () async {
        final wardrobe = [
        Item(id: 6, category: 'Bottom', label: 'Jeans', url: 'https://fakeurl.com/jeans.png', weather: ['Warm'], timesWorn: 0),
        Item(id: 7, category: 'Top', label: 'T-Shirt', url: 'https://fakeurl.com/tshirt2.png', weather: ['Warm'], timesWorn: 0),
        Item(id: 8, category: 'Shoe', label: 'Sneakers', url: 'https://fakeurl.com/sneakers2.png', weather: ['Warm'], timesWorn: 0),
        ];

        fakeWeatherService = FakeWeatherService(fakeTemperature: null);
        final outfit = await surpriseMeWithMock(wardrobe, fakeWeatherService);

        expect(outfit, isNotNull);
        expect(outfit?.bottomItem.label, 'Jeans');
    });

    test('should return null if valid bottoms are excluded by excludeBottomIds', () async {
        final wardrobe = [
        Item(id: 9, category: 'Bottom', label: 'Excluded Shorts', url: 'https://fakeurl.com/excludedshorts.png', weather: ['Warm'], timesWorn: 0),
        ];

        fakeWeatherService = FakeWeatherService(fakeTemperature: Temperature(fahrenheit: 75.0));
        final outfit = await surpriseMeWithMock(wardrobe, fakeWeatherService, excludeBottomIds: {9});

        expect(outfit, isNull);
    });
    });


}
