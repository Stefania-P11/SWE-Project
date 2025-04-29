import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
import 'package:dressify_app/services/firebase_service.dart'; // Import FirebaseService for local/firestore actions
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Custom app bar
import 'package:dressify_app/widgets/custom_button_3.dart';
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
  final bool showWearIcon; 

  const OutfitSuggestionScreen({
    super.key,
    this.showFavorite = true,
    this.showRegenerate = true,
    this.outfit,
    this.onRegenerate,
    this.showDeleteIcon = true,
    this.showWearIcon = true,
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

// Save the outfit to Firestore (cloud database) with the provided name and item details
    await FirebaseService.addFirestoreOutfit(
      outfitName, // User-defined name for the outfit
      outfit.id, // Unique ID of the outfit
      outfit.topItem, // Top clothing item
      outfit.bottomItem, // Bottom clothing item
      outfit.shoeItem, // Shoe item
      outfit.timesWorn, // Number of times the outfit has been worn
      outfit.weather, // Weather tags associated with this outfit
    );

// Save the same outfit locally (e.g., cached or stored for offline use)
    FirebaseService.addLocalOutfit(
      outfitName,
      outfit.id,
      outfit.topItem,
      outfit.bottomItem,
      outfit.shoeItem,
      outfit.timesWorn,
      outfit.weather,
    );

// Update UI state to reflect that the outfit is now marked as a favorite
    setState(() => isFavorite = true);

// Show a snackbar message at the top of the screen to confirm the action
    _showTopSnackbarStatic("Outfit added to favorites!");
  }

// Handle user disliking an outfit
  Future<void> handleDislike() async {
    final user = FirebaseAuth.instance.currentUser;
    final outfit = widget.outfit;

    // Check if the user is signed in and an outfit is available
    if (user == null || outfit == null) {
      print('No user or outfit to dislike.');
      return;
    }

    try {
      // Save the disliked outfit to the user's 'DislikedOutfits' subcollection in Firestore
      await FirebaseFirestore.instance
          .collection('users') // Top-level users collection
          .doc(user.uid) // Document for the current user
          .collection('DislikedOutfits') // Subcollection for disliked outfits
          .doc(outfit.id.toString()) // Use outfit ID as document ID
          .set(outfit.toJson()); // Store the outfit as a JSON map

      // Show a confirmation message to the user
      _showTopSnackbarStatic("We'll skip this outfit in the future!");
    } catch (e) {
      // Log any error that occurred during the Firestore operation
      print('Error disliking outfit: $e');
    }
  }

// Handle user liking an outfit
  Future<void> handleLike() async {
    final user = FirebaseAuth.instance.currentUser;
    final outfit = widget.outfit;

    // Check if the user is signed in and an outfit is available
    if (user == null || outfit == null) {
      print('No user or outfit to like.');
      return;
    }

    try {
      // Save the liked outfit to the user's 'LikedOutfits' subcollection in Firestore
      await FirebaseFirestore.instance
          .collection('users') // Top-level users collection
          .doc(user.uid) // Document for the current user
          .collection('LikedOutfits') // Subcollection for liked outfits
          .doc(outfit.id.toString()) // Use outfit ID as document ID
          .set(outfit.toJson()); // Store the outfit as a JSON map

      // Show a confirmation message to the user
      _showTopSnackbarStatic("We'll show you more outfits like this!");
    } catch (e) {
      // Log any error that occurred during the Firestore operation
      print('Error liking outfit: $e');
    }
  }

// Displays a dialog box prompting the user to name their outfit
// Returns the entered name as a String, or null if the user cancels
  Future<String?> _showNameInputDialog(BuildContext context) async {
    TextEditingController controller =
        TextEditingController(); // Controls the text input field
    String inputName = ''; // Stores the current input from the user
    bool isButtonEnabled =
        false; // Tracks if the "Save" button should be active

    // Show a dialog and return the result as a Future<String?>
    return showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors
                  .grey[300], // Set a light gray background for the dialog
              title: const Text('Name your Outfit'), // Dialog title
              content: TextField(
                controller:
                    controller, // Binds the controller to the input field
                autofocus:
                    true, // Automatically focuses on the text field when dialog opens
                onChanged: (value) {
                  inputName = value; // Update inputName with current value
                  // Enable the "Save" button only if the input is not empty
                  setState(() {
                    isButtonEnabled = value.trim().isNotEmpty;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Enter outfit name', // Placeholder text
                ),
              ),
              actions: [
                // Cancel button: closes dialog and returns null
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text("Cancel"),
                ),
                // Save button: only enabled when input is not empty
                TextButton(
                  onPressed: isButtonEnabled
                      ? () => Navigator.pop(
                          context, inputName) // Return the name entered
                      : null, // Disabled if input is empty
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

// Handles the action of "wearing" an outfit by updating item and outfit data
  Future<void> _handleWearOutfit(Outfit outfit) async {
    // Increment the outfit's wear count locally
    outfit.timesWorn++;

    // Update Firestore record for the top item to reflect potential wear-related changes
    await FirebaseService.editFirestoreItemDetails(
      outfit.topItem,
      outfit.topItem.label,
      outfit.topItem.category,
      outfit.topItem.weather,
    );

    // Update Firestore record for the bottom item
    await FirebaseService.editFirestoreItemDetails(
      outfit.bottomItem,
      outfit.bottomItem.label,
      outfit.bottomItem.category,
      outfit.bottomItem.weather,
    );

    // Update Firestore record for the shoe item
    await FirebaseService.editFirestoreItemDetails(
      outfit.shoeItem,
      outfit.shoeItem.label,
      outfit.shoeItem.category,
      outfit.shoeItem.weather,
    );

    // Save the updated outfit back to Firestore with the new wear count
    await FirebaseService.addFirestoreOutfit(
      outfit.label, // Outfit name
      outfit.id, // Unique outfit ID
      outfit.topItem, // Updated top item
      outfit.bottomItem, // Updated bottom item
      outfit.shoeItem, // Updated shoe item
      outfit.timesWorn, // Incremented wear count
      outfit.weather, // Associated weather data
    );

    // Refresh the UI to reflect any updates
    setState(() {});

    // Show a confirmation message at the top of the screen
    _showTopSnackbarStatic("Wear Recorded!");
  }

// Displays a custom snackbar with a success message
  void _showTopSnackbarStatic(String message) {
    final overlay =
        Overlay.of(context); // Get the overlay from the current context
    final screenHeight =
        MediaQuery.of(context).size.height; // Get screen height for positioning

    late OverlayEntry
        overlayEntry; // Declare the overlay entry to insert and later remove

    // Create the overlay entry
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Position the snackbar about halfway down the screen
        top: screenHeight * 0.5,
        left: 20,
        right: 20,
        child: Material(
          color: Colors
              .transparent, // Allow rounded corners and shadows to show naturally
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[300], // Light gray background color
              borderRadius: BorderRadius.circular(12), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: Colors.black12, // Soft shadow
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14), // Internal spacing
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.black87,
                  size: 24,
                ), // Icon to visually indicate success
                const SizedBox(width: 10), // Spacing between icon and text
                Expanded(
                  child: Text(
                    message, // The custom message to display
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

    // Insert the snackbar overlay into the current screen
    overlay.insert(overlayEntry);

    // Automatically remove the snackbar after 2 seconds
    Future.delayed(const Duration(seconds: 2)).then((_) {
      overlayEntry.remove();
    });
  }

  /// Called when the widget is first inserted into the widget tree
  /// Used here for debugging to verify image URLs load correctly
  @override
  void initState() {
    super.initState();

    // Print item image URLs to the console for debugging purposes
    print('Top URL: ${widget.outfit?.topItem.url}');
    print('Bottom URL: ${widget.outfit?.bottomItem.url}');
    print('Shoe URL: ${widget.outfit?.shoeItem.url}');
  }

  /// Handles the deletion of an outfit, including confirmation prompt and cleanup
  void _handleDeleteOutfit() {
    if (widget.outfit != null) {
      // Show a confirmation dialog before deleting the outfit
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[300], // Consistent dialog background
          title: const Text("Delete Outfit"), // Dialog title
          content: const Text(
            "Are you sure you want to permanently delete this outfit?",
          ), // Warning message
          actions: [
            // Cancel button: just closes the dialog
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            // Delete button: confirms deletion and performs cleanup
            TextButton(
              onPressed: () async {
                // Remove outfit from Firestore (cloud database)
                FirebaseService.removeFirestoreOutfit(widget.outfit!);

                // Remove outfit from local storage/cache
                FirebaseService.removeLocalOutfit(widget.outfit!);

                // Close both the confirmation dialog and the current screen,
                // returning a success flag (true) to the previous screen
                Navigator.pop(context); // Close the alert dialog
                Navigator.pop(context, true); // Pop this screen with result
              },
              child: const Text(
                "Delete",
                style: TextStyle(
                    color: Colors.red), // Highlight destructive action
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth =
        MediaQuery.of(context).size.width; // Get the full screen width
    final screenHeight =
        MediaQuery.of(context).size.height; // Get the full screen height

    return Scaffold(
      backgroundColor:
          kBackgroundColor, // Use the app's global background color

      // Custom app bar with back button and optional delete icon
      appBar: CustomAppBar(
        showBackButton: true, // Always show the back button
        isViewMode: true, // Disables editing mode in app bar
        showEditIcon: false, // Hides edit icon in view mode
        showDeleteIcon: widget.showDeleteIcon, // Conditionally show delete icon
        onDeletePressed:
            _handleDeleteOutfit, // Trigger deletion flow when pressed
      ),

      // Main scrollable body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0), // Page padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Visual display of outfit items (top, bottom, shoe)
              SizedBox(
                height: screenHeight * 0.70,
                width: screenWidth,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.8),
                    child: SizedBox(
                      height: screenHeight * 0.7,
                      child: Column(
                        children: [
                          // Top item display
                          Container(
                            child: outfitItem(
                              "Top",
                              screenWidth * 0.85,
                              imageUrl: widget.outfit?.topItem.url,
                            ),
                          ),

                          // Bottom item display
                          Container(
                            child: outfitItem(
                              "Bottom",
                              screenWidth * 0.85,
                              imageUrl: widget.outfit?.bottomItem.url,
                            ),
                          ),

                          // Shoe item display
                          Container(
                            child: outfitItem(
                              "Shoe",
                              screenWidth * 0.85,
                              imageUrl: widget.outfit?.shoeItem.url,
                            ),
                          ),

                          //Label
                          Text(widget.outfit!.label, style: kH3),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Spacer between outfit display and buttons
              SizedBox(height: screenHeight * 0.03),

              // Action button row (favorite, dislike, like, regenerate, wear)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: widget.showFavorite
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.spaceEvenly,
                  children: [
                    // Thumbs down (dislike) icon
                    if (widget.showFavorite)
                      IconButton(
                        iconSize: screenWidth * 0.08,
                        icon: const Icon(Icons.thumb_down, color: Colors.black),
                        onPressed: () async {
                          print("Thumbs down pressed");
                          await handleDislike();
                          if (widget.onRegenerate != null)
                            widget
                                .onRegenerate!(); // Trigger regenerate if provided
                        },
                      ),

                    // Favorite toggle (heart icon)
                    if (widget.showFavorite)
                      IconButton(
                        iconSize: screenWidth * 0.1,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          if (widget.outfit != null) {
                            _toggleFavorite(); // Save outfit to favorites
                          }
                        },
                      ),

                  Row(
  children: [
    if (widget.showRegenerate)
      IconButton(
        iconSize: screenWidth * 0.1,
        icon: const Icon(Icons.autorenew),
        onPressed: widget.onRegenerate ??
            () {
              print("Regenerate pressed");
            },
      ),
    if (widget.showWearIcon)
      Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.05), 
        child: IconButton(
          iconSize: screenWidth * 0.1,
          icon: const Icon(Icons.checkroom, color: Colors.black,),
          onPressed: () {
            if (widget.outfit != null) {
              _handleWearOutfit(widget.outfit!);
            }
          },
        ),
      ),
  ],
),


                    // Thumbs up (like) icon
                    if (widget.showFavorite)
                      IconButton(
                        iconSize: screenWidth * 0.08,
                        icon: const Icon(Icons.thumb_up, color: Colors.black),
                        onPressed: () async {
                          print("Thumbs up pressed");
                          await handleLike(); // Save outfit as liked
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//TODO: This code might need refactoring to be more readable and maintainable.
//      Some widgets can be extracte and methods can be simplified to do one thing only.
