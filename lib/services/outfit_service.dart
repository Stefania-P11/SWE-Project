import 'package:flutter/material.dart';
import 'package:dressify_app/services/firebase_service.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';

Future<void> saveNewOutfit({
  required BuildContext context,
  required String? topUrl,
  required String? bottomUrl,
  required String? shoesUrl,
  required String label,
}) async {
  // Validate that all URLs are provided.
  if (topUrl == null || bottomUrl == null || shoesUrl == null) {
    debugPrint('Please select your top, bottom and shoes to create an outfit.');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid Outfit!"),
          content: const Text(
              "Please select your top, bottom, and shoes item to create a new Outfit."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the popup
              },
              child: const Text("Back"),
            ),
          ],
        );
      },
    );
    return;
  }

  // Convert URLs to actual Item objects.
  final Item? topItem = Item.getItemByUrl(topUrl);
  final Item? bottomItem = Item.getItemByUrl(bottomUrl);
  final Item? shoeItem = Item.getItemByUrl(shoesUrl);

  if (topItem == null || bottomItem == null || shoeItem == null) {
    debugPrint("Failed to retrieve one or more Items for the outfit.");
    // Optionally, add user feedback here.
    return;
  }

  // Use the outfit name from the text field, or assign a default.
  final String outfitLabel =
      label.isEmpty ? "Outfit ${Outfit.outfitList.length + 1}" : label;

  // Generate an outfit ID; here, we simply use length+1 as an example.
  int newId = Outfit.outfitList.length + 1;
  debugPrint("NewId: \"$newId\"");

  // Set default values for times worn and weather.
  int timesWorn = 0;
  List<String> weather = topItem.weather; // Default weather based on top item.

  // Save the outfit to Firestore and locally.
  await FirebaseService.addFirestoreOutfit(
    outfitLabel,
    newId,
    topItem,
    bottomItem,
    shoeItem,
    timesWorn,
    weather,
  );
  await FirebaseService.addLocalOutfit(
    outfitLabel,
    newId,
    topItem,
    bottomItem,
    shoeItem,
    timesWorn,
    weather,
  );

  debugPrint("Outfit saved successfully!");

  // Pop the current screen, then show a success dialog.
  Navigator.pop(context);
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Outfit saved successfully!"),
        content:
            Text("Your new outfit \"$outfitLabel\" is saved to your List."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Dismiss the popup
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}
