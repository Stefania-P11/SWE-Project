import 'package:dressify_app/constants.dart'; // Import constants for styling
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
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
    return GestureDetector(
      onTap: onTap, // Handles outfit selection when tapped
      child: Container(
        padding: const EdgeInsets.all(8), // Padding around the outfit
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the card
          borderRadius: BorderRadius.circular(12), // Rounded corners
          border: Border.all(
            color: isSelected
                ? Colors.blue // Highlight border when selected
                : Colors.black12, // Default border color when not selected
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// Displays the outfit's label
            Text(
              outfit.label,
              style: kH2, // Applies the text style from constants.dart
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8), // Space between label and outfit items

            /// Displays the top item
            _buildOutfitSection(outfit.topItem.url),

            const SizedBox(height: 8), // Space between items

            /// Displays the bottom item
            _buildOutfitSection(outfit.bottomItem.url),

            const SizedBox(height: 8),

            /// Displays the shoes item
            _buildOutfitSection(outfit.shoeItem.url),
          ],
        ),
      ),
    );
  }

  /// Helper method to build a section with an image and label
  Widget _buildOutfitSection(String url) {
    return Container(
      height: 100, // Fixed height for each section
      width: double.infinity, // Takes full width
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url, // URL of the image from Item
                fit: BoxFit.cover, // Ensures the image covers the space
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, size: 50, color: Colors.grey),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}