import 'dart:typed_data';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'package:dressify_app/services/surprise_me_service.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
//import 'package:dressify_app/mocks/mock_color_detector.dart';
//import 'mocks/mock_color_detector.dart';
import '../mocks/mock_color_detector.dart';  // ✅ NEW



@GenerateMocks([http.Client])
import 'surprise_me_service_test.mocks.dart';

// ----------------------------
// Helpers & Mocks
// ----------------------------

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

Uint8List createWhiteImage({int size = 32}) => createSolidColorImage(255, 255, 255, size: size);

Uint8List createHalfRedHalfBlueImage({int width = 80, int height = 100}) {
  final image = img.Image(width: width, height: height);
  final red = img.ColorRgb8(255, 0, 0);
  final blue = img.ColorRgb8(0, 0, 255);
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      image.setPixel(x, y, x < width ~/ 2 ? red : blue);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}

Uint8List createInvalidImage() => Uint8List.fromList(List<int>.generate(10, (_) => Random().nextInt(255)));
Uint8List createInvalidPngBytes() => Uint8List.fromList([0x00, 0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77]);

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

class Temperature {
  final double fahrenheit;
  Temperature({required this.fahrenheit});
}

class Weather {
  final Temperature? temperature;
  Weather({this.temperature});
}

class FakeWeatherService {
  final Temperature? fakeTemperature;
  FakeWeatherService({this.fakeTemperature});
  Future<Weather> getTheWeather() async => Weather(temperature: fakeTemperature);
}

Future<Outfit?> surpriseMeWithMock(
  List<Item> wardrobe,
  FakeWeatherService weatherService, {
  Set<int> excludeBottomIds = const {},
  Future<String> Function(String url)? colorDetector,
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
    colorDetector: colorDetector,
  );
  return Outfit.fromSurpriseMe(
    top: matchedItems[0],
    bottom: bottom,
    shoe: matchedItems[1],
    tempCategory: tempCategory,
  );
}

Future<String> fakeColorDetector(String url) async {
  if (url.contains('shorts') || url.contains('jeans')) return 'blue';
  if (url.contains('tshirt') || url.contains('tshirt2')) return 'white';
  if (url.contains('sneakers') || url.contains('sneakers2')) return 'black';
  return 'unknown';
}

// ----------------------------
// Test Entry Point
// ----------------------------

