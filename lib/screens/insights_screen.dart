import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/constants.dart';

// Main insights screen showing outfit and clothing statistics
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // List of top 5 most worn outfits
  List<Outfit> topOutfits = [];
  
  // Map of top 3 items by category (Tops, Bottoms, Shoes)
  Map<String, List<Item>> topItemsByCategory = {
    'Top': [],
    'Bottom': [],
    'Shoes': [],
  };
  
  // List of items that have never been worn
  List<Item> neverWornItems = [];
  
  // Loading state flag
  bool isLoading = true;
  
  // Tracks how many times each item has been worn
  final Map<String, int> itemWearCounts = {};

  @override
  void initState() {
    super.initState();
    _loadInsightsData(); // Load data when screen initializes
  }

  // Fetches and processes outfit and item data
  Future<void> _loadInsightsData() async {
    setState(() => isLoading = true);

    // Fetch data if not already loaded
    if (Outfit.outfitList.isEmpty) await Outfit.fetchOutfits(kUsername);
    if (Item.itemList.isEmpty) await Item.fetchItems(kUsername);

    itemWearCounts.clear(); // Reset wear counts

    // Count appearances of each item in all outfits
    for (final outfit in Outfit.outfitList) {
      _countItemAppearances(outfit.topItem);
      _countItemAppearances(outfit.bottomItem);
      _countItemAppearances(outfit.shoeItem);
    }

    // Sort and get top 5 most worn outfits
    topOutfits = List.from(Outfit.outfitList)
      ..sort((a, b) => b.timesWorn.compareTo(a.timesWorn));
    topOutfits = topOutfits.take(5).toList();

    // Get top 3 items for each category
    for (var category in topItemsByCategory.keys) {
      var items = Item.itemList.where((i) => i.category == category).toList();
      items.sort((a, b) {
        final countA = itemWearCounts[a.id.toString()] ?? 0;
        final countB = itemWearCounts[b.id.toString()] ?? 0;
        return countB.compareTo(countA); // Sort by wear count descending
      });
      topItemsByCategory[category] = items.take(3).toList();
    }

    // Find never-worn items (wear count = 0)
    neverWornItems = Item.itemList.where((i) =>
      (itemWearCounts[i.id.toString()] ?? 0) == 0
    ).toList();

    setState(() => isLoading = false); // Done loading
  }

  // Helper to increment wear count for an item
  void _countItemAppearances(Item item) {
    final itemId = item.id.toString();
    itemWearCounts[itemId] = (itemWearCounts[itemId] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate card width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 24;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: const CustomNavBar(),
      body: SafeArea(
        // Show loading indicator or content
        child: isLoading ? _buildLoading() : _buildContent(cardWidth),
      ),
    );
  }

  // Loading indicator widget
  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  // Main content widget when data is loaded
  Widget _buildContent(double cardWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: kBottomNavigationBarHeight + 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most Worn Outfits section
          _sectionTitle('Most Worn Outfits'),
          SizedBox(
            height: 382,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topOutfits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final outfit = topOutfits[index];
                return GestureDetector(
                  onTap: () => _navigateToOutfitDetails(outfit),
                  child: Container(
                    width: cardWidth,
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[200], // Gray background
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // White container for outfit images
                        Container(
                          height: 305,
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black12,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildOutfitItem(outfit.topItem.url),
                              const SizedBox(height: 8),
                              _buildOutfitItem(outfit.bottomItem.url),
                              const SizedBox(height: 8),
                              _buildOutfitItem(outfit.shoeItem.url),
                            ],
                          ),
                        ),
                        // Outfit name and wear count
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: Column(
                            children: [
                              Text(
                                outfit.label,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Worn ${outfit.timesWorn} ${outfit.timesWorn == 1 ? 'time' : 'times'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Generate sections for each clothing category
          for (var entry in topItemsByCategory.entries) ...[
            _sectionTitle('Most Worn ${entry.key}s'),
            _itemList(entry.value),
            const SizedBox(height: 24),
          ],
          // Never Worn Items section
          _sectionTitle('Never Worn Items'),
          _itemList(neverWornItems, isNeverWorn: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Builds an individual outfit item image widget
  Widget _buildOutfitItem(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isNotEmpty
            ? Image.network( // Display network image if URL exists
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                ),
              )
            : const Center( // Fallback icon if no image
                child: Icon(Icons.checkroom, size: 40, color: Colors.grey),
              ),
      ),
    );
  }

  // Section title widget with consistent styling
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: kH2),
      );

  // Horizontal list widget for items (tops/bottoms/shoes)
  Widget _itemList(List<Item> items, {bool isNeverWorn = false}) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No items to display', style: TextStyle(color: Colors.grey)),
      );
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          final wearCount = itemWearCounts[item.id.toString()] ?? 0;

          return Container(
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Gray background
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow( // Subtle shadow
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Item image container
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: item.url.isNotEmpty
                      ? ClipRRect( // Display item image
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8)),
                          child: Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.checkroom,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : const Center( // Fallback icon
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                ),
                // Item label and wear count
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isNeverWorn) ...[ // Only show wear count if item has been worn
                        const SizedBox(height: 4),
                        Text(
                          '$wearCount ${wearCount == 1 ? 'wear' : 'wears'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Navigates to outfit details screen
  Future<void> _navigateToOutfitDetails(Outfit outfit) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => OutfitSuggestionScreen(
          outfit: outfit,
          showFavorite: false,
          showRegenerate: false,
          showDeleteIcon: true,
        ),
      ),
    );
    if (result == true) _loadInsightsData(); // Refresh if changes were made
  }
}