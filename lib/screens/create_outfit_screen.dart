import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/screens/choose_item_screen.dart';
import 'package:dressify_app/services/firebase_service.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_button_3.dart';
import 'package:dressify_app/widgets/item_container.dart';
import 'package:dressify_app/widgets/label_input_field.dart';
import 'package:flutter/material.dart';

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

  // List of weather conditions for the outfit
  List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];
  // Selected temperatures for the outfit
  List<String> selectedTemperatures = [];

  // Controller to handle text input for the outfit name
  final TextEditingController outfitNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Future<void> handleSave({
      required BuildContext context,
      required String label,
      required List<String> weather,
      required String topUrl,
      required String bottomUrl,
      required String shoesUrl,
    }) async {
      // Get selected items from URLs
      final topItem = Item.itemList.firstWhere((item) => item.url == topUrl);
      final bottomItem =
          Item.itemList.firstWhere((item) => item.url == bottomUrl);
      final shoesItem =
          Item.itemList.firstWhere((item) => item.url == shoesUrl);

      final id = DateTime.now().millisecondsSinceEpoch;

      // Save to Firestore
      await FirebaseService.addFirestoreOutfit(
        label,
        id,
        topItem,
        bottomItem,
        shoesItem,
        0,
        weather,
      );

      // Save locally
      FirebaseService.addLocalOutfit(
        label,
        id,
        topItem,
        bottomItem,
        shoesItem,
        0,
        weather,
      );

      // Return to previous screen with success flag
      Navigator.pop(context, true);
    }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Outfit items stack
              SizedBox(
                height: screenHeight * 0.7,
                child: Stack(
                  children: [
                    // Top item
                    Positioned(
                      top: screenHeight * 0.03,
                      left: 0,
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

                    // Bottom item
                    Positioned(
                      top: screenHeight * 0.25,
                      right: 0,
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

                    // Shoes item
                    Positioned(
                      top: screenHeight * 0.45,
                      left: 0,
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
                  ],
                ),
              ),

              // Spacing
              const SizedBox(height: 10),

              // Input field
              LabelInputField(
                controller: outfitNameController,
                hintText: "Add a name for your outfit",
              ),

              // Temperature selection
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Temperature", style: kH3),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: temperatures.map((temp) {
                      final isSelected = selectedTemperatures.contains(temp);
                      return ChoiceChip(
                        label: Text(temp,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            )),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              selectedTemperatures.add(temp);
                            } else {
                              selectedTemperatures.remove(temp);
                            }
                          });
                        },
                        selectedColor: Colors.black,
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // SAVE button
              CustomButton3(
                label: "SAVE",
                onPressed: () {
                  handleSave(
                    context: context,
                    label: outfitNameController.text,
                    weather: selectedTemperatures,
                    topUrl: topUrl!,
                    bottomUrl: bottomUrl!,
                    shoesUrl: shoesUrl!,
                  );
                },
                isActive: (topUrl != null &&
                    bottomUrl != null &&
                    shoesUrl != null &&
                    selectedTemperatures.isNotEmpty),
              ),

              const SizedBox(height: 30), // Extra bottom space
            ],
          ),
        ),
      ),
    );
  }
}
  /// Widget to display an outfit item with a label and image.