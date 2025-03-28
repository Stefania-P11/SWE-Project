import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Import custom bottom navigation bar widget
import 'package:dressify_app/widgets/custom_button_2.dart'; // Import custom button 2 (if needed for additional actions)
import 'package:dressify_app/widgets/custom_button_3.dart'; // Import custom button 3 (if needed for actions)
import 'package:dressify_app/widgets/item_container.dart'; // Import custom item container for outfit items
import 'package:flutter/material.dart'; // Import Flutter Material Design package
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts for text styling

// NOTE: I DO NOT THINK WE NEED THE NAME YOUR OUTFIT FIELD HERE BECAUSE WE WILL ONLY NAME IT WHEN
// WE SAVE IT TO FAVORITES. IN WHICH CASE-- WHEN THE HEART IS TAPPED, WE CAN BRING A POP-UP FIELD
// THAT ASKS FOR A NAME.

/// OutfitSuggestionScreen - Displays an outfit suggestion
/// Allows users to:
/// - View suggested outfit components (Top, Bottom, Shoes)
/// - Add the outfit to favorites
/// - Regenerate a new outfit
class OutfitSuggestionScreen extends StatefulWidget {
  const OutfitSuggestionScreen({super.key});

  @override
  State<OutfitSuggestionScreen> createState() =>
      _OutfitSuggestionScreenState(); // Create state for the screen
}

class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
  // Boolean to track if the outfit is marked as a favorite
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Set background color using the value defined in constants.dart
      backgroundColor: kBackgroundColor,

      // Custom app bar with a back button enabled to allow the user to navigate back
      appBar: CustomAppBar(
        showBackButton: true,
      ),

      // Main body content
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding around the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Scrollable Outfit Image Section
            SizedBox(
              height: screenHeight * 0.72, // Height of the scrollable section
              width: screenWidth, // Full width of the screen
              child: SingleChildScrollView(
                // Enables scrolling when the content is larger than the viewable area
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.8), // Add padding
                  child: SizedBox(
                    height: screenHeight * 0.8, // Height for outfit container
                    child: Stack(
                      children: [
                        // Display Top item at the top
                        Positioned(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.0,
                          child: outfitItem("Top", screenWidth),
                        ),
                        // Display Bottom item below Top
                        Positioned(
                          top: screenHeight * 0.25,
                          right: screenWidth * 0.0,
                          child: outfitItem("Bottom", screenWidth),
                        ),
                        // Display Shoes item at the bottom
                        Positioned(
                          top: screenHeight * 0.45,
                          left: screenWidth * 0.0,
                          child: outfitItem("Shoes", screenWidth),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Add spacing between outfit display and buttons
            SizedBox(height: screenHeight * 0.03),

            // Buttons Row for Favorite and Regenerate actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Heart icon to mark/unmark outfit as a favorite
                IconButton(
                  iconSize: screenWidth * 0.1, // Icon size relative to screen width
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? Colors.red
                        : Colors.black, // Change color based on favorite status
                  ),
                  onPressed: () {
                    setState(() {
                      // Toggle the favorite state
                      isFavorite = !isFavorite;
                    });

                    // TODO: Add favorite logic here
                    // Add logic to save/remove the outfit from favorites
                    // Display a pop-up asking for a name when the outfit is added to favorites
                  },
                ),

                // Regenerate outfit button to suggest a new outfit
                IconButton(
                  iconSize: screenWidth * 0.1, // Icon size relative to screen width
                  icon: const Icon(Icons.autorenew), // Icon for regenerating outfit
                  onPressed: () {
                    // TODO: Add regenerate logic here
                    // Add logic to generate a new outfit dynamically
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
