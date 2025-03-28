import 'package:dressify_app/constants.dart'; // this allows us to use the constants defined in lib/constants.dart
import 'package:dressify_app/models/item.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ChooseItemScreen extends StatefulWidget {
  final String category;

  const ChooseItemScreen({super.key, required this.category});

  @override
  State<ChooseItemScreen> createState() => _ChooseItemScreenState();
}

class _ChooseItemScreenState extends State<ChooseItemScreen> {
  List<Item> _items = [];
  bool _isLoading = true;
  String? selectedItemUrl;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    try {
      await Item.fetchItems('username'); // Replace with actual username
      setState(() {
        // Filter items based on the category passed from CreateOutfitScreen
        _items = Item.itemList
            .where((item) => item.category == widget.category)
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      print("Error loading items: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      appBar: CustomAppBar(showBackButton: true), // Custom app bar

      body: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),

          //Text("Choose a ${widget.category}", style: kH2),
          Text(
            widget.category == "Shoes"
                ? "Choose a Pair of Shoes"
                : "Choose a ${widget.category}",
            style: kH2,
          ),
          SizedBox(height: screenHeight * 0.015),

          // Grid View for Items
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text('No items found in this category.'))
                    : GridView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _items.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 3 / 4,
                        ),
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          final isSelected = item.url == selectedItemUrl;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedItemUrl =
                                    item.url; // Mark item as selected
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color:
                                      isSelected ? Colors.blue : Colors.black12,
                                  width: isSelected ? 3 : 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        item.url,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image,
                                                    size: 50,
                                                    color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      item.label,
                                      style: kH3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Add Button to Confirm Selection
          if (selectedItemUrl != null)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.2, vertical: 12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context, selectedItemUrl); // Return selected URL
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Add",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
