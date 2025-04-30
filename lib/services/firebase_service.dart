import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService{
  //Reusable Firestore instance
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  static final storage = FirebaseStorage.instance;
  //removes item from firestore
  static removeFirestoreItem(Item item){
    db.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).delete();
    return 0;
  }
  //removes item locally
  static removeLocalItem(Item item){
    //first removes any outfits that has the item as a component
    Outfit.outfitList.removeWhere((outfit) => outfit.topItem.id == item.id || outfit.bottomItem.id == item.id || outfit.shoeItem.id == item.id);
    //removes item locally
    Item.itemList.removeWhere((element) => element.id == item.id);
    return 0;
  }
  //edits item in Firestore
  static editFirestoreItemDetails(Item item, String label, String category, List<String> weather){
    final itemToSet = {
      'category' : item.category,
      'label' : item.label,
      'weather' : item.weather
    };
    db.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).set(itemToSet, SetOptions(merge : true));
    return 0;
  }

  //edits item in local Item.itemList
  static editLocalItemDetails(Item item, String label, String category, List<String> weather){
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
  static addFirestoreOutfit(String label, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather){
    final outfitStorage = {
      'label' : label,
      'id' : id,
      'topID' : top.id, // updated to topID to match what Outfit.fromFirestore expects
      'bottomID' : bottom.id, // updated to bottomID to match what Outfit.fromFirestore expects
      'shoesID' : shoes.id, // updated to shoesID to match what Outfit.fromFirestore expects
      'timesWorn' : timesWorn,
      'weather' : weather,
    };

      db.collection('users')
    .doc(kUsername)
    .collection('Outfits')
    .doc(id.toString())
    .set(outfitStorage);

    return 0;
  }

  //add outfit locally
  static addLocalOutfit(String category, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather){
    //Calls outfit constructor and then add it to Outfit.outfitList
    Outfit outfitSet = Outfit(
      label : category,
      id : id,
      topItem : top,
      bottomItem : bottom,
      shoeItem : shoes,
      timesWorn : timesWorn,
      weather : weather,
    );

    Outfit.outfitList.add(outfitSet);
    return 0;
  }

  //remove outfit from Firestore
  static removeFirestoreOutfit(Outfit outfit){
    db.collection('users').doc(kUsername).collection('Outfits').doc(outfit.id.toString()).delete();
    return 0;
  }

  //remove local outfit from Outfit.outfitList. Outfit arg should already be a part of outfitList, so this is trivial
  static removeLocalOutfit(Outfit outfit){
    //remove outfit from Outfit.outfitList if outfit.id matches list element's id
    Outfit.outfitList.removeWhere((o) => o.id == outfit.id);
    return 0;
  }

  // Add new item to Firestore
  static Future<void> addFirestoreItem(Item item) async {
    final itemMap = {
      'category': item.category,
      'label': item.label,
      'weather': item.weather,
      'url': item.url,
      'id': item.id,
      'timesWorn': 0,
    };

    await db
        .collection('users')
        .doc(kUsername)
        .collection('Clothes')
        .doc(item.id.toString())
        .set(itemMap);

  // Add the item to the local item list
  Item.itemList.add(item);
        
  }

  //check if Outfit is in Favorite
  static Future<bool> isOutfitFavorited(int topID, int bottomID, int shoeID) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(kUsername);
    final favorites = await userDoc.collection('FavoriteOutfits')
        .where('topID', isEqualTo: topID)
        .where('bottomID', isEqualTo: bottomID)
        .where('shoeID', isEqualTo: shoeID)
        .get();

    return favorites.docs.isNotEmpty;
  }

}