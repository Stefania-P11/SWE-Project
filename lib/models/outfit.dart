import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';

class Outfit {
  late final int id;
  late String label;
  Item topItem;
  Item bottomItem;
  Item shoeItem;
  late int timesWorn;
  late List<String> weather;
  static int outfitCount = 0;
  static List<Outfit> outfitList = [];

  /// Constructor to initialize Outfit properties
  Outfit({
    required this.id,
    required this.label,
    required this.topItem,
    required this.bottomItem,
    required this.shoeItem,
    required this.timesWorn,
    required this.weather,
  });

  /// Factory method to create an Outfit from Firestore document
  factory Outfit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Print document data to debug
    print('Document Data: $data');

    // Extract IDs from Firestore document
    int top = data['topID'] ?? -1;
    int bottom = data['bottomID'] ?? -1;
    int shoes = data['shoesID'] ?? -1;

    // Ensure itemList is populated before looking for items
    if (Item.itemList.isEmpty) {
      print('Error: Item list is empty!');
      throw Exception('Item list is not initialized or empty');
    }

    /// Get top item or fallback to default item if not found
    Item topItem = _findItemById(top, 'Top');

    /// Get bottom item or fallback to default item if not found
    Item bottomItem = _findItemById(bottom, 'Bottom');

    /// Get shoes item or fallback to default item if not found
    Item shoeItem = _findItemById(shoes, 'Shoes');

    // Map weather array correctly, ensure data exists
    List<String> weatherList = [];
    if (data.containsKey('weather') && data['weather'] != null) {
      weatherList = List<String>.from(data['weather']);
    }

    // Print outfit creation for debug
    print('Outfit created: ${data['label']}');

    // Return outfit with validated data
    return Outfit(
      id: (data['id'] ?? 0),
      label: data['label'] ?? 'Unknown Outfit',
      topItem: topItem,
      bottomItem: bottomItem,
      shoeItem: shoeItem,
      timesWorn: (data['timesWorn'] ?? 0),
      weather: weatherList,
    );
  }

  /// Helper method to find an item by ID or return a fallback item
  static Item _findItemById(int id, String category) {
    return Item.itemList.firstWhere(
      (item) => item.id == id,
      orElse: () {
        print('Error: $category item with ID $id not found');
        return Item(
          id: -1,
          category: category,
          label: 'Unknown $category',
          timesWorn: 0,
          url: '',
          weather: [],
        );
      },
    );
  }

  /// Fetch outfits from Firestore for a given user
  static Future<void> fetchOutfits(String username) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    QuerySnapshot querySnapshot =
        await db.collection('users').doc(username).collection("Outfits").get();

    print('Fetched ${querySnapshot.docs.length} outfits.');

    // Map Firestore documents to Outfit objects
    outfitList = querySnapshot.docs.map((doc) {
      try {
        return Outfit.fromFirestore(doc);
      } catch (e) {
        print('Error creating outfit: $e');
        return Outfit(
          id: 0,
          label: 'Error Outfit',
          topItem: Item(
            id: -1,
            category: 'Top',
            label: 'Unknown Top',
            timesWorn: 0,
            url: '',
            weather: [],
          ),
          bottomItem: Item(
            id: -1,
            category: 'Bottom',
            label: 'Unknown Bottom',
            timesWorn: 0,
            url: '',
            weather: [],
          ),
          shoeItem: Item(
            id: -1,
            category: 'Shoes',
            label: 'Unknown Shoes',
            timesWorn: 0,
            url: '',
            weather: [],
          ),
          timesWorn: 0,
          weather: [],
        );
      }
    }).toList();
  }

  /// Count number of outfits loaded
  static Future<void> countOutfits(String username) async {
    outfitCount = outfitList.length;
    print('Total outfits: $outfitCount');
  }

  /// Create an Outfit from a list of Items returned by surpriseMe()
  factory Outfit.fromSurpriseMe({
    required Item top,
    required Item bottom,
    required Item shoe,
    required String tempCategory,
  }) {
    return Outfit(
      id: DateTime.now().millisecondsSinceEpoch,
      label: 'Surprise Me Outfit',
      topItem: top,
      bottomItem: bottom,
      shoeItem: shoe,
      timesWorn: 0,
      weather: [tempCategory], // ✅ Use actual temperature category
    );
  }

  factory Outfit.fromItemList(List<Item> items) {
    final top = items.firstWhere(
      (i) => i.category.toLowerCase().contains('top'),
      orElse: () => Item(
        id: -1,
        category: 'Top',
        label: 'Unknown Top',
        timesWorn: 0,
        url: '',
        weather: [],
      ),
    );

    final bottom = items.firstWhere(
      (i) => i.category.toLowerCase().contains('bottom'),
      orElse: () => Item(
        id: -1,
        category: 'Bottom',
        label: 'Unknown Bottom',
        timesWorn: 0,
        url: '',
        weather: [],
      ),
    );

    final shoe = items.firstWhere(
      (i) => i.category.toLowerCase().contains('shoe'),
      orElse: () => Item(
        id: -1,
        category: 'Shoe',
        label: 'Unknown Shoe',
        timesWorn: 0,
        url: '',
        weather: [],
      ),
    );

    return Outfit(
      id: DateTime.now().millisecondsSinceEpoch,
      label: 'Surprise Me Outfit',
      topItem: top,
      bottomItem: bottom,
      shoeItem: shoe,
      timesWorn: 0,
      weather: top.weather
          .toSet()
          .intersection(bottom.weather.toSet())
          .intersection(shoe.weather.toSet())
          .toList(),
    );
  }

  ///Save outfits to Firestore for Like, Dislike and Heart buttons
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'topID': topItem.id,
      'bottomID': bottomItem.id,
      'shoesID': shoeItem.id,
      'timesWorn': timesWorn,
      'weather': weather,
      'createdAt': Timestamp.now(),
    };
  }
}
