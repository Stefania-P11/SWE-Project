import 'package:dressify_app/models/item.dart'; // Import the Item model
import 'package:dressify_app/widgets/item_card.dart'; // Import the ItemCard widget
import 'package:flutter/material.dart'; // Import Flutter's material package

/// A widget that displays a grid of items.
/// This widget is used to display a grid of item cards and handles item selection.
class ItemGrid extends StatelessWidget {
  /// List of items to be displayed in the grid
  final List<Item> items;

  /// URL of the selected item (if any) to highlight the selected item
  final String? selectedItemUrl;

  /// Callback function triggered when an item is selected
  /// - `onItemSelected` is called with the selected item's URL
  final ValueChanged<String?> onItemSelected;

  /// Constructor to initialize the required fields
  const ItemGrid({
    super.key, // Passes the key to the parent class (optional but improves performance)
    required this.items, // List of items to be displayed
    required this.selectedItemUrl, // URL of the currently selected item
    required this.onItemSelected, // Callback for handling item selection
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 80), // Add padding at the bottom to avoid overlap with the button
      itemCount: items.length, // Number of items to display in the grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Display 2 items per row
        crossAxisSpacing: 12, // Horizontal spacing between items
        mainAxisSpacing: 12, // Vertical spacing between items
        childAspectRatio: 3 / 4, // Aspect ratio for item containers (width/height ratio)
      ),
      itemBuilder: (context, index) {
        final item = items[index]; // Get the item at the current index
        // Check if the current item's URL matches the selectedItemUrl
        final isSelected = item.url == selectedItemUrl;

        /// Create an ItemCard for each item in the grid
        return ItemCard(
          item: item, // Pass item data to the ItemCard
          isSelected: isSelected, // Set the selected state for the card
          onTap: () {
            // Trigger onItemSelected callback when the item is tapped
            onItemSelected(item.url);
          },
        );
      },
    );
  }
}
