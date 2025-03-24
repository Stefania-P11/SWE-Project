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

class OutfitSuggestion extends StatefulWidget {
  const OutfitSuggestion({super.key});

  @override
  State<OutfitSuggestion> createState() => _OutfitSuggestionState();
}

class _OutfitSuggestionState extends State<OutfitSuggestion> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          // Scrollable Outfit Image Section
          SizedBox(
            height: screenHeight * 0.72, // scroll area height
            width: screenWidth,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.8),
                child: SizedBox(
                  height: screenHeight * 0.8, 
                  child: Stack(
                    children: [
                      Positioned(
                        top: screenHeight * 0.03,
                        left: screenWidth * 0.0,
                        child: outfitItem("Top", screenWidth),
                      ),
                      Positioned(
                        top: screenHeight * 0.25,
                        right: screenWidth * 0.0,
                        child: outfitItem("Bottom", screenWidth),
                      ),
                      Positioned(
                        top: screenHeight * 0.45,
                        left: screenWidth * 0.0,
                        child: outfitItem("Shoes", screenWidth),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          SizedBox(height: screenHeight * 0.03),
          
          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                iconSize: screenWidth * 0.1,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    isFavorite = !isFavorite;
                  });

                  // TODO: Add favorite logic here
                },
              ),
              IconButton(
                iconSize: screenWidth * 0.1,
                icon: const Icon(Icons.autorenew),
                onPressed: () {
                  // TODO: Add regenerate logic here
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
