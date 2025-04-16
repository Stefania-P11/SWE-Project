import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
import 'package:dressify_app/services/firebase_service.dart'; // Import FirebaseService for local/firestore actions
import 'package:dressify_app/widgets/custom_app_bar.dart'; // Custom app bar
import 'package:dressify_app/widgets/item_container.dart'; // Widget to display individual item in the outfit
import 'package:flutter/material.dart'; // Flutter Material components
import 'package:dressify_app/services/outfit_service.dart';

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

  ///add debugging to make sure everything loads right
  @override
  void initState() {
    super.initState();
    print('Top URL: ${widget.outfit?.topItem.url}');
    print('Bottom URL: ${widget.outfit?.bottomItem.url}');
    print('Shoe URL: ${widget.outfit?.shoeItem.url}');
  }

  /// Show a confirmation dialog before removing the outfit locally
  void _handleDeleteOutfit() {
    if (widget.outfit != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Delete Outfit"),
          content: const Text(
              "Are you sure you want to remove this outfit from favorites?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel dialog
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                FirebaseService.removeLocalOutfit(
                    widget.outfit!); // Remove from local list
                // Also remove from the global list just in case
                Outfit.outfitList.removeWhere((o) => o.id == widget.outfit!.id);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, true); // Return with success result
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
    final screenHeight =
        MediaQuery.of(context).size.height; // Get screen height

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
        padding: EdgeInsets.only(top: screenHeight * 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: screenHeight * 0.5, // Scroll area height
              width: screenWidth,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Left side: Top item (full height)
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Your background color
                          borderRadius: BorderRadius.circular(
                              8), // Optional rounded corners
                        ),
                        child: outfitItem("Top", screenWidth,
                            imageUrl: widget.outfit?.topItem.url),
                      ),
                    ),

                    // Horizontal spacing between Top and the right column
                    const SizedBox(width: 16),

                    // Right side: Column with Bottom and Shoes
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Bottom item with flex 2
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Your background color
                                borderRadius: BorderRadius.circular(
                                    8), // Optional rounded corners
                              ),
                              child: outfitItem("Bottom", screenWidth,
                                  imageUrl: widget.outfit?.bottomItem.url),
                            ),
                          ),

                          // Vertical spacing between Bottom and Shoes
                          const SizedBox(height: 16),

                          // Shoes item as a square box using AspectRatio
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // Your background color
                                borderRadius: BorderRadius.circular(
                                    8), // Optional rounded corners
                              ),
                              child: outfitItem("Shoes", screenWidth,
                                  imageUrl: widget.outfit?.shoeItem.url),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Add spacing between the input field and the next element
            SizedBox(height: screenHeight * 0.03),
            Padding(
              padding: EdgeInsets.all(20),
              //  Action buttons (favorite, regenerate, thumbs)
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
                      onPressed: () {
                        print("Thumbs down pressed");
                        // TODO: Add dislike logic
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
                      // onPressed: () {
                      //   setState(() => isFavorite = !isFavorite);
                      //   // TODO: Show popup for naming and saving favorite
                      // },
                      onPressed: () async {
                        await saveNewOutfit(
                            context: context,
                            topUrl: widget.outfit?.topItem.url,
                            bottomUrl: widget.outfit?.bottomItem.url,
                            shoesUrl: widget.outfit?.shoeItem.url,
                            //Auto assign the name for new outfit
                            label: "Outfit ${Outfit.outfitList.length + 1}");
                      },
                    ),

                  // Regenerate button
                  if (widget.showRegenerate)
                    IconButton(
                      iconSize: screenWidth * 0.1,
                      icon: const Icon(Icons.autorenew),
                      onPressed: widget.onRegenerate ??
                          () {
                            print("Regenerate pressed");
                          },
                    ),

                  // Thumbs up (like)
                  if (widget.showFavorite)
                    IconButton(
                      iconSize: screenWidth * 0.08,
                      icon: const Icon(Icons.thumb_up, color: Colors.black),
                      onPressed: () {
                        print("Thumbs up pressed");
                        // TODO: Add like logic
                      },
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    ); // Spacer
  }
}

// // outfitItem("Top", screenWidth,imageUrl: widget.outfit?.bottomItem.url),
// import 'package:dressify_app/constants.dart'; // Import global constants and styles
// import 'package:dressify_app/models/outfit.dart'; // Import Outfit model
// import 'package:dressify_app/services/firebase_service.dart'; // Import FirebaseService for local/firestore actions
// import 'package:dressify_app/widgets/custom_app_bar.dart'; // Custom app bar
// import 'package:dressify_app/widgets/item_container.dart'; // Widget to display individual item in the outfit
// import 'package:flutter/material.dart'; // Flutter Material components

