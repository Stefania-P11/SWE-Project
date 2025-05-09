import 'package:dressify_app/constants.dart'; // Importing global constants and styles
import 'package:dressify_app/models/item.dart'; // Importing the Item model to display item details
import 'package:dressify_app/screens/add_item_screen.dart'; // Importing AddItemScreen for adding new items
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Importing custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Importing custom bottom navigation bar
import 'package:flutter/material.dart'; // Importing Flutter Material Design
import 'package:flutter_svg/flutter_svg.dart'; //Importing flutter_svg to use image in .svg

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
  Set<String> selectedTemps =
      {}; // temperature can be selected more than 1 choice

  List<Item> _items = []; // List to store fetched items
  bool _isLoading = true; // Indicates whether items are being loaded
  bool _isFilterVisible =
      false; //ensure filter button active/inactive when needed.

  @override
  void initState() {
    super.initState();
    _loadItems(); // Load items when the screen initializes
  }

  /// Fetches items from Firebase Firestore and updates the item list
  /// TODO: Stefania move this to the proper file
  //Future<void> _loadItems() async {
  //try {
  // await Item.fetchItems(kUsername); // Fetch items using a placeholder username (replace with real username later)
  //  setState(() {
  //    _items = Item.itemList; // Populate the item list with fetched data
  //    _isLoading = false; // Hide loading indicator after fetching
  //  });
  //} catch (e) {
  //  print("Error loading items: $e"); // Handle any errors during item fetching
  //  setState(() {
  //    _isLoading = false; // Hide loading indicator if an error occurs
  //  });
  //  }
  // }

  /* Future<void> _loadItems() async {
      setState(() {
        _items = Item.itemList; //  Only uses local list
        _isLoading = false;
      });
    } */

  Future<void> _loadItems() async {
    setState(() => _isLoading = true);

    if (Item.itemList.isEmpty) {
      await Item.fetchItems(kUsername);
    }

    setState(() {
      _items = Item.itemList;
      _isLoading = false;
    });
  }

  void _applyFilters() {
    setState(() {
      _isFilterVisible = false;
    });
  }

  void _resetFilters() {
    setState(() {
      selectedCateg = null;
      selectedTemps.clear();
      _isFilterVisible = false;
    });
  }

  /// Filters items based on the currently selected category and temperature filters
  /// TODO: Stefania move this to the proper file
  List<Item> getFilteredItems() {
    return _items.where((item) {
      final matchesCategory =
          selectedCateg == null || item.category == selectedCateg;
      final matchesTemperature = selectedTemps.isEmpty ||
          selectedTemps.intersection(item.weather.toSet()).isNotEmpty;
      return matchesCategory && matchesTemperature;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor, // Background color
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
                    Text("Your Wardrobe",
                        style: kH2), // Title with custom style

                    IconButton(
                      // add filter buttom for sorting
                      icon: SvgPicture.asset(
                        'lib/assets/icons/filter-icon.svg',
                        width: 24,
                        height: 24,
                        color: Colors.black, // Color of the filter icon
                      ),
                      onPressed: () {
                        setState(() {
                          _isFilterVisible = !_isFilterVisible;
                        });
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.add,
                          size: 28), // Add icon for adding items
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    AddItemScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );

                        // Only reload if a new item was successfully added
                        if (result == true) {
                          await Item.fetchItems(
                              kUsername); // Re-fetch from Firestore
                          setState(() {
                            _items = Item.itemList;
                          });
                        }
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
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: categories.map((category) {
                            final isSelected = selectedCateg == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedCateg = isSelected ? null : category;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.grey[400]
                                      : Colors.white, // Grey when selected
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Text("Temperature", style: kH3),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: temperatures.map((temperature) {
                            //map temperatures elemeent to category of Item
                            final isSelected = selectedTemps
                                .contains(temperature); // Check if selected
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedTemps.remove(temperature);
                                  } else {
                                    selectedTemps.add(temperature);
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.grey[400]
                                      : Colors.white, // Grey when selected
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Text(
                                  temperature,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.black
                                        : Colors.grey[700],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _resetFilters,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Default color
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey), // Grey border
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight:
                                        FontWeight.bold, // Make text bold
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 8), // Space between buttons
                            GestureDetector(
                              onTap: _applyFilters,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.white, // Default color
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey), // Grey border
                                ),
                                child: Text(
                                  "Apply",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight:
                                        FontWeight.bold, // Make text bold
                                  ),
                                ),
                              ),
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
                      ? const Center(
                          child:
                              CircularProgressIndicator()) // Show loader if items are loading
                      : _items.isEmpty
                          ? const Center(
                              child: Text(
                                  'No items in your wardrobe.')) // Show message if no items
                          : GridView.builder(
                              padding: const EdgeInsets.only(
                                  bottom:
                                      80), // Padding to avoid overlapping with nav bar
                              itemCount: getFilteredItems()
                                  .length, // Count of filtered items
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // 2 items per row
                                crossAxisSpacing:
                                    12, // Horizontal spacing between items
                                mainAxisSpacing:
                                    12, // Vertical spacing between items
                                childAspectRatio:
                                    3 / 4, // Aspect ratio to control item size
                              ),
                              itemBuilder: (context, index) {
                                final item = getFilteredItems()[
                                    index]; // Get the item at the current index

                                // Wrap item in GestureDetector to navigate to AddItemScreen when tapped
                                return GestureDetector(
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            AddItemScreen(item: item),
                                      ),
                                    );

                                    // Only reload if the item was deleted
                                    if (result == true) {
                                      _loadItems();
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white, // Item background
                                      borderRadius: BorderRadius.circular(
                                          12), // Rounded corners
                                      border: Border.all(
                                          color:
                                              Colors.black12), // Light border
                                    ),
                                    child: Column(
                                      children: [
                                        // Display item image
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                12), // Rounded corners for image
                                            child: Image.network(
                                              item.url, // Display item image from URL
                                              fit: BoxFit.contain,
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
      bottomNavigationBar:
          const CustomNavBar(), // Display custom bottom navigation bar
    );
  }
}

/// TODO: Add edit item functionality
/// You will reuse the same screen as the Add Item Screen, but when the user navigates
/// to the screen, pass the item that the user wants to edit and pre-fill the
/// fields with the item data.

/// TODO: Add delete item functionality (maybe add it in the edit item screen)
/// Add functionality to delete an item from the list and update the screen accordingly.
