import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
import 'package:dressify_app/services/firebase_service.dart'; // Import FirebaseService for local/firestore actions
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Custom app bar
import 'package:dressify_app/widgets/item_container.dart'; // Widget to display individual item in the outfit
import 'package:flutter/material.dart'; // Flutter Material components
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// OutfitSuggestionScreen - Displays a suggested outfit
/// Features:
/// - Shows the top, bottom, and shoes of the outfit
/// - Optionally displays buttons for saving, deleting, or regenerating the outfit
class OutfitSuggestionScreen extends StatefulWidget {
  final bool showFavorite; // Whether to show the heart icon
  final bool showRegenerate; // Whether to show the regenerate icon
  final bool showDeleteIcon; // Whether to show the trash icon
  final Outfit? outfit; // The outfit to display
  final VoidCallback? onRegenerate; // Optional regenerate callback

  const OutfitSuggestionScreen({
    super.key,
    this.showFavorite = true,
    this.showRegenerate = true,
    this.outfit,
    this.onRegenerate,
    this.showDeleteIcon = true,
  });

  @override
  State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
}

class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
  bool isFavorite = false; // Track favorite state for UI
  
  Future<void> _toggleFavorite() async {
    final outfit = widget.outfit!;
    
    // Prompt user for name
    String? outfitName = await _showNameInputDialog(context);

    // If user cancels dialog, stop everything
    if (outfitName == null) return;

    // Check if the outfit already exists
    final existing = await FirebaseService.isOutfitFavorited(
      outfit.topItem.id,
      outfit.bottomItem.id,
      outfit.shoeItem.id,
    );

    if (existing) {
      _showTopSnackbarStatic("The Outfit is already in Favorite!");
      return;
    }

    // Add to favorites
    await FirebaseService.addFirestoreOutfit(
      outfitName,
      outfit.id,
      outfit.topItem,
      outfit.bottomItem,
      outfit.shoeItem,
      outfit.timesWorn,
      outfit.weather,
    );

    FirebaseService.addLocalOutfit(
      outfitName,
      outfit.id,
      outfit.topItem,
      outfit.bottomItem,
      outfit.shoeItem,
      outfit.timesWorn,
      outfit.weather,
    );

    setState(() => isFavorite = true);
    _showTopSnackbarStatic("Outfit added to favorites!");
  }
  //handle dislike
  Future<void> handleDislike() async {
    final user = FirebaseAuth.instance.currentUser;
    final outfit = widget.outfit;

    if (user == null || outfit == null) {
      print('No user or outfit to dislike.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('DislikedOutfits')
          .doc(outfit.id.toString())
          .set(outfit.toJson());

      _showTopSnackbarStatic("We'll skip this outfit in the future!");
    } catch (e) {
      print('Error disliking outfit: $e');
    }
  }
  //handle like
  Future<void> handleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    final outfit = widget.outfit;

    if (user == null || outfit == null) {
      print('No user or outfit to like.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('LikedOutfits')
          .doc(outfit.id.toString())
          .set(outfit.toJson());

      _showTopSnackbarStatic("We'll show you more outfits like this!");
    } catch (e) {
      print('Error liking outfit: $e');
    }
  }

  //Name outfit box
  Future<String?> _showNameInputDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    String inputName = '';
    bool isButtonEnabled = false;

    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[300], // Unified background
              title: const Text('Name your Outfit'),
              content: TextField(
                controller: controller,
                autofocus: true,
                onChanged: (value) {
                  inputName = value;
                  setState(() {
                    isButtonEnabled = value.trim().isNotEmpty;
                  });
                },
                decoration: const InputDecoration(hintText: 'Enter outfit name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, null), // Cancel = null
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: isButtonEnabled
                      ? () => Navigator.pop(context, inputName)
                      : null,
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }




/*Future<void> _toggleFavorite() async {
  final outfit = widget.outfit!;
  setState(() => isFavorite = !isFavorite);

  if (isFavorite) {
    // Add to favorites (Firestore + local)
    await FirebaseService.addFirestoreOutfit(
      outfit.label,
      outfit.id,
      outfit.topItem,
      outfit.bottomItem,
      outfit.shoeItem,
      outfit.timesWorn,
      outfit.weather,
    );

    FirebaseService.addLocalOutfit(
      outfit.label,
      outfit.id,
      outfit.topItem,
      outfit.bottomItem,
      outfit.shoeItem,
      outfit.timesWorn,
      outfit.weather,
    );

    _showTopSnackbarStatic("Outfit added to favorites!");
    
  } else {
    // Remove from favorites (Firestore + local)
    FirebaseService.removeFirestoreOutfit(outfit);
    FirebaseService.removeLocalOutfit(outfit);

    _showTopSnackbarStatic("Outfit removed from favorites.");
    
  }
}*/

  void _showTopSnackbarStatic(String message) {
    final overlay = Overlay.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: screenHeight * 0.5, // Around 30% from the top
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // Light gray background
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.black87, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove after 3 seconds
    Future.delayed(const Duration(seconds: 2)).then((_) {
      overlayEntry.remove();
    });
  }

  
  /// Debugging to make sure everything loads righ
  @override
  void initState() {
    super.initState();
    print('Top URL: ${widget.outfit?.topItem.url}');
    print('Bottom URL: ${widget.outfit?.bottomItem.url}');
    print('Shoe URL: ${widget.outfit?.shoeItem.url}');
  }
  void _handleDeleteOutfit() {
  if (widget.outfit != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[300], // Unified background
        title: const Text("Delete Outfit"),
        content: const Text("Are you sure you want to permanently delete this outfit?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Remove from Firestore
              FirebaseService.removeFirestoreOutfit(widget.outfit!);

              // Remove locally
              FirebaseService.removeLocalOutfit(widget.outfit!);

              // Close dialogs and return to previous screen
              Navigator.pop(context); // Close confirmation dialog
              Navigator.pop(context, true); // Return with success flag
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Get screen width
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height

    print('Top URL: ${widget.outfit?.topItem.url}');
    print('Bottom URL: ${widget.outfit?.bottomItem.url}');
    print('Shoe URL: ${widget.outfit?.shoeItem.url}');

    return Scaffold(
      backgroundColor: kBackgroundColor, // Set background color

      // Top app bar with optional delete button
      appBar: CustomAppBar(
        showBackButton: true,
        isViewMode: true,
        showEditIcon: false,
        showDeleteIcon: widget.showDeleteIcon,
        onDeletePressed: _handleDeleteOutfit, // Hook up delete callback
      ),

      // Main body layout
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Screen padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
            height: screenHeight * 0.72,
            width: screenWidth,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.8),
                child: SizedBox(
                  height: screenHeight * 0.8,
                  child: Stack(
                    children: [
                      // 🟦 Top Item
                      Positioned(
                        top: screenHeight * 0.03,
                        left: 0,
                        child: outfitItem(
                          "Top",
                          screenWidth,
                          imageUrl: widget.outfit?.topItem.url,
                        ),
                      ),

                      // 🟨 Bottom Item
                      Positioned(
                        top: screenHeight * 0.25,
                        right: 0,
                        child: outfitItem(
                          "Bottom",
                          screenWidth,
                          imageUrl: widget.outfit?.bottomItem.url,
                        ),
                      ),

                      // 🟩 Shoes Item
                      Positioned(
                        top: screenHeight * 0.45,
                        left: 0,
                        child: outfitItem(
                          "Shoe",
                          screenWidth,
                          imageUrl: widget.outfit?.shoeItem.url,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),


            SizedBox(height: screenHeight * 0.03), // Spacer

            /// Action buttons (favorite, regenerate, thumbs)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: widget.showFavorite
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.spaceEvenly,
                children: [
                  // Thumbs down (dislike)
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth * 0.08,
                      icon: const Icon(Icons.thumb_down, color: Colors.black),
                      onPressed: () async {
                        print("Thumbs down pressed");
                        // TODO: Add dislike logic
                        await handleDislike();
                        if (widget.onRegenerate != null) widget.onRegenerate!(); // Refresh after dislike
                      },
                    ),

                  // Heart icon (toggle favorite)
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth * 0.1,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                      ),
                      onPressed: () {
                        if (widget.outfit != null) {
                          _toggleFavorite();
                        }
                      },
                    ),

                  // Regenerate button
                  if (widget.showRegenerate)
                    IconButton(
                      iconSize: screenWidth * 0.1,
                      icon: const Icon(Icons.autorenew),
                      onPressed: widget.onRegenerate ?? () {
                        print("Regenerate pressed");
                      },
                    ),

                  // Thumbs up (like)
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth * 0.08,
                      icon: const Icon(Icons.thumb_up, color: Colors.black),
                      onPressed: () async {
                        print("Thumbs up pressed");
                        // TODO: Add like logic
                        await handleLike();
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
