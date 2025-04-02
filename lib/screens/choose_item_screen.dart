import 'package:dressify_app/constants.dart'; // Import constants for styling and reusable values
import 'package:dressify_app/models/item.dart'; // Import the Item model
import 'package:dressify_app/services/item_service.dart'; // Import ItemService to fetch data
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar widget
import 'package:dressify_app/widgets/item_grid.dart'; // Import custom widget to display grid items
import 'package:flutter/material.dart'; // Import Flutter Material package

/// Screen that allows the user to choose an item based on the selected category.
class ChooseItemScreen extends StatefulWidget {
  final String
      category; // Category of items to be displayed (e.g., Top, Bottom, Shoes)

  const ChooseItemScreen({super.key, required this.category});

  @override
  State<ChooseItemScreen> createState() => _ChooseItemScreenState();
}

class _ChooseItemScreenState extends State<ChooseItemScreen> {
  List<Item> _items = []; // List to store the fetched items
  bool _isLoading = true; // Tracks loading state for showing a loader
  String?
      selectedItemUrl; // Stores the selected item URL to pass back to the previous screen

  // Create an instance of ItemService
  final ItemService _itemService = ItemService();

   @override
  void initState() {
    super.initState();
    _loadItems(); // Load items when the screen initializes
  }

  /// Fetch items from Firestore using ItemService and filter based on the selected category
  Future<void> _loadItems() async {
  setState(() {
    _items = Item.itemList
        .where((item) => item.category == widget.category)
        .toList(); // Local filter only
    _isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    // Get the screen width and height to calculate dynamic sizes
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 239, 240, 240), // Background color for the screen
      appBar: CustomAppBar(
          showBackButton:
              true), // Display the custom app bar with a back button

      // Main body of the screen
      body: Column(
        children: [
          SizedBox(
              height: screenHeight * 0.02), // Add vertical space at the top

          /// Dynamic title based on the selected category
          Text(
            widget.category == "Shoes"
                ? "Choose a Pair of Shoes" // Special title for shoes
                : widget.category == "Bottom"
                    ? "Choose a Bottom Piece" // Special for bottoms
                    : "Choose a ${widget.category}", // Generic title for other categories
            style: kH2, // Apply text style from constants.dart
          ),
          SizedBox(height: screenHeight * 0.015), // Add space below the title

          /// Grid View to Display Items
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show a loading indicator if items are being loaded
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                            'No items found in this category.')) // Show message if no items found
                    : ItemGrid(
                        items: _items, // Pass fetched items to ItemGrid
                        selectedItemUrl:
                            selectedItemUrl, // Pass selected URL to keep track of selected item
                        onItemSelected: (url) {
                          // Handle item selection
                          setState(() {
                            selectedItemUrl =
                                url; // Update the selected item URL
                          });
                        },
                      ),
          ),

          /// Button to confirm selection (only visible if an item is selected)
          if (selectedItemUrl != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.2,
                vertical: 12,
              ), // Add padding to the button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context,
                      selectedItemUrl); // Return selected item URL to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // Button background color
                  padding: const EdgeInsets.symmetric(
                      vertical: 12), // Vertical padding
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Button border radius
                  ),
                ),
                child: const Text(
                  "Add", // Button text
                  style: TextStyle(
                      color: Colors.white, fontSize: 16), // Button text style
                ),
              ),
            ),
        ],
      ),
    );
  }
}
