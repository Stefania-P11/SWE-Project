
import 'package:cloud_firestore/cloud_firestore.dart';
class Item{
  late final String category;
  late final String color;
  late final int id;
  late final String label;
  int timesWorn;
  late final String url;
  late final String weather;
  static List<Item> itemList = [];
  Item({required this.category, required this.color, required this.id, required this.label, required this.timesWorn, required this.url, required this.weather});

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      category : data['category'] ?? '',
      color : data['color'] ?? '',
      id : (data['id'] ?? 0).toInteger(),
      label : data['label'] ?? '',
      timesWorn : (data['timesWorn'] ?? 0).toInteger(),
      url : data['url'] ?? '',
      weather : data['weather'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore(){
    return {
      'category' : category,
      'color' : color,
      'id' : id,
      "label" : label,
      'timesWorn' : timesWorn,
      'url' : url,
      'weather' : weather
    };
  }
  static Future<void> fetchItems(String username) async{
    FirebaseFirestore db = FirebaseFirestore.instance;  
    QuerySnapshot querySnapshot = await db.collection('users').doc(username).collection("Clothes").get();
    itemList = querySnapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
  }
}