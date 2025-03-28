import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/choose_item_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/item_container.dart';
import 'package:flutter/material.dart';

class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(
        showBackButton: true,
      ), // Replaces the hamburger menu icon with a back arrow to allow the user to go back
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Scrollable Outfit Image Section
            SizedBox(
              height: screenHeight * 0.72, // scroll area height
              width: screenWidth,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.8),
                  child: SizedBox(
                    height: screenHeight * 0.8,
                    child: Stack(
                      children: [
                        Positioned(
                          top: screenHeight * 0.03,
                          left: screenWidth * 0.0,
                          child: outfitItem(
                            "Top",
                            screenWidth,
                            onTap: () async {
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Top"),
                                ),
                              );

                              if (selectedItemUrl != null) {
                                print('Selected Top URL: $selectedItemUrl');
                                // TODO: Handle selected item for "Top"
                                // We would want to display it in the container
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.25,
                          right: screenWidth * 0.0,
                          child: outfitItem(
                            "Bottom",
                            screenWidth,
                            onTap: () async {
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Bottom"),
                                ),
                              );

                              if (selectedItemUrl != null) {
                                print('Selected Bottom URL: $selectedItemUrl');
                                // TODO: Handle selected item for "Bottom"
                              }
                            },
                          ),
                        ),
                        Positioned(
                          top: screenHeight * 0.45,
                          left: screenWidth * 0.0,
                          child: outfitItem(
                            "Shoes",
                            screenWidth,
                            onTap: () async {
                              final selectedItemUrl = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChooseItemScreen(category: "Shoes"),
                                ),
                              );

                              if (selectedItemUrl != null) {
                                print('Selected Shoes URL: $selectedItemUrl');
                                // TODO: Handle selected item for "Shoes"
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                maxLength: 15,
                decoration: const InputDecoration(
                  hintText: "Add a name for your outfit",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0), // Adjust radius here
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    borderSide: BorderSide(
                      color: Colors.black, // Border color when not focused
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(12.0),
                    ),
                    
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }
}
