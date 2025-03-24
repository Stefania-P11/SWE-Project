import 'package:dressify_app/constants.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/widgets/custom_button_2.dart';
import 'package:dressify_app/widgets/custom_button_3.dart';
import 'package:dressify_app/widgets/item_container.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// NOTE: I DO NOT THINK WE NEED THE NAME YOUR OUTFIT FIELD HERE BECAUSE WE WILL ONLY NAME IT WHEN
// WE SAVE IT TO FAVORITES. IN WHICH CASE-- WHEN THE HEART IS TAPPED, WE CAN BRING A PUP UP FIELD
// THAT ASKS FOR A NAME.

class OutfitSuggestion extends StatelessWidget {
  const OutfitSuggestion({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    bool isFavorite = false;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [


          // Outfit & Action Buttons Stack
          SizedBox(
            width: screenWidth,
            height: screenHeight * 0.72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outfit Item Images
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.8,
                  ),
                  child: // Outfit Items Overlapping Using Positioned
Stack(
  children: [
    // Top item (center top)
    Positioned(
      top: screenHeight * 0.025,
      left: screenWidth * 0.0,
      child: outfitItem("Top", screenWidth),
    ),

    // Bottom item (center-right, overlapping top slightly)
    Positioned(
      top: screenHeight * 0.22,
      right: screenWidth * 0.0,
      child: outfitItem("Bottom", screenWidth),
    ),

    // Shoes item (bottom-left, overlapping bottom slightly)
    Positioned(
      top: screenHeight * 0.42,
      left: screenWidth * 0.0,
      child: outfitItem("Shoes", screenWidth),
    ),
  ],
)

                ),

                // Floating Favorite Button
                Positioned(
                  top: screenHeight * 0.67,
                  left: screenWidth * 0.3,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return IconButton(
                        iconSize: screenWidth * 0.1,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                        },
                      );
                    },
                  ),
                ),

                // Floating Regenerate Button
                Positioned(
                  top: screenHeight * 0.67,
                  right: screenWidth * 0.3,
                  child: IconButton(
                    iconSize: screenWidth * 0.1,
                    icon: const Icon(Icons.autorenew),
                    onPressed: () {
                      // TODO: Add regenerate logic here
                    },
                  ),
                ),
              ],
            ),
          ),

          // Label field (currently commented out)
          /*
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.025),
            child: Container(
              width: screenWidth * 0.7,
              height: screenHeight * 0.055,
              padding: EdgeInsets.all(screenWidth * 0.015),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1,
                    color: const Color(0xFF595856),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'Name your outfit',
                style: kHintText,
              ),
            ),
          ),
          */
        ],
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
