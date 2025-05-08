// Imports for core Dart libraries and required packages
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

// Internal app models and services
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/services/weather_service.dart';

// Image processing library
import 'package:image/image.dart' as img; // Dart image decoding

// Converts temperature (°F) into a weather category
String getTempCategory(double temp) {
  if (temp < 40) return "Cold";
  if (temp < 60) return "Cool";
  if (temp < 80) return "Warm";
  return "Hot";
}

// Maps RGB hex code to a human-readable color name using a simple dictionary
String getBasicColorName(String hex) {
  // Convert hex string to RGB components
  int r = int.parse(hex.substring(1, 3), radix: 16);
  int g = int.parse(hex.substring(3, 5), radix: 16);
  int b = int.parse(hex.substring(5, 7), radix: 16);
  // Map of basic named colors with RGB values
  const Map<String, List<int>> namedColors = {
    "black": [0, 0, 0],
    "white": [255, 255, 255],
    "red": [255, 0, 0],
    "lime": [0, 255, 0],
    "blue": [0, 0, 255],
    "yellow": [255, 255, 0],
    "cyan": [0, 255, 255],
    "magenta": [255, 0, 255],
    "gray": [128, 128, 128],
    "maroon": [128, 0, 0],
    "olive": [128, 128, 0],
    "green": [0, 128, 0],
    "purple": [128, 0, 128],
    "teal": [0, 128, 128],
    "silver": [192, 192, 192],
    "beige": [245, 245, 220],
    "brown": [165, 42, 42],
    "tan": [210, 180, 140],
    "lightblue": [173, 216, 230],
    "lightgreen": [144, 238, 144],
    "lightgray": [211, 211, 211],
    "orange": [255, 165, 0],
    "pink": [255, 192, 203],
    "darkgray": [169, 169, 169],
  };

  double minDistance = double.infinity;
  String closestColor = "unknown";

  namedColors.forEach((name, rgb) {
    double distance = pow(r - rgb[0], 2).toDouble() +
                      pow(g - rgb[1], 2).toDouble() +
                      pow(b - rgb[2], 2).toDouble();
    if (distance < minDistance) {
      minDistance = distance;
      closestColor = name;
    }
  });

  return closestColor;
}



// Detect the dominant color of an image using a lightweight KMeans algorithm
Future<String> detectDominantColorFromBytes(Uint8List imageBytes, {int k = 3}) async {
  final image = img.decodeImage(imageBytes);
  if (image == null || (image.width == 0 && image.height == 0)) {
    print("🛑 Failed to decode image.");
    return 'unknown';
  }

  // 🔹 Step 1: Crop center square to remove background corners 
  final cropSize = min(image.width, image.height);// Define the cropping size (square: take min dimension)
  //Assign width and height for cropping separately
  final cropWidth = cropSize;
  final cropHeight = cropSize;
  //Now call img.copyCrop using the separate width/height
  final cropped = img.copyCrop(
    image,
    x: (image.width - cropWidth) ~/ 2,
    y: (image.height - cropHeight) ~/ 2,
    width: cropWidth,
    height: cropHeight,
  );


  // 🔹 Step 2: Resize to reduce background pixel influence
  final resized = img.copyResize(cropped, width: 64, height: 64);

  final pixels = <List<double>>[];
  for (int y = 0; y < resized.height; y++) {
    for (int x = 0; x < resized.width; x++) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();

      final brightness = (r + g + b) / 3;

      if (brightness < 245) {
        pixels.add([r, g, b]);
      }
      
    }
  }
  if (pixels.isEmpty) {
    print("⚠️ All pixels filtered out. Returning unknown.");
    return 'unknown';
  }

  // 🔹 Step 3: KMeans clustering
  final centroids = pixels.sublist(0, k);
  final labels = List<int>.filled(pixels.length, 0);
  const maxIterations = 10;

  for (int iter = 0; iter < maxIterations; iter++) {
    for (int i = 0; i < pixels.length; i++) {
      final pixel = pixels[i];
      double minDist = double.infinity;
      int bestCluster = 0;

      for (int c = 0; c < k; c++) {
        final centroid = centroids[c];
        final dist = pow(pixel[0] - centroid[0], 2).toDouble() +
                     pow(pixel[1] - centroid[1], 2).toDouble() +
                     pow(pixel[2] - centroid[2], 2).toDouble();
        if (dist < minDist) {
          minDist = dist;
          bestCluster = c;
        }
      }
      labels[i] = bestCluster;
    }

    final newCentroids = List.generate(k, (_) => [0.0, 0.0, 0.0]);
    final counts = List<int>.filled(k, 0);

    for (int i = 0; i < pixels.length; i++) {
      final label = labels[i];
      final pixel = pixels[i];
      newCentroids[label][0] += pixel[0];
      newCentroids[label][1] += pixel[1];
      newCentroids[label][2] += pixel[2];
      counts[label]++;
    }

    for (int c = 0; c < k; c++) {
      if (counts[c] == 0) continue;
      newCentroids[c][0] /= counts[c];
      newCentroids[c][1] /= counts[c];
      newCentroids[c][2] /= counts[c];
    }

    centroids.setAll(0, newCentroids);
  }

  // 🔹 Step 4: Most frequent cluster
  final frequency = List<int>.filled(k, 0);
  for (final label in labels) {
    frequency[label]++;
  }
  final dominantIndex = frequency.indexOf(frequency.reduce(max));
  final dominantRGB = centroids[dominantIndex];

  final hex = '#${dominantRGB[0].round().toRadixString(16).padLeft(2, '0')}'
              '${dominantRGB[1].round().toRadixString(16).padLeft(2, '0')}'
              '${dominantRGB[2].round().toRadixString(16).padLeft(2, '0')}';

  //print("🎯 Dominant RGB Hex: $hex");

  return getBasicColorName(hex);
}

