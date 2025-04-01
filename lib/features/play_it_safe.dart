import 'package:dressify_app/models/outfit.dart';

/// Service to handle logic for the "Play It Safe" feature
class PlayItSafeService {
  /// Returns a random outfit from the saved outfit list
  static Outfit? getSafeOutfit() {
    // Check if any outfits have been loaded
    if (Outfit.outfitList.isNotEmpty) {
      Outfit.outfitList.shuffle(); // Randomize the list order

      // TODO: Implement weather suitability check here
      // Only return outfits suitable for current weather once weather API is integrated.

      // TODO: Prevent same outfit from showing twice in a row
      // Store last shown outfit and skip if it's the same.

      return Outfit.outfitList.first; // Return the first (randomized) outfit
    }

    // Return null if no outfits are available
    return null;
  }
}
