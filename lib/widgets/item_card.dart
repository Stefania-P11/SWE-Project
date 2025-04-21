import 'package:dressify_app/constants.dart'; // Import constants for consistent styling
import 'package:dressify_app/models/item.dart'; // Import Item model to use item data
import 'package:flutter/material.dart'; // Import Flutter Material package for UI components

/// A widget that displays an individual item in a card format.
/// This widget is used in a grid or list to showcase items.
class ItemCard extends StatelessWidget {
  final Item item; // The item to be displayed in the card
  final bool isSelected; // Indicates whether the item is selected
  final VoidCallback onTap; // Callback triggered when the item is tapped

  /// Constructor that initializes the required properties.
  const ItemCard({
    super.key, // Passes the key to the parent class (optional but useful for performance optimization)
    required this.item, // Item data to be displayed
    required this.isSelected, // Whether the item is selected
    required this.onTap, // Callback for item tap action
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handles item selection when tapped
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color of the item card
          borderRadius: BorderRadius.circular(12), // Rounded corners for the card
          border: Border.all(
            color: isSelected
                ? Colors.blue // Highlight border when selected
                : Colors.black12, // Default border color when not selected
            width: isSelected
                ? 3 // Thicker border when item is selected
                : 1, // Thinner border when item is not selected
          ),
        ),
        child: Column(
          children: [
            /// Displays the item's image with rounded corners
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12), // Applies rounded corners to the image
                child: Image.network(
                  item.url, // URL of the image
                  fit: BoxFit.contain, 
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                  // Shows a fallback icon if the image fails to load
                ),
              ),
            ),

            /// Displays the item's label below the image
            Padding(
              padding: const EdgeInsets.all(8.0), // Padding around the label
              child: Text(
                item.label, // The label or name of the item
                style: kH3, // Applies the text style from constants.dart
                overflow: TextOverflow.ellipsis, // Prevents long text from overflowing
              ),
            ),
          ],
        ),
      ),
    );
  }
}
