import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/models/item.dart'; // Import Item model
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
import 'package:dressify_app/screens/display_outfit_screen.dart'; // Screen to display individual outfit
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Custom app bar widget
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // Custom bottom navigation bar
import 'package:dressify_app/widgets/outfit_card.dart'; // Widget to display outfits in card format
import 'package:flutter/material.dart'; // Flutter core UI package

/// Screen that displays the user's favorite outfits
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    // Load items and outfits when the screen is initialized
    loadItemsAndFetchOutfits();
  }

  /// Load items and outfits only if they haven't already been loaded
  Future<void> loadItemsAndFetchOutfits() async {
    if (Item.itemList.isEmpty) {
      await Item.fetchItems(kUsername); // Fetch user's items from Firestore
    }

    await Outfit.fetchOutfits(kUsername); // Fetch user's outfits from Firestore

    setState(() {}); // Trigger UI rebuild
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(), // Top app bar

      body: _buildOutfitGrid(), // Display filtered outfits

      bottomNavigationBar: CustomNavBar(), // Bottom nav bar
    );
  }

  /// Filters and builds the grid view of outfits
  Widget _buildOutfitGrid() {
    // Filter outfits to exclude those referencing missing items
    final filteredOutfits = Outfit.outfitList.where((outfit) {
      return Item.itemList.contains(outfit.topItem) &&
             Item.itemList.contains(outfit.bottomItem) &&
             Item.itemList.contains(outfit.shoeItem);
    }).toList();

    // If no valid outfits, show a message
    if (filteredOutfits.isEmpty) {
      return const Center(
        child: Text(
          'Your favorite outfits will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    // GridView to display outfit cards
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: filteredOutfits.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Two cards per row
        crossAxisSpacing: 16, // Space between columns
        mainAxisSpacing: 16, // Space between rows
        childAspectRatio: 0.55, // Card aspect ratio
      ),
      itemBuilder: (context, index) {
        final outfit = filteredOutfits[index];

        // Each outfit is wrapped in an OutfitCard
        return OutfitCard(
          outfit: outfit,
          isSelected: false,
          onTap: () async {
            // Navigate to OutfitSuggestionScreen and wait for result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OutfitSuggestionScreen(
                  outfit: outfit,
                  showFavorite: false,
                  showRegenerate: false,
                  showDeleteIcon: true,
                ),
              ),
            );

            // If outfit was deleted, trigger rebuild
            if (result == true) {
              setState(() {});
            }
          },
        );
      },
    );
  }
}
