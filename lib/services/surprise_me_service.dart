import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:dressify_app/services/weather_service.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';

///Convert temperature to a weather category
String getTempCategory(double temp) {
  if (temp < 40) return "Cold";
  if (temp < 60) return "Cool";
  if (temp < 80) return "Warm";
  return "Hot";
}


///Define color matching map
const colorMatchMap = {
  "blue": {
    "Top": ["white", "gray", "black"],
    "Shoe": ["white", "black"]
  },
  "black": {
    "Top": ["white", "beige", "gray"],
    "Shoe": ["white", "red"]
  },
  "white": {
    "Top": ["black", "blue", "green"],
    "Shoe": ["black", "brown"]
  },
  "gray": {
  "Top": ["white", "black"],
  "Shoe": ["white"]
  },
  "red": {
    "Top": ["black", "white"],
    "Shoe": ["white", "gray"]
  },
  // add more as needed
};
//colorMatchMap[bottomColor.toLowerCase()] == null

///Using backend function to do color recognition
Future<String> getColorFromImage(String imageUrl) async {
  final response = await http.post(
    Uri.parse("https://us-central1-dressify-47e6a.cloudfunctions.net/detectDominantColor"),
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"imageUrl": imageUrl}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data["dominant_color"] ?? "unknown";
  } else {
    return "unknown";
  }
}

///Randomly select a bottom and recognize its color
Future<Item?> getRandomBottom(String tempCategory, List<Item> wardrobe) async {
  final bottoms = wardrobe.where((item) =>
    item.category == "bottom" && item.weather.contains(tempCategory)).toList();
  if (bottoms.isEmpty) return null;
  return bottoms[Random().nextInt(bottoms.length)];
}

///Match Top and Shoe based on AI-detected bottom color
Future<List<Item>> matchTopAndShoe({
  required Item bottom,
  required String tempCategory,
  required List<Item> wardrobe,
}) async {
  final bottomColor = await getColorFromImage(bottom.url);
  final colorKey = bottomColor.toLowerCase();

  final topColors = colorMatchMap.containsKey(colorKey)
    ? colorMatchMap[colorKey]!['Top'] ?? []
    : ["white", "black"]; // fallback if unknown or no match

  final shoeColors = colorMatchMap.containsKey(colorKey)
    ? colorMatchMap[colorKey]!['Shoe'] ?? []
    : ["white", "black"]; // fallback if unknown or no match


  //debug
  print('Bottom color detected: $bottomColor');
  print('Matching top colors: $topColors');
  print('Matching shoe colors: $shoeColors');
  print('Wardrobe top candidates: ${wardrobe.where((i) => i.category == "top").length}');
  print('Wardrobe shoe candidates: ${wardrobe.where((i) => i.category == "shoe").length}');

  List<Future<MapEntry<Item, String>>> topColorFutures = wardrobe
    .where((item) => item.category.toLowerCase().contains("top") && item.weather.contains(tempCategory))
    .map((item) async {
      final detectedColor = await getColorFromImage(item.url);
      final color = detectedColor == "unknown" ? "white" : detectedColor;
      return MapEntry(item, color);
    }).toList();

  List<Future<MapEntry<Item, String>>> shoeColorFutures = wardrobe
    .where((item) => item.category.toLowerCase().contains("shoe") && item.weather.contains(tempCategory))
    .map((item) async {
      final detectedColor = await getColorFromImage(item.url);
      final color = detectedColor == "unknown" ? "white" : detectedColor;
      return MapEntry(item, color);
    }).toList();

  final topPairs = await Future.wait(topColorFutures);
  final shoePairs = await Future.wait(shoeColorFutures);

  final matchedTops = topPairs.where((entry) => topColors.contains(entry.value)).map((e) => e.key).toList();
  final matchedShoes = shoePairs.where((entry) => shoeColors.contains(entry.value)).map((e) => e.key).toList();

  final top = matchedTops.isNotEmpty ? matchedTops[Random().nextInt(matchedTops.length)] : Item(category: 'Top', id: 0, label: 'default', timesWorn: 0, url: 'https://via.placeholder.com/150', weather: [tempCategory]);
  final shoe = matchedShoes.isNotEmpty ? matchedShoes[Random().nextInt(matchedShoes.length)] : Item(category: 'Shoe', id: 0, label: 'default', timesWorn: 0, url: 'https://via.placeholder.com/150', weather: [tempCategory]);
  //debug
  print('Top results: ${matchedTops.map((e) => e.label).toList()}');
  print('Shoe results: ${matchedShoes.map((e) => e.label).toList()}');
  return [top, shoe];
}

///Complete "Surprise Me" function
//Future<List<Item>> surpriseMe(List<Item> wardrobe) async {
//Future<Outfit?> surpriseMe(List<Item> wardrobe) async {
Future<Outfit?> surpriseMe(List<Item> wardrobe, {Set<int> excludeBottomIds = const {}}) async {

  WeatherService weatherService = WeatherService();
  final weather = await weatherService.getTheWeather();
  final temp = weather.temperature?.fahrenheit ?? 70.0; // default fallback
  
  final tempCategory = getTempCategory(temp);
  print('Temp Category: $tempCategory');

  final validBottoms = wardrobe.where((item) =>
    item.category.toLowerCase().contains("bottom") &&
    item.weather.contains(tempCategory) &&
    !excludeBottomIds.contains(item.id)).toList();
  print('Bottoms available: ${validBottoms.length}');
  
  //if (validBottoms.isEmpty) return null;

  //final bottom = validBottoms[Random().nextInt(validBottoms.length)];

  final bottom = validBottoms.isNotEmpty
    ? validBottoms[Random().nextInt(validBottoms.length)]
    : null;

  if (bottom == null) {
    print(' No bottom found for temp category $tempCategory');
    return null;
  }

  final results = await matchTopAndShoe(
    bottom: bottom,
    tempCategory: tempCategory,
    wardrobe: wardrobe,
  );

  return Outfit.fromItemList([results[0], bottom, results[1]]);
}
