import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/choose_item_screen.dart';
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

              // SAVE button
              CustomButton3(
                label: "SAVE",
                onPressed: () {
                  // TODO: Handle save logic
                  print("Save pressed: ${outfitNameController.text}");
                },
                isActive:
                    (topUrl != null && bottomUrl != null && shoesUrl != null),
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