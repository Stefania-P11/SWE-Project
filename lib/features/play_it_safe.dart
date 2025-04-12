import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/models/item.dart';

/// Service to handle logic for the "Play It Safe" feature
class PlayItSafeService {
  /// Returns a random valid outfit from the saved outfit list
  static Outfit? getSafeOutfit() {
    // Filter out outfits with missing components
    final validOutfits = Outfit.outfitList.where((outfit) {
      return Item.itemList.contains(outfit.topItem) &&
             Item.itemList.contains(outfit.bottomItem) &&
             Item.itemList.contains(outfit.shoeItem);
    }).toList();

    if (validOutfits.isNotEmpty) {
      validOutfits.shuffle(); // Randomize the list
      return validOutfits.first;
    }

    return null;
  }
}
