import 'package:dressify_app/models/item.dart';

/// A service that handles fetching items from Firestore.
class ItemService {
  /// Fetch items from Firestore and filter them by category.
  Future<List<Item>> fetchItemsByCategory(String category, String username) async {
    try {
      // Fetch items from Firestore
      await Item.fetchItems(username); // Fetch all items

      // Filter items by category
      return Item.itemList
          .where((item) => item.category == category)
          .toList();
    } catch (e) {
      print("Error loading items: $e");
      return []; // Return an empty list on error
    }
  }
}
