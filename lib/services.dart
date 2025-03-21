import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;
const String username = "dummy";

/// After a user takes a photo and provides item details such as name for the clothing and   
/// appropriate weather, all of that information is uploaded to the database.
/// *Parameters:
/// + image_filepath: The filepath of the image to upload
/// + name: The name of the clothing that the user provided
/// + weather: The appropriate weather to wear the clothing, provided by user
/// + category: What kind of item is it? Top, Bottom, or Shoe represented as int.
/// *Return: the generated id of the clothing that was uploaded
/// *Throws Firebase exception when there’s a failure to upload a photo/item
/// IllegalArgumentException when there is an illegal value
/// Exception when there is an error that does not fit in the above Exception types
/// Written By: Raymond
int uploadItem(String imageFilepath, String color, String label, String weather, int category){
  return 1;
}

/// This function deletes all the outfits associated with a particular item of clothing,
/// then deletes the item itself.
/// *Parameters:
/// + category: The category of the item that is to be deleted.
/// + itemId: The ID of the item that is to be deleted.
/// + user_name: The name of the user whose item should be deleted.
/// *Return: 0 on success
/// *Throws IllegalArgumentException when the category value is invalid.
int deleteItem(int category, String itemId, String username){
  return 1;
}
