import 'package:dressify_app/constants.dart'; // Import constants for styling
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:flutter/material.dart'; // Import Flutter Material package

/// A widget that displays an outfit in a card format with top, bottom, and shoes.
class OutfitCard extends StatelessWidget {
  final Outfit outfit; // The outfit to be displayed
  final bool isSelected; // Indicates whether the outfit is selected
  final VoidCallback onTap; // Callback triggered when the outfit is tapped

  /// Constructor that initializes the required properties.
  const OutfitCard({
    super.key,
    required this.outfit, // Outfit data to be displayed
    required this.isSelected, // Whether the outfit is selected
    required this.onTap, // Callback for outfit tap action
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 24; // Account for padding and spacing

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.black12,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              //Left side
              Expanded(
                flex: 2, // Give more space to the left side
                child: Container(
                  // color: Colors.white, // Dark background
                  child: Column(
                    children: [
                      // Label at the top
                      _buildOutfitSection(outfit.topItem.url)
                    ],
                  ),
                ),
              ),
              // Right side: Two vertical sections for "Bottom" and "Shoes"
              Expanded(
                flex: 1, // Less space for the right side
                child: Column(
                  children: [
                    // Upper half: "Bottom"
                    Expanded(
                      flex: 3,
                      child: Container(
                        // color: const Color(0xFF302D30),
                        child: Column(
                          children: [
                            _buildOutfitSection(outfit.bottomItem.url)
                          ],
                        ),
                      ),
                    ),

                    // Lower half: "Shoes"
                    Expanded(
                      flex: 2,
                      child: Container(
                        // color: const Color(0xFF302D30),
                        child: Column(
                          children: [_buildOutfitSection(outfit.shoeItem.url)],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  /// Helper method to build a section with an image and label
  Widget _buildOutfitSection(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 40, color: Colors.grey),
        ),
      ),
    );
  }
}
