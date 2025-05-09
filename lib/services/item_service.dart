import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/item.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
/// A service that handles fetching items from Firestore.
class ItemService {
  
  
  
  /// Fetch items from Firestore and filter them by category.
  Future<List<Item>> fetchItemsByCategory(String category, String kUsername, {FirebaseFirestore? firestore}) async {
    try {
      // Fetch items from Firestore and pass the fake Firestore 
      await Item.fetchItems(kUsername, firestore: firestore); // Fetch all items

      // Filter items by category
      return Item.itemList
          .where((item) => item.category == category)
          .toList();
    } catch (e) {
      print("Error loading items: $e");
      return []; // Return an empty list on error
    }
  }

  /// Fetch items and count them by category.
  Future<Map<String, int>> fetchAndCountItems(String kUsername,{FirebaseFirestore? firestore}) async {
    try {
      // Fetch items from Firestore
      await Item.fetchItems(kUsername,firestore: firestore);
      await Item.countItemsPerCategory();

      // Return item counts for different categories
      return {
        'topCount': Item.topCount,
        'bottomCount': Item.bottomCount,
        'shoeCount': Item.shoeCount,
      };
    } catch (e) {
      print("Error fetching item data: $e");
      return {
        'topCount': 0,
        'bottomCount': 0,
        'shoeCount': 0,
      }; // Return default values on error
    }
  }
}
