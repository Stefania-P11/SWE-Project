import 'package:dressify_app/constants.dart'; // Importing global constants and styles
import 'package:dressify_app/models/item.dart'; // Importing the Item model to display item details
import 'package:dressify_app/screens/add_item_screen.dart'; // Importing AddItemScreen for adding new items
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Importing custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Importing custom bottom navigation bar
import 'package:flutter/material.dart'; // Importing Flutter Material Design

/// ClosetItemsScreen displays the user's wardrobe with filter functionality
/// Users can view their items, add new items, and filter items by category.
class ClosetItemsScreen extends StatefulWidget {
  const ClosetItemsScreen({super.key});

  @override
  State<ClosetItemsScreen> createState() => _ClosetItemsScreenState();
}

class _ClosetItemsScreenState extends State<ClosetItemsScreen> {
  String selectedFilter = 'All'; // Default filter is set to "All"
  final filters = ['All', 'Top', 'Bottom', 'Shoes']; // Available filter options

  /// Map that associates Firebase category names with display names
  final Map<String, String> filterLabels = {
    'All': 'All',
    'Top': 'Tops', // Firebase category "Top" -> Show "Tops"
    'Bottom': 'Bottoms', // Firebase category "Bottom" -> Show "Bottoms"
    'Shoes': 'Shoes',
  };

  List<Item> _items = []; // List to store fetched items
  bool _isLoading = true; // Indicates whether items are being loaded

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load items when the screen initializes
  }

  /// Fetches items from Firebase Firestore and updates the item list
  Future<void> _loadItems() async {
    try {
      await Item.fetchItems(kUsername); // Fetch items using a placeholder username (replace with real username later)
      setState(() {
        _items = Item.itemList; // Populate the item list with fetched data
        _isLoading = false; // Hide loading indicator after fetching
      });
    } catch (e) {
      print("Error loading items: $e"); // Handle any errors during item fetching
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Filters items based on the selected category
  List<Item> getFilteredItems() {
    if (selectedFilter == 'All') {
      return _items; // Show all items if "All" is selected
    } else {
      // Return filtered items matching the selected category
      return _items.where((item) => item.category == selectedFilter).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240), // Background color
      appBar: CustomAppBar(), // Display the custom app bar

      // Main body of the screen
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),

                /// Title with Add Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Your Wardrobe", style: kH2), // Title with custom style
                    IconButton(
                      icon: const Icon(Icons.add, size: 28), // Add icon for adding items
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const AddItemScreen(), // Navigate to AddItemScreen
                            transitionDuration: Duration.zero, // No transition animation
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.015),

                /// Scrollable Grid to Display Items
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator()) // Show loader if items are loading
                      : _items.isEmpty
                          ? const Center(child: Text('No items in your wardrobe.')) // Show message if no items
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 80),
                              itemCount: getFilteredItems().length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 items per row
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 3 / 4,
                              ),
                              itemBuilder: (context, index) {
                                final item = getFilteredItems()[index];
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            item.url,
                                            fit: BoxFit.cover, // Display item image
                                          ),
                                        ),
                                      ),
                                      Text(item.label, style: kH3), // Display item label
                                    ],
                                  ),
                                );
                              },
                            ),
                ),

                /// Filter Buttons to Filter Items by Category
                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: filters.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter; // Update the selected filter
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.012,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(30), // Rounded corners for buttons
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              filterLabels[filter] ?? filter, // Show appropriate label for the filter
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),
        ],
      ),

      /// Bottom Navigation Bar
      bottomNavigationBar: const CustomNavBar(), // Display custom bottom navigation bar
    );
  }
}

/// TODO: Add edit item functionality
/// You will reuse the same screen as the Add Item Screen, but when the user navigates
/// to the screen, pass the item that the user wants to edit and pre-fill the
/// fields with the item data.

/// TODO: Add delete item functionality (maybe add it in the edit item screen)
/// Add functionality to delete an item from the list and update the screen accordingly.
