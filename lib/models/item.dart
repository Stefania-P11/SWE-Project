import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';

// Item class to model clothing items
class Item {
  // Properties to store item details
  late String category;        // Category of the item (e.g., Top, Bottom, Shoes)
  late final int id;            // Unique ID for the item
  late String label;           // Label or name of the item
  int timesWorn;                // Number of times the item has been worn
  late final String url;        // URL for the item's image
  late List<String> weather;    // Weather conditions suited for the item

  // Static list to store fetched items
  static List<Item> itemList = [];

   static bool isLoaded = false; 

  // Static counters to store item counts by category
  static int topCount = 0;      // Count of tops
  static int bottomCount = 0;   // Count of bottoms
  static int shoeCount = 0;     // Count of shoes

  // Constructor to initialize an Item
  Item({
    required this.category,
    required this.id,
    required this.label,
    required this.timesWorn,
    required this.url,
    required this.weather,
  });

  // Factory constructor to create an Item from Firestore data
  factory Item.fromFirestore(DocumentSnapshot doc) {
    // Map Firestore document data to a Map
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<String> weatherList = [];
    List.from(data['weather']).forEach((element){
      String weatherCategory = element;
      weatherList.add(weatherCategory);
    });
    // Create and return an Item with data from Firestore
    return Item(
      category: data['category'],   // Assign category from Firestore
      id: data['id'],               // Assign item ID from Firestore
      label: data['label'],         // Assign label from Firestore
      timesWorn: data['timesWorn'] ?? 0,// Assign times worn from Firestore
      url: data['url'],             // Assign URL from Firestore
      weather: weatherList          // Assign weather array from Firestore
    );
  }

  // Fetch items from Firestore and populate itemList
  static Future<void> fetchItems(String username) async {
    FirebaseFirestore db = FirebaseFirestore.instance;

    // Query to get items from the "Clothes" collection of the user
    QuerySnapshot querySnapshot = await db
        .collection('users')
        .doc(kUsername)
        .collection("Clothes")
        .get();

    // Map each document to an Item and populate itemList
    itemList = querySnapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
  }

  // Count items per category (Top, Bottom, Shoes)
  static Future<void> countItemsPerCategory() async {
    // Reset counters to avoid double counting
    Item.topCount = 0;
    Item.bottomCount = 0;
    Item.shoeCount = 0;

    // Iterate through itemList and count items by category
    for (Item x in itemList) {
      if (x.category == 'Top') {
        Item.topCount++; // Increment top counter if category is 'Top'
      } else if (x.category == 'Bottom') {
        Item.bottomCount++; // Increment bottom counter if category is 'Bottom'
      } else if (x.category == 'Shoes') {
        Item.shoeCount++; // Increment shoe counter if category is 'Shoes'
      }
    }
  }
}
