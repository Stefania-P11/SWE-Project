import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/choose_item_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/item_container.dart';
import 'package:dressify_app/widgets/label_input_field.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/widgets/custom_button.dart';
import 'package:dressify_app/services/firebase_service.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/models/item.dart';

/// Screen for creating an outfit where users can select items and name their outfit.
class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  // URLs to store the selected item images for top, bottom, and shoes
  String? topUrl;
  String? bottomUrl;
  String? shoesUrl;

  void _saveNewOutfit() {
    if (topUrl == null || bottomUrl == null || shoesUrl == null) {
      debugPrint(
          'Please select your top, bottom and shoes to create an outfit.');
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
    // Convert the selected URLs to actual Item objects.
    // (Assumes that you have a helper method to look up an Item by its URL.)
    final Item? topItem = Item.getItemByUrl(topUrl!);
    final Item? bottomItem = Item.getItemByUrl(bottomUrl!);
    final Item? shoeItem = Item.getItemByUrl(shoesUrl!);

    if (topItem == null || bottomItem == null || shoeItem == null) {
      debugPrint("Failed to retrieve one or more Items for the outfit.");

      return;
    }
    // Use the outfit name from the text field (or assign a default)
    String label = outfitNameController.text.trim();
    if (label.isEmpty) {
      label = "Outfit ${Outfit.outfitList.length + 1}";
    }

    // Generate an outfit ID; here, we simply use length+1 as an example.
    int newId = Outfit.outfitList.length + 1;
    debugPrint("NewId: \"$newId\" ");
    // Set default values for times worn and weather
    int timesWorn = 0;
    List<String> weather = topItem
        .weather; // Default assign weather for new outfit as top weather.

    // Save the outfit to Firestore and locally (assuming these methods are defined in your FirebaseService)
    FirebaseService.addFirestoreOutfit(
        label, newId, topItem, bottomItem, shoeItem, timesWorn, weather);
    FirebaseService.addLocalOutfit(
        label, newId, topItem, bottomItem, shoeItem, timesWorn, weather);

    debugPrint("Outfit saved successfully!");

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Outfit saved successfully!"),
          content: Text("Your new outfit \"$label\" is saved to your List."),
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

  // Controller to handle text input for the outfit name
  final TextEditingController outfitNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Get screen width and height for responsive UI
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Set background color using a constant defined in constants.dart
      backgroundColor: kBackgroundColor,

      // Use a custom app bar with a back button
      appBar: CustomAppBar(
        showBackButton: true,
      ), // Replaces the hamburger menu icon with a back arrow to allow the user to go back

      // Main body content
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.5, // Scroll area height
              width: screenWidth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side: Top item (full height)
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Your background color
                          borderRadius: BorderRadius.circular(
                              8), // Optional rounded corners
                        ),
                        child: outfitItem(
                          "Top",
                          screenWidth,
                          onTap: () async {
                            final selectedItemUrl = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChooseItemScreen(category: "Top"),
                              ),
                            );
                            if (selectedItemUrl != null) {
                              setState(() {
                                topUrl = selectedItemUrl;
                              });
                            }
                          },
                          imageUrl: topUrl,
                        ),
                      ),
                    ),

                    // Horizontal spacing between Top and the right column
                    const SizedBox(width: 16),

                    // Right side: Column with Bottom and Shoes
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bottom item with flex 2
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Your background color
                                borderRadius: BorderRadius.circular(
                                    8), // Optional rounded corners
                              ),
                              child: outfitItem(
                                "Bottom",
                                screenWidth,
                                onTap: () async {
                                  final selectedItemUrl = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChooseItemScreen(category: "Bottom"),
                                    ),
                                  );
                                  if (selectedItemUrl != null) {
                                    setState(() {
                                      bottomUrl = selectedItemUrl;
                                    });
                                  }
                                },
                                imageUrl: bottomUrl,
                              ),
                            ),
                          ),

                          // Vertical spacing between Bottom and Shoes
                          const SizedBox(height: 16),

                          // Shoes item as a square box using AspectRatio
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Your background color
                                borderRadius: BorderRadius.circular(
                                    8), // Optional rounded corners
                              ),
                              child: outfitItem(
                                "Shoes",
                                screenWidth,
                                onTap: () async {
                                  final selectedItemUrl = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChooseItemScreen(category: "Shoes"),
                                    ),
                                  );
                                  if (selectedItemUrl != null) {
                                    setState(() {
                                      shoesUrl = selectedItemUrl;
                                    });
                                  }
                                },
                                imageUrl: shoesUrl,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Input field to name the outfit using LabelInputField widget
            LabelInputField(
              controller: outfitNameController,
              hintText: "Add a name for your outfit",
            ),

            // Add spacing between the input field and the next element
            SizedBox(height: screenHeight * 0.03),
            //Add Save Button here!
            CustomButton(
              onPressed: _saveNewOutfit,
              text: 'Save Outfit',
            )
          ],
        ),
      ),
    );
  }
}
