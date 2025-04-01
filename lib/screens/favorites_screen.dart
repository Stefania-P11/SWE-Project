import 'package:dressify_app/constants.dart'; // Import constants for global styles and values
import 'package:dressify_app/models/item.dart'; // Import Item model to access item data
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model to manage outfit data
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Import custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Import custom bottom navbar widget
import 'package:dressify_app/widgets/outfit_card.dart'; // Import OutfitCard widget to display outfits
import 'package:flutter/material.dart'; // Import Flutter Material package for UI components

/// Stateful widget to manage and display favorite outfits
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key}); // Constructor with optional key

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState(); // Create state for the widget
}

/// State class for FavoritesScreen
class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<void> _fetchOutfitsFuture; // Future to handle async data fetching

  @override
  void initState() {
    super.initState();
    // Load items and outfits when the screen initializes
    _fetchOutfitsFuture = loadItemsAndFetchOutfits();
  }

  /// Fetches items first, then fetches outfits after items are loaded
  Future<void> loadItemsAndFetchOutfits() async {
    // Check if the item list is empty before fetching items
    if (Item.itemList.isEmpty) {
      print('Loading items for user: $kUsername');
      await Item.fetchItems(kUsername); // Fetch items for the current user
      print('Items loaded: ${Item.itemList.length}'); // Debug log
    }

    // Fetch outfits after items are loaded
    print('Fetching outfits for user: $kUsername');
    await Outfit.fetchOutfits(kUsername);
    print('Outfits loaded: ${Outfit.outfitList.length}'); // Debug log
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Display custom app bar

      /// Body of the screen with FutureBuilder to handle async data loading
      body: FutureBuilder<void>(
        future: _fetchOutfitsFuture, // The future that loads outfits
        builder: (context, snapshot) {
          // Show loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle any error during fetching
          if (snapshot.hasError) {
            print('Error fetching data: ${snapshot.error}'); // Log error
            return const Center(
              child: Text(
                'Error loading outfits. Please try again later.', // Error message for the user
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          // Show a message if no outfits are found
          if (Outfit.outfitList.isEmpty) {
            return const Center(
              child: Text(
                'Your favorite outfits will appear here!',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return GridView.builder(
  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
  itemCount: Outfit.outfitList.length,
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2, // Two cards per row
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    childAspectRatio: 0.55, // Adjust to match card height/width balance
  ),
  itemBuilder: (context, index) {
    final outfit = Outfit.outfitList[index];
    return OutfitCard(
      outfit: outfit,
      isSelected: false,
      onTap: () {
        print('Outfit selected: ${outfit.label}');
      },
    );
  },
);

        },
      ),
      bottomNavigationBar: CustomNavBar(), // Display custom bottom navbar
    );
  }
}
