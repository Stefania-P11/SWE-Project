import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/choose_item_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            
            // Scrollable Outfit Image Section
            SizedBox(
              height: screenHeight * 0.72, // Scroll area height
              width: screenWidth,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.8),
                  child: SizedBox(
                    height: screenHeight * 0.8,
                    child: Stack(
                      children: [
                        
                        // Top Item Section
                        Positioned(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.0,
                          child: outfitItem(
                            "Top",
                            screenWidth,
                            onTap: () async {
                              
                              // Navigate to ChooseItemScreen to select a Top
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Top"),
                                ),
                              );

                              // Update topUrl if a valid item is selected
                              if (selectedItemUrl != null) {
                                setState(() {
                                  topUrl = selectedItemUrl;
                                });
                              }
                            },
                            
                            // Show selected Top item image if available
                            imageUrl: topUrl,
                          ),
                        ),

                        // Bottom Item Section
                        Positioned(
                          top: screenHeight * 0.25,
                          right: screenWidth * 0.0,
                          child: outfitItem(
                            "Bottom",
                            screenWidth,
                            onTap: () async {
                             
                             // Navigate to ChooseItemScreen to select Bottom
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Bottom"),
                                ),
                              );

                              // Update bottomUrl if a valid item is selected
                              if (selectedItemUrl != null) {
                                setState(() {
                                  bottomUrl = selectedItemUrl;
                                });
                              }
                            },
                            
                            // Show selected Bottom item image if available
                            imageUrl: bottomUrl,
                          ),
                        ),

                        // Shoes Item Section
                        Positioned(
                          top: screenHeight * 0.45,
                          left: screenWidth * 0.0,
                          child: outfitItem(
                            "Shoes",
                            screenWidth,
                            onTap: () async {
                             
                             // Navigate to ChooseItemScreen to select Shoes
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Shoes"),
                                ),
                              );

                              // Update shoesUrl if a valid item is selected
                              if (selectedItemUrl != null) {
                                setState(() {
                                  shoesUrl = selectedItemUrl;
                                });
                              }
                            },
                            
                            // Show selected Shoes item image if available
                            imageUrl: shoesUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Input field to name the outfit using LabelInputField widget
            LabelInputField(
              controller: outfitNameController,
              hintText: "Add a name for your outfit",
            ),

            // Add spacing between the input field and the next element
            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
