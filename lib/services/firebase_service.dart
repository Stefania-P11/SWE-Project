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
    //first removes any outfits that has the item as a component
    Outfit.outfitList.removeWhere((outfit) => outfit.topItem.id == item.id || outfit.bottomItem.id == item.id || outfit.shoeItem.id == item.id);
    //removes item locally
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

  //edits item in local Item.itemList
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

  //add outfit to Firestore
  int addFirestoreOutfit(String category, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather){
    return 0;
  }

  //add outfit locally
  int addLocalOutfit(String category, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather){
    //Calls outfit constructor and then add it to Outfit.outfitList
    return 0;
  }
  
  //remove outfit from Firestore
  int removeFirestoreOutfit(Outfit outfit){
    return 0;
  }

  //remove local outfit from Outfit.outfitList. Outfit arg should already be a part of outfitList, so this is trivial
  int removeLocalOutfit(Outfit outfit){
    //remove outfit from Outfit.outfitList if outfit.id matches list element's id
    return 0;
  }
}