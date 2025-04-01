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
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OutfitSuggestionScreen(
            showFavorite: false,
            outfit: outfit,
            showRegenerate: false,
          ),
        ),
      );
    },
    child: Container(
      width: cardWidth, // ✅ Restrict card width
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.black12,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            outfit.label,
            style: kH2.copyWith(fontSize: 16), // Smaller title for compact card
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          _buildOutfitSection(outfit.topItem.url),
          const SizedBox(height: 8),
          _buildOutfitSection(outfit.bottomItem.url),
          const SizedBox(height: 8),
          _buildOutfitSection(outfit.shoeItem.url),
        ],
      ),
    ),
  );
}


  /// Helper method to build a section with an image and label
  Widget _buildOutfitSection(String url) {
  return SizedBox(
    height: 80,
    width: double.infinity,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 40, color: Colors.grey),
      ),
    ),
  );

}

  
}