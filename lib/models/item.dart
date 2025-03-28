
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
  static int topCount = 0;
  static int bottomCount = 0;
  static int shoeCount = 0;
  Item({required this.category, required this.color, required this.id, required this.label, required this.timesWorn, required this.url, required this.weather});

  factory Item.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Item(
      category : data['category'],
      color : data['color'],
      id : data['id'],
      label : data['label'],
      timesWorn : data['timesWorn'],
      url : data['url'],
      weather : data['weather'],
    );
  }
  static Future<void> fetchItems(String username) async{
    FirebaseFirestore db = FirebaseFirestore.instance;  
    QuerySnapshot querySnapshot = await db.collection('users').doc(username).collection("Clothes").get();
    itemList = querySnapshot.docs.map((doc) => Item.fromFirestore(doc)).toList();
  }
  static Future<void> countItemsPerCategory() async{
    for(Item x in itemList){
      if(x.category == 'Top'){
        Item.topCount++;
      }else if(x.category == 'Bottom'){
        Item.bottomCount++;
      }else if(x.category == 'Shoes'){
        Item.shoeCount++;
      }
    }
  }
}