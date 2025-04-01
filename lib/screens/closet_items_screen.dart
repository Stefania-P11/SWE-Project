import 'package:dressify_app/constants.dart'; // Importing global constants and styles
import 'package:dressify_app/models/item.dart'; // Importing the Item model to display item details
import 'package:dressify_app/screens/add_item_screen.dart'; // Importing AddItemScreen for adding new items
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Importing custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Importing custom bottom navigation bar
import 'package:flutter/material.dart'; // Importing Flutter Material Design
import 'package:flutter_svg/flutter_svg.dart';//Importing flutter_svg to use image in .svg


/// ClosetItemsScreen displays the user's wardrobe with filter functionality
/// Users can view their items, add new items, and filter items by category.
class ClosetItemsScreen extends StatefulWidget {
  const ClosetItemsScreen({super.key});

  @override
  State<ClosetItemsScreen> createState() => _ClosetItemsScreenState();
}

class _ClosetItemsScreenState extends State<ClosetItemsScreen> {
  // Define categories and temperatures within the class
  static const List<String> categories = ['Top', 'Bottom', 'Shoes'];
  static const List<String> temperatures = ['Hot', 'Warm', 'Cool', 'Cold'];
  String? selectedCateg; //No catgeory is selected initially
  Set<String> selectedTemps = {}; // temperature can be selected more than 1 choice

  List<Item> _items = []; // List to store fetched items
  bool _isLoading = true; // Indicates whether items are being loaded
  bool _isFilterVisible = false; //ensure filter button active/inactive when needed.

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load items when the screen initializes
  }

  /// Fetches items from Firebase Firestore and updates the item list
  /// TODO: Stefania move this to the proper file
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
        _isLoading = false; // Hide loading indicator if an error occurs
      });
    }
  }
  /*method to inactivate filter button */
  void _applyFilters() {
    setState(() {
      _isFilterVisible = false;
    });
  }

  /*method to reset filter as default*/
  void _resetFilters() {
  setState(() {
    selectedCateg = null; // Reset category selection
    selectedTemps.clear(); // Clear temperature selection
    _isFilterVisible = false; // Hide filter UI
  });
}


  /// Filters items based on the currently selected category and temperature filters
  /// TODO: Stefania move this to the proper file
  List<Item> getFilteredItems() {
    return _items.where((item) {
      final matchesCategory = selectedCateg == null || item.category == selectedCateg;
      final matchesTemperature = selectedTemps.isEmpty || selectedTemps.intersection(item.weather.toSet()).isNotEmpty;
      return matchesCategory && matchesTemperature;
    }).toList();
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
                    IconButton(// add filter buttom for sorting
                      icon: SvgPicture.asset(
                        'lib/assets/icons/filter-icon.svg', 
                        width: 24,
                        height: 24,
                        color: Colors.black, // Optional color tint
                      ),
                      onPressed: () {
                        setState(() {
                          _isFilterVisible = !_isFilterVisible;
                        });
                      },
                    ),
                
                    IconButton(
                      icon: const Icon(Icons.add, size: 28), // Add icon for adding items
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                AddItemScreen(), // Navigate to AddItemScreen for adding a new item
                            transitionDuration: Duration.zero, // No transition animation
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      },
                    ),
                  ],
                ),

              //activate filter button and drop the the container for selecting filter choice
              if (_isFilterVisible)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 5),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Category", style: kH3),
                        Wrap(
                          spacing: 8,
                          children: categories.map((category) {
                            return ChoiceChip(
                              label: Text(category),
                              selected: selectedCateg == category,
                              onSelected: (selected) {
                                setState(() {
                                  selectedCateg = selected ? category : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Text("Temperature", style: kH3), 
                        Wrap(
                          spacing: 8,
                          children: temperatures.map((temperature) { //map temperatures elemeent to category of Item
                            final isSelected = selectedTemps.contains(temperature); // Check if selected
                            return ChoiceChip(
                              label: Text(temperature),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedTemps.add(temperature); // Add to selected set
                                  } else {
                                    selectedTemps.remove(temperature); // Remove if deselected
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(onPressed: _resetFilters, child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: selectedCateg != 'All' || selectedTemps != null ? _applyFilters : null,
                              child: const Text("Apply"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                SizedBox(height: screenHeight * 0.015),

                /// Scrollable Grid to Display Items
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator()) // Show loader if items are loading
                      : _items.isEmpty
                          ? const Center(child: Text('No items in your wardrobe.')) // Show message if no items
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 80), // Padding to avoid overlapping with nav bar
                              itemCount: getFilteredItems().length, // Count of filtered items
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 items per row
                                crossAxisSpacing: 12, // Horizontal spacing between items
                                mainAxisSpacing: 12, // Vertical spacing between items
                                childAspectRatio: 3 / 4, // Aspect ratio to control item size
                              ),
                              itemBuilder: (context, index) {
                                final item = getFilteredItems()[index]; // Get the item at the current index

                                // Wrap item in GestureDetector to navigate to AddItemScreen when tapped
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddItemScreen(item: item), // Pass item data to AddItemScreen
                                      ),
                                    ).then((_) {
                                      // Reload items when returning to refresh the list
                                      _loadItems();
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Item background
                                      borderRadius: BorderRadius.circular(12), // Rounded corners
                                      border: Border.all(color: Colors.black12), // Light border
                                    ),
                                    child: Column(
                                      children: [
                                        // Display item image
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12), // Rounded corners for image
                                            child: Image.network(
                                              item.url, // Display item image from URL
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Display item name or label
                                        Text(item.label, style: kH3),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
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
