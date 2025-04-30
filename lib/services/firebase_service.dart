import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:collection/collection.dart';
//import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService{
  //Reusable Firestore instance
  static final FirebaseFirestore db = FirebaseFirestore.instance;
  //static final storage = FirebaseStorage.instance;
  //removes item from firestore
  static Future<void> removeFirestoreItem(FirebaseFirestore firestore, Item item) async{
    if(item.id < 0){
      throw ArgumentError();
    }
    if(await doesItemExist(firestore, item.id) == false){
      throw ArgumentError();
    }
    firestore.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).delete();
  }
  //removes item locally
  static removeLocalItem(Item item){
    //first removes any outfits that has the item as a component
    if(item.id < 0 || !Item.itemList.contains(item)){
      throw ArgumentError();
    }
    Outfit.outfitList.removeWhere((outfit) => outfit.topItem.id == item.id || outfit.bottomItem.id == item.id || outfit.shoeItem.id == item.id);
    //removes item locally
    Item.itemList.removeWhere((element) => element.id == item.id);
    return 0;
  }
  //edits item in Firestore
  static editFirestoreItemDetails(FirebaseFirestore firestore, Item item, String label, String category, List<String> weather) async{
    final itemToSet = {
      'category' : item.category,
      'label' : item.label,
      'weather' : item.weather
    };
    if(item.category != 'Top' && item.category != 'Bottom' && item.category != 'Shoes'){
      throw ArgumentError();
    }
    if(item.label == '' || item.label.length > 15){
      throw ArgumentError();
    }
    if(item.weather.isEmpty){
      throw ArgumentError();
    }
    List<String> duplicateList = [];
    for(String weatherCat in item.weather){
      if((weatherCat != 'Hot' && weatherCat != 'Warm' && weatherCat != 'Cool' && weatherCat!= 'Cold') || duplicateList.contains(weatherCat)){
        throw ArgumentError();
      }
      duplicateList.add(weatherCat);
    }
    if(item.id < 0){
      throw ArgumentError();
    }
    if(await doesItemExist(firestore, item.id) == false){
      throw ArgumentError();
    }
    firestore.collection('users').doc(kUsername).collection('Clothes').doc(item.id.toString()).set(itemToSet, SetOptions(merge : true));
    return 0;
  }

  //edits item in local Item.itemList
  static editLocalItemDetails(Item item, String label, String category, List<String> weather){
    if(!Item.itemList.contains(item)){
      throw ArgumentError();
    }
    if(label.length > 15){
      throw ArgumentError();
    }
    if(category != 'Top' && category != 'Bottom' && category != 'Shoes' && category != ''){
      throw ArgumentError();
    }
    List<String> duplicateList = [];
    for(String weatherCat in weather){
      if((weatherCat != 'Hot' && weatherCat != 'Warm' && weatherCat != 'Cool' && weatherCat != 'Cold') || duplicateList.contains(weatherCat)){
        throw ArgumentError();
      }
      duplicateList.add(weatherCat);
    }
    if(label == '' && category == '' && weather.isEmpty){
      throw ArgumentError();
    }
    if(label != ''){
      item.label = label;
    }
    if(category != ''){
      item.category = category;
    }
    if(weather.isNotEmpty){
      item.weather = weather;
    }
    return 0;
  }

  //add outfit to Firestore
  static addFirestoreOutfit(FirebaseFirestore firestore, String label, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather) async{
    final outfitStorage = {
      'label' : label,
      'id' : id,
      'topID' : top.id, // updated to topID to match what Outfit.fromFirestore expects
      'bottomID' : bottom.id, // updated to bottomID to match what Outfit.fromFirestore expects
      'shoesID' : shoes.id, // updated to shoesID to match what Outfit.fromFirestore expects
      'timesWorn' : timesWorn,
      'weather' : weather,
    };
    if(timesWorn < 0 ){
      throw ArgumentError();
    }
    if(label == '' || label.length > 15){
      throw ArgumentError();
    }
    List<String> duplicateList = [];
    if(weather.isEmpty){
      throw ArgumentError();
    }
    for(String weatherCat in weather){
      if((weatherCat != 'Hot' && weatherCat != 'Warm' && weatherCat != 'Cool' && weatherCat != 'Cold') || duplicateList.contains(weatherCat)){
        throw ArgumentError();
      }
      duplicateList.add(weatherCat);
    }
    if(id < 0){
      throw ArgumentError();
    }
    final topSnapshot = await firestore.collection('users').doc(kUsername).collection('Clothes').doc(top.id.toString()).get();
    final bottomSnapshot = await firestore.collection('users').doc(kUsername).collection('Clothes').doc(bottom.id.toString()).get();
    final shoeSnapshot = await firestore.collection('users').doc(kUsername).collection('Clothes').doc(shoes.id.toString()).get();
    if(topSnapshot.exists == false || bottomSnapshot.exists == false || shoeSnapshot.exists == false){
      throw ArgumentError();
    }
    Map<String, dynamic> topData = topSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> bottomData = bottomSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> shoeData = shoeSnapshot.data() as Map<String, dynamic>;
    if(topData['category'] != 'Top'){
      throw ArgumentError();
    }
    if(bottomData['category'] != 'Bottom'){
      throw ArgumentError();
    }
    if(shoeData['category'] != 'Shoes'){
      throw ArgumentError();
    }
    if(await doesOutfitExist(firestore, id) == true){
      throw ArgumentError();
    }

    await firestore.collection('users')
    .doc(kUsername)
    .collection('Outfits')
    .doc(id.toString())
    .set(outfitStorage);

    return 0;
  }

  //add outfit locally
  static addLocalOutfit(String label, int id, Item top, Item bottom, Item shoes, int timesWorn, List<String> weather){
    //Calls outfit constructor and then add it to Outfit.outfitList
    if(!Item.itemList.contains(top) || top.category != 'Top'){
      throw ArgumentError();
    }
    if(!Item.itemList.contains(bottom) || bottom.category != 'Bottom'){
      throw ArgumentError();
    }
    if(!Item.itemList.contains(shoes) || shoes.category != 'Shoes'){
      throw ArgumentError();
    }
    if(label == '' || label.length > 15){
      throw ArgumentError();
    }
    if(id < 0 || Outfit.outfitList.firstWhereOrNull((o) => o.id == id) != null){
      throw ArgumentError();
    }
    if(timesWorn < 0){
      throw ArgumentError();
    }
    if(weather.isEmpty){
      throw ArgumentError();
    }
    List<String> duplicateList = [];
    for(String weatherCat in weather){
      if((weatherCat != 'Hot' && weatherCat != 'Warm' && weatherCat != 'Cool' && weatherCat !='Cold') || duplicateList.contains(weatherCat)){
        throw ArgumentError();
      }
      duplicateList.add(weatherCat);
    }
    Outfit outfitSet = Outfit(
      label : label,
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
  static removeFirestoreOutfit(FirebaseFirestore firestore, Outfit outfit) async{
    if(outfit.id < 0){
      throw ArgumentError();
    }
    if(await doesOutfitExist(firestore, outfit.id) == false){
      throw ArgumentError();
    }
    firestore.collection('users').doc(kUsername).collection('Outfits').doc(outfit.id.toString()).delete();
    return 0;
  }

  //remove local outfit from Outfit.outfitList. Outfit arg should already be a part of outfitList, so this is trivial
  static removeLocalOutfit(Outfit outfit){
    //remove outfit from Outfit.outfitList if outfit.id matches list element's id
    if(!Outfit.outfitList.contains(outfit)){
      throw ArgumentError();
    }
    Outfit.outfitList.removeWhere((o) => o.id == outfit.id);
    return 0;
  }

  // Add new item to Firestore
  static Future<void> addFirestoreItem(FirebaseFirestore firestore, Item item) async{
    if(!isValidItem(item)){
      throw ArgumentError();
    }
    if(await doesItemExist(firestore, item.id) == true){
      throw ArgumentError();
    }
    final itemMap = {
      'category': item.category,
      'label': item.label,
      'weather': item.weather,
      'url': item.url,
      'id': item.id,
      'timesWorn': 0,
    };

    await firestore
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
  //helper function to determine if Item has valid contents before uploading
  static bool isValidItem(Item item){
    if(item.category == '' || (item.category != 'Top' && item.category != 'Bottom' && item.category != 'Shoes')){
      return false;
    }
    if(item.id < 0){
      return false;
    }
    if(item.label == '' || item.label.length > 15){
      return false;
    }
    List<String> duplicateList = [];
    if(item.weather.isEmpty){
      return false;
    }
    for(String weatherCat in item.weather){
      if((weatherCat != 'Hot' && weatherCat != 'Warm' && weatherCat != 'Cool' && weatherCat!= 'Cold') || duplicateList.contains(weatherCat)){
        return false;
      }
      duplicateList.add(weatherCat);
    }
    if(item.timesWorn < 0){
      return false;
    }
    return true;
  }
  static Future<bool> doesItemExist(FirebaseFirestore firestore, int id) async {
    final docSnapshot = await firestore.collection('users').doc(kUsername).collection('Clothes').doc(id.toString()).get();
    return docSnapshot.exists;
  }
  static Future<bool> doesOutfitExist(FirebaseFirestore firestore, int id) async{
    final docSnapshot = await firestore.collection('users').doc(kUsername).collection('Outfits').doc(id.toString()).get();
    return docSnapshot.exists;
  }

}