// /// OutfitSuggestionScreen - Displays a suggested outfit
// /// Features:
// /// - Shows the top, bottom, and shoes of the outfit
// /// - Optionally displays buttons for saving, deleting, or regenerating the outfit
// class OutfitSuggestionScreen extends StatefulWidget {
//   final bool showFavorite; // Whether to show the heart icon
//   final bool showRegenerate; // Whether to show the regenerate icon
//   final bool showDeleteIcon; // Whether to show the trash icon
//   final Outfit? outfit; // The outfit to display
//   final VoidCallback? onRegenerate; // Optional regenerate callback

//   const OutfitSuggestionScreen({
//     super.key,
//     this.showFavorite = true,
//     this.showRegenerate = true,
//     this.outfit,
//     this.onRegenerate,
//     this.showDeleteIcon = true,
//   });

//   @override
//   State<OutfitSuggestionScreen> createState() => _OutfitSuggestionScreenState();
// }

// class _OutfitSuggestionScreenState extends State<OutfitSuggestionScreen> {
//   bool isFavorite = false; // Track favorite state for UI

//   /// Show a confirmation dialog before removing the outfit locally
//   void _handleDeleteOutfit() {
//     if (widget.outfit != null) {
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Delete Outfit"),
//           content: const Text("Are you sure you want to remove this outfit from favorites?"),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context), // Cancel dialog
//               child: const Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () {
//                 FirebaseService.removeLocalOutfit(widget.outfit!); // Remove from local list
//                 // Also remove from the global list just in case
//                 Outfit.outfitList.removeWhere((o) => o.id == widget.outfit!.id);
//                 Navigator.pop(context); // Close dialog
//                 Navigator.pop(context, true); // Return with success result
//               },
//               child: const Text("Delete", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width; // Get screen width
//     final screenHeight = MediaQuery.of(context).size.height; // Get screen height

//     return Scaffold(
//       backgroundColor: kBackgroundColor, // Set background color

//       // Top app bar with optional delete button
//       appBar: CustomAppBar(
//         showBackButton: true,
//         isViewMode: true,
//         showEditIcon: false,
//         showDeleteIcon: widget.showDeleteIcon,
//         onDeletePressed: _handleDeleteOutfit, // Hook up delete callback
//       ),

//       // Main body layout
//       body: Padding(
//         padding: const EdgeInsets.all(8.0), // Screen padding
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             /// Outfit image section (scrollable in case content overflows)
//             SizedBox(
//               height: screenHeight * 0.72,
//               width: screenWidth,
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.8),
//                   child: SizedBox(
//                     height: screenHeight * 0.8,
//                     child: Stack(
//                       children: [
//                         // Display top item image
//                         Positioned(
//                           top: screenHeight * 0.03,
//                           left: screenWidth * 0.0,
//                           child: outfitItem("Top", screenWidth, imageUrl: widget.outfit?.topItem.url),
//                         ),
//                         // Display bottom item image
//                         Positioned(
//                           top: screenHeight * 0.25,
//                           right: screenWidth * 0.0,
//                           child: outfitItem("Bottom", screenWidth, imageUrl: widget.outfit?.bottomItem.url),
//                         ),
//                         // Display shoes item image
//                         Positioned(
//                           top: screenHeight * 0.45,
//                           left: screenWidth * 0.0,
//                           child: outfitItem("Shoes", screenWidth, imageUrl: widget.outfit?.shoeItem.url),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             SizedBox(height: screenHeight * 0.03), // Spacer

//             /// Action buttons (favorite, regenerate, thumbs)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 10.0),
//               child: Row(
//                 mainAxisAlignment: widget.showFavorite
//                     ? MainAxisAlignment.spaceBetween
//                     : MainAxisAlignment.spaceEvenly,
//                 children: [
//                   // Thumbs down (dislike)
//                   if (widget.showFavorite)
//                     IconButton(
//                       iconSize: screenWidth * 0.08,
//                       icon: const Icon(Icons.thumb_down, color: Colors.black),
//                       onPressed: () {
//                         print("Thumbs down pressed");
//                         // TODO: Add dislike logic
//                       },
//                     ),

//                   // Heart icon (toggle favorite)
//                   if (widget.showFavorite)
//                     IconButton(
//                       iconSize: screenWidth * 0.1,
//                       icon: Icon(
//                         isFavorite ? Icons.favorite : Icons.favorite_border,
//                         color: isFavorite ? Colors.red : Colors.black,
//                       ),
//                       onPressed: () {
//                         setState(() => isFavorite = !isFavorite);
//                         // TODO: Show popup for naming and saving favorite
//                       },
//                     ),

//                   // Regenerate button
//                   if (widget.showRegenerate)
//                     IconButton(
//                       iconSize: screenWidth * 0.1,
//                       icon: const Icon(Icons.autorenew),
//                       onPressed: widget.onRegenerate ?? () {
//                         print("Regenerate pressed");
//                       },
//                     ),

//                   // Thumbs up (like)
//                   if (widget.showFavorite)
//                     IconButton(
//                       iconSize: screenWidth * 0.08,
//                       icon: const Icon(Icons.thumb_up, color: Colors.black),
//                       onPressed: () {
//                         print("Thumbs up pressed");
//                         // TODO: Add like logic
//                       },
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