// Download image from URL and detect its dominant color
Future<String> getColorFromImage(String imageUrl) async {
//Future<String> getColorFromImage(String imageUrl, {http.Client? client}) async {
  //final httpClient = client ?? http.Client(); // Use provided client, or real client
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return await detectDominantColorFromBytes(imageBytes);
    } else {
      print("\u274c Failed to fetch image: ${response.statusCode}");
      return 'unknown';
    }
  } catch (e) {
    print("\u274c Error fetching or processing image: $e");
    return 'unknown';
  }
}

// Fashion color compatibility map based on dominant bottom color
Map<String, Map<String, List<String>>> colorMatchMap = {
  "blue": {
    "Top": ["white", "gray", "black"],
    "Shoe": ["white", "black"]
  },
  "black": {
    "Top": ["white", "beige", "gray", "green"],
    "Shoe": ["white", "red", "gray", "beige", "brown", "silver", "blue"] 
  },
  "white": {
    "Top": ["black", "blue", "green","red"],
    "Shoe": ["black", "brown","white"]
  },
  "gray": {
    "Top": ["white", "black","gray"],
    "Shoe": ["white","black"]
  },
  "red": {
    "Top": ["black", "white"],
    "Shoe": ["white", "gray","black"]
  },
};

// Select a random bottom item that matches the weather category
Future<Item?> getRandomBottom(String tempCategory, List<Item> wardrobe) async {
  final bottoms = wardrobe.where((item) =>
    item.category == "bottom" && item.weather.contains(tempCategory)).toList();
  if (bottoms.isEmpty) return null;
  return bottoms[Random().nextInt(bottoms.length)];
}


