import 'package:dressify_app/models/outfit.dart'; // Outfit model with outfitList
import 'package:dressify_app/models/item.dart';   // Item model with itemList
import 'package:dressify_app/services/weather_service.dart'; // WeatherService to get current weather

/// Service to handle logic for the "Play It Safe" feature
class PlayItSafeService {
  /// Converts a temperature in Fahrenheit to a general weather category
  static String getTempCategory(double temp) {
    if (temp < 40) return "Cold";
    if (temp < 60) return "Cool";
    if (temp < 80) return "Warm";
    return "Hot";
  }

  /// Returns a random favorite outfit that matches the current weather category
  static Future<Outfit?> getSafeOutfit() async {
    try {
      // Attempt to fetch current weather using WeatherService
      final weather = await WeatherService().getTheWeather();

      // Use current temp in °F, or fallback to 70°F if weather data is unavailable
      final double tempFahrenheit = weather.temperature?.fahrenheit ?? 70.0;

      // Get the matching temperature category (Cold, Cool, Warm, Hot)
      final String tempCategory = getTempCategory(tempFahrenheit);

      // Filter outfits that:
      // - Have all items still present in the user's wardrobe
      // - Are marked as appropriate for the current weather
      final validOutfits = Outfit.outfitList.where((outfit) {
        final hasAllItems = Item.itemList.contains(outfit.topItem) &&
                             Item.itemList.contains(outfit.bottomItem) &&
                             Item.itemList.contains(outfit.shoeItem);

        final matchesWeather = outfit.weather.contains(tempCategory);
        return hasAllItems && matchesWeather;
      }).toList();

      // If no valid outfits are found, return null
      if (validOutfits.isEmpty) return null;

      // Randomize the list and return the first valid match
      validOutfits.shuffle();
      return validOutfits.first;

    } catch (e) {
      // Log any unexpected errors and return null
      print('[PlayItSafeService] Failed to fetch safe outfit: $e');
      return null;
    }
  }
}
