import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart'; // ✅ Needed
import 'package:mockito/mockito.dart'; // ✅ Needed
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/services/surprise_me_service.dart';

//Add this line to tell build_runner to generate the mocks:
@GenerateMocks([http.Client])

import 'surprise_me_service_test.mocks.dart';


void main() {
  // ✅ Important for Flutter async service tests
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Basic utilities', () {
    test('getTempCategory correctly categorizes temperature', () {
      expect(getTempCategory(30), "Cold");
      expect(getTempCategory(50), "Cool");
      expect(getTempCategory(70), "Warm");
      expect(getTempCategory(90), "Hot");
    });

    test('getBasicColorName finds nearest color', () {
      expect(getBasicColorName('#000000'), 'black');
      expect(getBasicColorName('#FFFFFF'), 'white');
      expect(getBasicColorName('#FF0000'), 'red');
      expect(getBasicColorName('#00FF00'), 'lime');
      expect(getBasicColorName('#0000FF'), 'blue');
    });
  });

  group('getColorFromImage', () {
    final mockClient = MockClient();

    testWidgets('returns unknown when an exception occurs during fetch', (tester) async {
        // 🔥 Simulate network error (Exception)
        when(mockClient.get(any)).thenThrow(Exception('Simulated network error'));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/exception.png', mockClient);
        });

        expect(result, 'unknown'); // ✅ hits the catch (e) block
    });

    testWidgets('returns unknown when HTTP status is not 200', (tester) async {
        // 🔥 Simulate bad HTTP response (404 Not Found)
        when(mockClient.get(any)).thenAnswer((_) async => http.Response('Not found', 404));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/404.png', mockClient);
        });

        expect(result, 'unknown'); // hits HTTP failure path
    });

    testWidgets('returns unknown when decoding image fails', (tester) async {
        // 🔥 Simulate HTTP 200 but invalid image bytes (garbage data)
        final garbageBytes = Uint8List.fromList([0, 1, 2, 3, 4, 5]); // Not a real image
        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(garbageBytes, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/invalidimage.png', mockClient);
        });

        expect(result, 'unknown'); // hits decoding failure inside detectDominantColorFromBytes
    });

    testWidgets('returns color when HTTP succeeds and image decodes correctly', (tester) async {
        // 🔥 Create a real, valid image
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255); // Light beige
        }
        }
        final validImageBytes = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(validImageBytes, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/success.png', mockClient);
        });

        expect(result, isNot('unknown')); // hits happy path: decoding, clustering
    });

    testWidgets('returns unknown if detectDominantColorFromBytes cannot detect dominant color', (tester) async {
        // 🔥 Simulate HTTP 200 but with an image that will result in all white or invalid pixels
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 255, 255, 255, 255); // All white pixels
        }
        }
        final whiteImageBytes = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(whiteImageBytes, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/white.png', mockClient);
        });

        expect(result, 'unknown'); // some dominant color detectors return 'unknown' for pure white noise
    });
  });

  group('Real getColorFromImage (no injected client)', () {
    testWidgets('returns unknown if fetch throws error', (tester) async {
      final result = await tester.runAsync(() async {
        return await getColorFromImage('httpp://invalid_url'); // invalid URL causes error
      });

      expect(result, 'unknown');
    });

    testWidgets('returns unknown if HTTP status is not 200', (tester) async {
      // Normally you cannot fake http.get easily without a mock client.
      // So to simulate, we use a special bad image server (or leave as TODO if offline).
      final result = await tester.runAsync(() async {
        return await getColorFromImage('https://httpstat.us/404');
      });

      expect(result, 'unknown');
    });
  });
  /*group('getColorFromImage', () {
    final mockClient = MockClient();

    testWidgets('returns unknown when an exception occurs during fetch', (tester) async {
        when(mockClient.get(any)).thenThrow(Exception('Simulated network error'));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/exception.png', mockClient);
        });

        expect(result, 'unknown'); // ✅ line 201
    });

    testWidgets('returns color when HTTP succeeds and bodyBytes are read', (tester) async {
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255); // light beige
        }
        }
        final validImage = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(validImage, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/success.png', mockClient);
        });

        expect(result, isNot('unknown')); // ✅ hits line 193–194
    });
    testWidgets('returns color when HTTP succeeds with a valid image', (tester) async {
        final image = img.Image(width: 64, height: 64);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255); // light gray
        }
        }
        final validImage = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(validImage, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/success.png', mockClient);
        });

        expect(result, 'beige');
    });

    testWidgets('should hit response.bodyBytes and call detectDominantColorFromBytes', (tester) async {
        final image = img.Image(width: 10, height: 10);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255);
        }
        }
        final encodedImage = img.encodePng(image);

        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(encodedImage, 200));

        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/test.png', mockClient);
        });

        expect(result, isNot('unknown')); // confirms bodyBytes & clustering executed
    });
  
    testWidgets('getColorFromImage hits bodyBytes and detectDominantColorFromBytes', (tester) async {
        // 1. Create a valid PNG image
        final image = img.Image(width: 10, height: 10);
        for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
            image.setPixelRgba(x, y, 240, 240, 240, 255); // Light gray
        }
        }
        final encodedImage = img.encodePng(image);

        // 2. Mock client to return 200 and valid image
        when(mockClient.get(any)).thenAnswer((_) async => http.Response.bytes(encodedImage, 200));

        // 3. Run inside runAsync properly
        final result = await tester.runAsync(() async {
        return await getColorFromImageWithClient('https://fakeurl.com/fake.png', mockClient);
        });

        // 4. Verify the result
        expect(result, 'beige'); // or 'white' depending on your color map
    });
    
  });*/



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
}