/// Matches a top and shoe based on a given bottom item's detected color and the weather category.
/// 
/// [bottom]: The bottom item.
/// [tempCategory]: Current weather category ("Hot", "Warm", "Cool", "Cold").
/// [wardrobe]: List of all available wardrobe items.
/// [colorDetector]: Optional custom color detector for testing or overriding image analysis.
///
/// Returns a [List] with exactly 2 items: selected Top and Shoe.
Future<List<Item>> matchTopAndShoe({
  required Item bottom,
  required String tempCategory,
  required List<Item> wardrobe,
  Future<String> Function(String url)? colorDetector,
}) async {
  final detectColor = colorDetector ?? getColorFromImage; // ✅ use this everywhere

  // Step 1: Detect color from the bottom item's image URL
  final bottomColor = await detectColor(bottom.url);
  final colorKey = bottomColor.toLowerCase();
  print("🎨 Detected Bottom Color: $bottomColor");

  // Step 2: Lookup preferred matching colors for tops and shoes
  final topColors = colorMatchMap[colorKey]?['Top'] ?? ["white", "black"];
  final shoeColors = colorMatchMap[colorKey]?['Shoe'] ?? ["white", "black", "gray", "brown"];

  // Step 3: Detect colors for tops
  final topColorFutures = wardrobe
      .where((item) => item.category.toLowerCase().contains("top") && item.weather.contains(tempCategory))
      .map((item) async {
        final color = await detectColor(item.url); // ✅ use detectColor
        return MapEntry(item, color == "unknown" ? "white" : color);
      }).toList();

  // Step 4: Detect colors for shoes
  final shoeColorFutures = wardrobe
      .where((item) => item.category.toLowerCase().contains("shoe") && item.weather.contains(tempCategory))
      .map((item) async {
        final color = await detectColor(item.url); // ✅ use detectColor
        return MapEntry(item, color == "unknown" ? "white" : color);
      }).toList();

  final topPairs = await Future.wait(topColorFutures);
  final shoePairs = await Future.wait(shoeColorFutures);

  // Step 5: Filter items by compatible color
  final matchedTops = topPairs.where((entry) => topColors.contains(entry.value)).map((e) => e.key).toList();
  final matchedShoes = shoePairs.where((entry) => shoeColors.contains(entry.value)).map((e) => e.key).toList();

  // Step 6: Select a top
  final top = matchedTops.isNotEmpty
    ? matchedTops[Random().nextInt(matchedTops.length)]
    : (topPairs.any((entry) => entry.value != 'unknown')
        ? topPairs
            .where((entry) => entry.value != 'unknown')
            .map((e) => e.key)
            .toList()[Random().nextInt(topPairs.where((entry) => entry.value != 'unknown').length)]
        : Item(
            category: 'Top',
            id: 0,
            label: 'default',
            timesWorn: 0,
            url: 'https://via.placeholder.com/150',
            weather: [tempCategory],
          ));

  // Step 7: Select a shoe
  final shoe = matchedShoes.isNotEmpty
    ? matchedShoes[Random().nextInt(matchedShoes.length)]
    : (shoePairs.any((entry) => entry.value != 'unknown')
        ? shoePairs
            .where((entry) => entry.value != 'unknown')
            .map((e) => e.key)
            .toList()[Random().nextInt(shoePairs.where((entry) => entry.value != 'unknown').length)]
        : Item(
            category: 'Shoe',
            id: 0,
            label: 'default',
            timesWorn: 0,
            url: 'https://via.placeholder.com/150',
            weather: [tempCategory],
          ));

  return [top, shoe];
}


// Full Surprise Me feature: generate a full outfit based on weather and wardrobe
Future<Outfit?> surpriseMe(List<Item> wardrobe, {Set<int> excludeBottomIds = const {}}) async {
  final weatherService = WeatherService();
  final weather = await weatherService.getTheWeather();
  final temp = weather.temperature?.fahrenheit ?? 70.0;

  final tempCategory = getTempCategory(temp);

  // Filter bottoms by weather and exclusions
  final validBottoms = wardrobe.where((item) =>
    item.category.toLowerCase().contains("bottom") &&
    item.weather.contains(tempCategory) &&
    !excludeBottomIds.contains(item.id)).toList();

  final bottom = validBottoms.isNotEmpty
      ? validBottoms[Random().nextInt(validBottoms.length)]
      : null;

  if (bottom == null) return null;

  print("🎲 Selected Bottom: ${bottom.label} (${bottom.url}),Weather: $tempCategory");

  // Match top and shoe and return the final outfit
  final matchedItems = await matchTopAndShoe(
    bottom: bottom,
    tempCategory: tempCategory,
    wardrobe: wardrobe,
  );

  //Print selected top and shoe with temperature
  print("👕 Selected Top: ${matchedItems[0].label} (${matchedItems[0].url}), Weather: $tempCategory");
  print("👟 Selected Shoe: ${matchedItems[1].label} (${matchedItems[1].url}), Weather: $tempCategory");

  //return Outfit.fromItemList([matchedItems[0], bottom, matchedItems[1]]);
  return Outfit.fromSurpriseMe(
    top: matchedItems[0],
    bottom: bottom,
    shoe: matchedItems[1],
    tempCategory: tempCategory,
  );
}
///HELPER for test
Future<String> getColorFromImageWithClient(String imageUrl, http.Client client) async {
  try {
    final response = await client.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final imageBytes = response.bodyBytes;
      return await detectDominantColorFromBytes(imageBytes);
    } else {
      print("\u274c Failed to fetch image: ${response.statusCode}");
      return 'unknown';
    }
  } catch (e) {
    print("\u274c Error fetching or processing image: $e");
    return 'unknown';
  }
}