// Flutter and Firestore imports for UI and data interaction
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Project-specific models and widgets
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/widgets/outfit_card.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/constants.dart';

// Stateful widget to display clothing and outfit insights
class InsightsScreen extends StatefulWidget {
  const InsightsScreen({Key? key}) : super(key: key);

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // List of top worn outfits (max 5)
  List<Outfit> topOutfits = [];

  // Top 3 items by category (Tops, Bottoms, Shoes)
  Map<String, List<Item>> topItemsByCategory = {
    'Top': [],
    'Bottom': [],
    'Shoes': [],
  };

  // List of items never worn by the user
  List<Item> neverWornItems = [];

  // Loading state flag
  bool isLoading = true;

  // Map to track how many times each item has been worn
  final Map<String, int> itemWearCounts = {};

  // Lifecycle method: fetch insights when screen is initialized
  @override
  void initState() {
    super.initState();
    _loadInsightsData();
  }

  // Fetch outfits and items data, compute top and never worn lists
  Future<void> _loadInsightsData() async {
    setState(() => isLoading = true);

    // Fetch outfits and items from Firestore if not already loaded
    if (Outfit.outfitList.isEmpty) await Outfit.fetchOutfits(kUsername);
    if (Item.itemList.isEmpty) await Item.fetchItems(kUsername);

    itemWearCounts.clear();

    // Count each item appearance across all outfits
    for (final outfit in Outfit.outfitList) {
      _countItemAppearances(outfit.topItem);
      _countItemAppearances(outfit.bottomItem);
      _countItemAppearances(outfit.shoeItem);
    }

    // Sort and take top 5 outfits based on wear count
    topOutfits = List.from(Outfit.outfitList)
      ..sort((a, b) => b.timesWorn.compareTo(a.timesWorn));
    topOutfits = topOutfits.take(5).toList();

    // Sort items by category based on wear counts and keep top 3 per category
    for (var category in topItemsByCategory.keys) {
      var items = Item.itemList.where((i) => i.category == category).toList();
      items.sort((a, b) {
        final countA = itemWearCounts[a.id.toString()] ?? 0;
        final countB = itemWearCounts[b.id.toString()] ?? 0;
        return countB.compareTo(countA);
      });
      topItemsByCategory[category] = items.take(3).toList();
    }

    // Identify items that have never been worn
    neverWornItems = Item.itemList.where((i) =>
      (itemWearCounts[i.id.toString()] ?? 0) == 0
    ).toList();

    setState(() => isLoading = false);
  }

  // Increment wear count for a given item
  void _countItemAppearances(Item item) {
    final itemId = item.id.toString();
    itemWearCounts[itemId] = (itemWearCounts[itemId] ?? 0) + 1;
  }

  // Build UI for the insights screen
  @override
  Widget build(BuildContext context) {
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

  // Widget to show while data is loading
  Widget _buildLoading() => const Center(child: CircularProgressIndicator());

  // Main content: outfits and items summary
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
          _sectionTitle('Top 5 Most Worn Outfits'),
          SizedBox(
            height: 353,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: topOutfits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final outfit = topOutfits[index];
                return Container(
                  width: cardWidth,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 305,
                        child: OutfitCard(
                          outfit: outfit,
                          isSelected: false,
                          onTap: () => _navigateToOutfitDetails(outfit),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Worn ${outfit.timesWorn} ${outfit.timesWorn == 1 ? 'time' : 'times'}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          // Display top 3 items for each category
          for (var entry in topItemsByCategory.entries) ...[
            _sectionTitle('Top 3 ${entry.key}s'),
            _itemList(entry.value),
            const SizedBox(height: 24),
          ],
          // Display never worn items
          _sectionTitle('Never Worn Items'),
          _itemList(neverWornItems, isNeverWorn: true),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Styled section title widget
  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(title, style: kH2),
      );

  // Horizontal list of items for display (worn or unworn)
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
              color: isNeverWorn ? Colors.red[50] : Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                // Item image or fallback icon
                Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                  child: item.url.isNotEmpty
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                          child: Image.network(
                            item.url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.checkroom,
                                size: 40,
                                color: isNeverWorn ? Colors.red : null,
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.checkroom,
                            size: 40,
                            color: isNeverWorn ? Colors.red : null,
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
                      const SizedBox(height: 4),
                      Text(
                        isNeverWorn 
                          ? 'Never worn' 
                          : '$wearCount ${wearCount == 1 ? 'wear' : 'wears'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isNeverWorn ? Colors.red : Colors.grey[700],
                        ),
                      ),
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

  // Navigate to outfit detail screen and refresh data on return if changes occurred
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
    if (result == true) _loadInsightsData();
  }
}