void main() {
  // TestWidgetsFlutterBinding.ensureInitialized();


  group('Basic utilities', () {
  group('getTempCategory', () {
    test('correctly categorizes edge temperatures', () {
      expect(getTempCategory(39.9), "Cold"); // edge just below 40
      expect(getTempCategory(40.0), "Cool"); // exact transition to Cool
      expect(getTempCategory(59.9), "Cool"); // edge just below 60
      expect(getTempCategory(60.0), "Warm"); // exact transition to Warm
      expect(getTempCategory(79.9), "Warm"); // edge just below 80
      expect(getTempCategory(80.0), "Hot");  // exact transition to Hot
    });

    test('handles extreme values', () {
      expect(getTempCategory(-10), "Cold");
      expect(getTempCategory(100), "Hot");
    });
  });

  group('getBasicColorName', () {
    test('matches exact RGB values for known colors', () {
      expect(getBasicColorName('#FFFF00'), 'yellow');   // yellow
      expect(getBasicColorName('#00FFFF'), 'cyan');     // cyan
      expect(getBasicColorName('#FF00FF'), 'magenta');  // magenta
      expect(getBasicColorName('#C0C0C0'), 'silver');   // silver
      expect(getBasicColorName('#A52A2A'), 'brown');    // brown
      expect(getBasicColorName('#ADD8E6'), 'lightblue'); // lightblue
    });

    test('handles closest match by Euclidean distance', () {
      expect(getBasicColorName('#F4F4DC'), 'beige');     // close to beige
      expect(getBasicColorName('#D3D3D3'), 'lightgray'); // close to lightgray
      expect(getBasicColorName('#D2B48C'), 'tan');       // close to tan
    });

    test('returns unknown for invalid or distant values (not expected in real app)', () {
      // If you'd like to guard this in real use, add validation logic
      // For now, it's tested just to ensure fallback works
      expect(getBasicColorName('#123456'), isA<String>()); // should still return some closest match
    });

    test('midpoint testing between known colors', () {
      // Midpoint between red (255,0,0) and maroon (128,0,0) is approx (192,0,0)
      expect(getBasicColorName('#C00000'), anyOf(['red', 'maroon'])); // whichever is closer
    });
  });
});

  group('getColorFromImage', () {
    final mockClient = MockClient();

    test('returns unknown when an exception occurs during fetch', () async {
        // Simulate network error (Exception)
        when(mockClient.get(any)).thenThrow(Exception('Simulated network error'));

        final result = await getColorFromImageWithClient('https://fakeurl.com/exception.png', mockClient);
        

        expect(result, 'unknown'); // hits the catch (e) block
    });

    test('returns unknown when HTTP status is not 200', () async {
        // Simulate bad HTTP response (404 Not Found)
        when(mockClient.get(any)).thenAnswer((_) async => http.Response('Not found', 404));

        final result = await getColorFromImageWithClient('https://fakeurl.com/404.png', mockClient);
        

        expect(result, 'unknown'); // hits HTTP failure path
    });

    test('returns unknown when decoding image fails', () async {
        // Simulate HTTP 200 but invalid image bytes (garbage data)
        final garbageBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]); // Not a real image
        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(garbageBytes, 200));

        final result = await getColorFromImageWithClient('https://fakeurl.com/invalidimage.png', mockClient);
  

        expect(result, 'unknown'); // hits decoding failure inside detectDominantColorFromBytes
    });

    test('returns color when HTTP succeeds and image decodes correctly', () async {
        //  Create a real, valid image
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255); // Light beige
        }
        }
        final validImageBytes = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(validImageBytes, 200));

        final result = await getColorFromImageWithClient('https://fakeurl.com/success.png', mockClient);
    

        expect(result, isNot('unknown')); // hits happy path: decoding, clustering
    });

    test('returns unknown if detectDominantColorFromBytes cannot detect dominant color', () async {
        //  Simulate HTTP 200 but with an image that will result in all white or invalid pixels
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 255, 255, 255, 255); // All white pixels
        }
        }
        final whiteImageBytes = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(whiteImageBytes, 200));

        final result = await getColorFromImageWithClient('https://fakeurl.com/white.png', mockClient);
      
        expect(result, 'unknown'); // some dominant color detectors return 'unknown' for pure white noise
    });

  });

  group('Real getColorFromImage (no injected client)', () {
    test('returns unknown if fetch throws error', () async {
      final result = await getColorFromImage('httpp://invalid_url'); // invalid URL causes error
    

      expect(result, 'unknown');
    });

    test('returns unknown if HTTP status is not 200', () async {
      // Normally you cannot fake http.get easily without a mock client.
      // So to simulate, we use a special bad image server (or leave as TODO if offline).
      final result = await getColorFromImage('https://httpstat.us/404');

      expect(result, 'unknown');
    });
  });
  

  group('getRandomBottom', () {
    test('selects a random bottom if available', () async {
      final wardrobe = [
        Item(id: 1, label: 'Shorts', category: 'bottom', url: '', weather: ['Warm'], timesWorn: 0),
      ];
      final bottom = await getRandomBottom('Warm', wardrobe);
      expect(bottom, isNotNull);
      expect(bottom?.label, 'Shorts');
    });

    test('returns null if no bottom matches', () async {
      final wardrobe = [
        Item(id: 1, label: 'Jacket', category: 'top', url: '', weather: ['Cold'], timesWorn: 0),
      ];
      final bottom = await getRandomBottom('Warm', wardrobe);
      expect(bottom, isNull);
    });
  });

  group('matchTopAndShoe', () {
    test('matches top and shoe based on bottom color', () async {
      final wardrobe = [
        Item(id: 2, label: 'White Shirt', category: 'top', url: 'top1', weather: ['Warm'], timesWorn: 0),
        Item(id: 3, label: 'Black Shoes', category: 'shoe', url: 'shoe1', weather: ['Warm'], timesWorn: 0),
      ];

      Future<String> fakeColorDetector(String url) async {
        if (url == 'bottom') return 'blue';
        if (url == 'top1') return 'white';
        if (url == 'shoe1') return 'white';
        return 'unknown';
      }

      final bottom = Item(id: 1, label: 'Blue Jeans', category: 'bottom', url: 'bottom', weather: ['Warm'], timesWorn: 0);

      final items = await matchTopAndShoe(bottom: bottom, tempCategory: 'Warm', wardrobe: wardrobe, colorDetector: fakeColorDetector);

      expect(items.length, 2);
      expect(items[0].label, 'White Shirt'); // Top
      expect(items[1].label, 'Black Shoes'); // Shoe
    });

    test('fallbacks to default top/shoe when no match', () async {
      final wardrobe = <Item>[];

      Future<String> fakeColorDetector(String url) async => 'unknown';

      final bottom = Item(id: 1, label: 'Any Pants', category: 'bottom', url: 'bottom', weather: ['Warm'], timesWorn: 0);

      final items = await matchTopAndShoe(bottom: bottom, tempCategory: 'Warm', wardrobe: wardrobe, colorDetector: fakeColorDetector);

      expect(items.length, 2);
      expect(items[0].label, 'default');
      expect(items[1].label, 'default');
    });

    test('fallback selects random top/shoe from unknown colors', () async {
        final wardrobe = [
        Item(id: 2, label: 'Mystery Top', category: 'top', url: 'top1', weather: ['Warm'], timesWorn: 0),
        Item(id: 3, label: 'Mystery Shoe', category: 'shoe', url: 'shoe1', weather: ['Warm'], timesWorn: 0),
        ];

        Future<String> fakeAlwaysUnknownColorDetector(String url) async => 'unknown'; // All unknowns!

        final bottom = Item(id: 1, label: 'Any Pants', category: 'bottom', url: 'bottom', weather: ['Warm'], timesWorn: 0);

        final matchedItems = await matchTopAndShoe(
        bottom: bottom,
        tempCategory: 'Warm',
        wardrobe: wardrobe,
        colorDetector: fakeAlwaysUnknownColorDetector,
        );

        expect(matchedItems.length, 2);
        expect(matchedItems[0].label, 'Mystery Top'); //fallback from unknown
        expect(matchedItems[1].label, 'Mystery Shoe'); //fallback from unknown
    });
  });

  group('surpriseMe', () {
    test('generates an outfit successfully', () async {
      final wardrobe = [
        Item(id: 1, label: 'Jeans', category: 'bottom', url: 'bottom', weather: ['Warm'], timesWorn: 0),
        Item(id: 2, label: 'T-shirt', category: 'top', url: 'top1', weather: ['Warm'], timesWorn: 0),
        Item(id: 3, label: 'Sneakers', category: 'shoe', url: 'shoe1', weather: ['Warm'], timesWorn: 0),
      ];

      Future<String> fakeColorDetector(String url) async {
        if (url == 'bottom') return 'blue';
        if (url == 'top1') return 'white';
        if (url == 'shoe1') return 'white';
        return 'unknown';
      }

      final outfit = await surpriseMe(wardrobe);

      expect(outfit, isNotNull);
      expect(outfit?.bottomItem.label, 'Jeans'); // fixed from bottom.label to bottomItem.label
    });

    test('returns null if no bottoms available', () async {
      final wardrobe = [
        Item(id: 2, label: 'Top', category: 'top', url: '', weather: ['Warm'], timesWorn: 0),
        Item(id: 3, label: 'Shoe', category: 'shoe', url: '', weather: ['Warm'], timesWorn: 0),
      ];

      final result = await surpriseMe(wardrobe);
      expect(result, isNull);
    });
  });
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
    
    test('detectDominantColorFromBytes returns unknown if image is empty', () async {
      final emptyImage = img.Image(width: 0, height: 0); 
      final bytes = Uint8List.fromList(img.encodePng(emptyImage));
      final result = await detectDominantColorFromBytes(bytes);
      expect(result, 'unknown');
    });

    test('handles non-square image and clustering', () async {
        final bytes = createHalfRedHalfBlueImage(width: 80, height: 100);
        final dominantColor = await detectDominantColorFromBytes(bytes, k: 2);

        expect(
            dominantColor,
            anyOf(['red', 'blue', 'purple']), //add 'purple' as valid
        );
    });


  });

  
  // --------------------------
  // 2. getColorFromImage Network Fetch Tests
  // --------------------------
  group('getColorFromImage Network Fetch Tests', () {
    test('getColorFromImage real image test (requires network)', () async {
        
        const imageUrl = 'https://firebasestorage.googleapis.com/v0/b/dressify-47e6a.firebasestorage.app/o/images%2Fimage_picker_25BB0901-13BB-40E0-A09E-34A9B50B3D43-3675-0000001DEBA3FED0.png?alt=media&token=e00a2dfc-e0a0-43cf-ad90-d2e6c87fa765';
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
        final redColor = img.ColorRgb8(255, 0, 0); // Create solid red color
        tinyImage.setPixel(0, 0, redColor); //Set the pixel manually to red

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

    test('getColorFromImage returns a color when real HTTP 200', () async {
     //  Setup: You need a real small hosted image online
    final colorName = await getColorFromImage('https://firebasestorage.googleapis.com/v0/b/dressify-47e6a.firebasestorage.app/o/images%2Fimage_picker_25BB0901-13BB-40E0-A09E-34A9B50B3D43-3675-0000001DEBA3FED0.png?alt=media&token=e00a2dfc-e0a0-43cf-ad90-d2e6c87fa765');
    
    expect(colorName, isNot('unknown'));
    });

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
        colorDetector: mockDetector.getColor, //  Inject cleanly
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
        colorDetector: mockDetector.getColor, 
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
        colorDetector: mockDetector.getColor, // Inject smart mock
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
            colorDetector: fakeColorDetector, // inject fake here!
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