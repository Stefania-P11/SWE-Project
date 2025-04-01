import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar widget
import 'package:dressify_app/widgets/item_container.dart'; // Import custom item container for outfit items
import 'package:flutter/material.dart'; // Import Flutter Material Design package

// NOTE: I DO NOT THINK WE NEED THE NAME YOUR OUTFIT FIELD HERE BECAUSE WE WILL ONLY NAME IT WHEN
// WE SAVE IT TO FAVORITES. IN WHICH CASE-- WHEN THE HEART IS TAPPED, WE CAN BRING A POP-UP FIELD
// THAT ASKS FOR A NAME.

/// OutfitSuggestionScreen - Displays an outfit suggestion
/// Allows users to:
/// - View suggested outfit components (Top, Bottom, Shoes)
/// - Add the outfit to favorites
/// - Regenerate a new outfit
class OutfitSuggestionScreen extends StatefulWidget {
  
  // Optional parameter to control the visibility of the favorite icon
  final bool showFavorite;

  // Optional parameter to control the visibility of the regenerate button
  final bool showRegenerate;


  // Outfit object to display the suggested outfit
  final Outfit? outfit;


  const OutfitSuggestionScreen(
      {super.key,
      this.showFavorite = true,
      this.showRegenerate = true,
      this.outfit});

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
        isViewMode: true,
        showEditIcon: false,
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
                          child: outfitItem("Top", screenWidth, imageUrl: widget.outfit?.topItem.url),
                        ),
                        // Display Bottom item below Top
                        Positioned(
                          top: screenHeight * 0.25,
                          right: screenWidth * 0.0,
                          child: outfitItem("Bottom", screenWidth, imageUrl: widget.outfit?.bottomItem.url),
                        ),
                        // Display Shoes item at the bottom
                        Positioned(
                          top: screenHeight * 0.45,
                          left: screenWidth * 0.0,
                          child: outfitItem("Shoes", screenWidth, imageUrl: widget.outfit?.shoeItem.url),  
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Add spacing between outfit display and buttons
            SizedBox(height: screenHeight * 0.03),

            // Buttons Row for Favorite and Regenerate actions (plus thumbs up/down if applicable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: widget.showFavorite
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceEvenly, // Adjust alignment
                children: [
                  // Show thumbs down icon if showFavorite is true
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth *
                          0.08, // Icon size relative to screen width
                      icon: const Icon(
                        Icons.thumb_down,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // TODO: Add dislike logic here
                        print("Thumbs down pressed");
                      },
                    ),

                  // Heart icon to mark/unmark outfit as a favorite
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth *
                          0.1, // Icon size relative to screen width
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? Colors.red
                            : Colors
                                .black, // Change color based on favorite status
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
                  if (widget.showRegenerate)
                    IconButton(
                      iconSize: screenWidth * 0.1,
                      icon: const Icon(Icons.autorenew),
                      onPressed: () {
                        print("Regenerate pressed");
                      },
                    ),

                  // Show thumbs up icon if showFavorite is true
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth *
                          0.08, // Icon size relative to screen width
                      icon: const Icon(
                        Icons.thumb_up,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // TODO: Add like logic here
                        print("Thumbs up pressed");
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
