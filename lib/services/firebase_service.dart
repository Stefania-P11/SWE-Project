import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import '../models/item.dart';
import '../models/outfit.dart';
class FirebaseService{
  //Reusable Firestore instance
  static FirebaseFirestore db = FirebaseFirestore.instance;
  
  //removes item from firestore
  int removeFirestoreItem(Item item){
    db.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).delete();
    return 0;
  }
  //removes item locally
  int removeLocalItem(Item item){
    Outfit.outfitList.removeWhere((outfit) => outfit.topItem.id == item.id || outfit.bottomItem.id == item.id || outfit.shoeItem.id == item.id);
    Item.itemList.removeWhere((element) => element.id == item.id);
    return 0;
  }
  //edits item in Firestore
  int editFirestoreItemDetails(Item item, String label, String category, List<String> weather){
    final itemToSet = {
      'category' : item.category,
      'label' : item.label,
      'weather' : item.weather
    };
    db.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).set(itemToSet, SetOptions(merge : true));
    return 0;
  }

  //edits item in local Item.itemList which contains referenes to all items
  int editLocalItemDetails(Item item, String label, String category, List<String> weather){
    if(label != ''){
      item.label = label;
    }
    if(category != ''){
      item.category = category;
    }
    if(weather != []){
      item.weather = weather;
    }
    return 0;
  }
  //remove outfit from Firestore
  int removeFirestoreOutfit(Outfit outfit){
    return 0;
  }
  //remove local outfit from Outfit.outfitList
  int removeLocalOutfit(Outfit outfit){
    return 0;
  }
  //int addFirestoreOutfit()
  //int addLocalOutfit()
}