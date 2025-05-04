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
  // List to store top outfits based on wear count
  List<Outfit> topOutfits = [];

  // Map to store top items by category (Top, Bottom, Shoes)
  Map<String, List<Item>> topItemsByCategory = {
    'Top': [],
    'Bottom': [],
    'Shoes': [],
  };

  // List to store items that have never been worn
  List<Item> neverWornItems = [];

  // Loading state flag
  bool isLoading = true;

  // Map to track how many times each item has been worn
  final Map<String, int> itemWearCounts = {};

  @override
  void initState() {
    super.initState();
    // Load insights data when the widget initializes
    _loadInsightsData();
  }

  /// Loads all the insights data including:
  /// - Top outfits by wear count
  /// - Top items by category
  /// - Never worn items
  Future<void> _loadInsightsData() async {
    setState(() => isLoading = true);

    // Fetch outfits and items if they haven't been loaded yet
    if (Outfit.outfitList.isEmpty) await Outfit.fetchOutfits(kUsername);
    if (Item.itemList.isEmpty) await Item.fetchItems(kUsername);

    // Clear previous wear counts
    itemWearCounts.clear();

    // Count how many times each item appears in outfits
    for (final outfit in Outfit.outfitList) {
      _countItemAppearances(outfit.topItem);
      _countItemAppearances(outfit.bottomItem);
      _countItemAppearances(outfit.shoeItem);
    }

    // Sort outfits by times worn and take top 5
    topOutfits = List.from(Outfit.outfitList)
      ..sort((a, b) => b.timesWorn.compareTo(a.timesWorn));
    topOutfits = topOutfits.take(5).toList();

    // For each category, sort items by wear count and take top 3
    for (var category in topItemsByCategory.keys) {
      var items = Item.itemList.where((i) => i.category == category).toList();
      items.sort((a, b) {
        final countA = itemWearCounts[a.id.toString()] ?? 0;
        final countB = itemWearCounts[b.id.toString()] ?? 0;
        return countB.compareTo(countA);
      });
      topItemsByCategory[category] = items.take(3).toList();
    }

    // Find items that have never been worn (wear count = 0)
    neverWornItems = Item.itemList
        .where((i) => (itemWearCounts[i.id.toString()] ?? 0) == 0)
        .toList();

    setState(() => isLoading = false);
  }

  /// Increments the wear count for a specific item
  void _countItemAppearances(Item item) {
    final itemId = item.id.toString();
    itemWearCounts[itemId] = (itemWearCounts[itemId] ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context) {
    // Calculate card width based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth / 2) - 24;

    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: kBackgroundColor,
      bottomNavigationBar: const CustomNavBar(),
      body: SafeArea(
        child: isLoading ? _buildLoading() : _buildContent(cardWidth),
      ),
    );
  }

  /// Builds a loading indicator
  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  /// Builds the main content of the insights screen
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
          _sectionTitle('Most Worn Outfits'),
          SizedBox(
            height: 330,
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
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(2),
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
                        // Outfit preview container with white background
                        Container(
                          height: 260,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
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
                                '${outfit.timesWorn} ${outfit.timesWorn == 1 ? 'time' : 'times'}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color.fromARGB(255, 65, 64, 64),
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
          // Display top items for each category
          for (var entry in topItemsByCategory.entries) ...[
            _sectionTitle(
                'Most Worn ${entry.key == 'Shoes' ? entry.key : '${entry.key}s'}'),
            _itemList(entry.value),
            const SizedBox(height: 24),
          ],
          // Display never worn items section
          _sectionTitle('Never Worn Items'),
          _itemList(neverWornItems, isNeverWorn: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Builds an individual outfit item image
  Widget _buildOutfitItem(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image,
                      size: 40, color: Color.fromARGB(255, 235, 233, 233)),
                ),
              )
            : const Center(
                child: Icon(Icons.checkroom,
                    size: 40, color: Color.fromARGB(255, 235, 233, 233)),
              ),
      ),
    );
  }

  /// Builds a section title with consistent styling
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: kH2),
      );

  /// Builds a horizontal list of items
  /// [items] - List of items to display
  /// [isNeverWorn] - Flag to indicate if these are never worn items
  Widget _itemList(List<Item> items, {bool isNeverWorn = false}) {
    // Show message if no items are available
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child:
            Text('No items to display', style: TextStyle(color: Colors.grey)),
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
              color: Colors.grey[200],
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
                // Item image container
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: item.url.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(8),
                          ),
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
                      : const Center(
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
                      if (!isNeverWorn) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$wearCount ${wearCount == 1 ? 'time' : 'times'}',
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

  /// Navigates to the outfit details screen
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
    // Reload data if there were changes
    if (result == true) _loadInsightsData();
  }
}
