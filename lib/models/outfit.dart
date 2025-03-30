import 'package:cloud_firestore/cloud_firestore.dart';
import 'item.dart';
class Outfit{
  late final int id;
  late String label;
  Item topItem;
  Item bottomItem;
  Item shoeItem;
  late int timesWorn;
  late List<String> weather;
  static int outfitCount = 0;
  static List<Outfit> outfitList = [];
  Outfit({required this.id, required this.label, required this.topItem, required this.bottomItem, required, required this.shoeItem, required this.timesWorn, required this.weather});

  factory Outfit.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    int top = data['topID'];
    Item topItem = Item.itemList.firstWhere((item) => item.id == top);
    int bottom = data['bottomID'];
    Item bottomItem = Item.itemList.firstWhere((item) => item.id == bottom);
    int shoes = data['shoesID'];
    Item shoeItem = Item.itemList.firstWhere((item) => item.id == shoes);
    List<String> weatherList = [];
    List.from(data['weather']).forEach((element){
      String weatherCategory = element;
      weatherList.add(weatherCategory);
    });
    return Outfit(
      id : (data['id'] ?? 0),
      label : data['label'] ?? ' ',
      topItem : topItem,
      bottomItem : bottomItem,
      shoeItem : shoeItem,
      timesWorn : (data['timesWorn'] ?? 0),
      weather : weatherList
    );

  }

  static Future<void> fetchOutfits(String username) async{
    FirebaseFirestore db = FirebaseFirestore.instance;  
    QuerySnapshot querySnapshot = await db.collection('users').doc(username).collection("Outfits").get();
    outfitList = querySnapshot.docs.map((doc) => Outfit.fromFirestore(doc)).toList();
  }

  static Future<void> countOutfits(String username) async{
    outfitCount = outfitList.length;
  }
}