// This screen will display the items in the user's closet
// It will consist of:
//1) App Bar -- which I already added in.
//2) Body-- which will contain 3 elements: 1) "Your Wardrobe" text (use one of the styles defined in the constants.dart (e.g kH1 or kH2)
                                        // 2) A container that will contain a grid of containers (do 2 containers per row as 3 might make the images too small)
                                        // 3) Filter buttons that will allow the user to only display a certain category (do not worry about the functionality-- just add the buttons)
//3) Bottom Navigation Bar -- which I have already added in.

import 'package:dressify_app/constants.dart'; // this allows us to use the constants defined in lib/constants.dart
import 'package:dressify_app/screens/add_item_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart'; // this allows us to use the custom app bar defined in lib/widgets/custom_app_bar.dart
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // this allows us to use the custom bottom navigation bar defined in lib/widgets/custom_bottom_navbar.dart
import 'package:dressify_app/widgets/custom_button_3.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClosetItemsScreen extends StatefulWidget {
  const ClosetItemsScreen({super.key});

  @override
  State<ClosetItemsScreen> createState() => _ClosetItemsScreenState();
}

class _ClosetItemsScreenState extends State<ClosetItemsScreen> {
  String selectedFilter = 'All';
  final filters = ['All', 'Tops', 'Bottoms', 'Shoes'];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      appBar: CustomAppBar(), // this app bar is defined in lib/widgets/custom_app_bar.dart

      // Body -- THE 3 BODY ELEMENTS
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),

                // Title
                Text("Your Wardrobe", style: kH2),

                SizedBox(height: screenHeight * 0.015),

                // Scrollable Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: 6, // placeholder item count
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3 / 4,
                    ),
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 40, color: Colors.black26),
                        ),
                      );
                    },
                  ),
                ),

                // Filter Buttons (always at bottom)
                SizedBox(height: screenHeight * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: filters.map((filter) {
                    final isSelected = selectedFilter == filter;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.012,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              filter,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: screenHeight * 0.03),
              ],
            ),
          ),

          // Floating Add New Item Button
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: CustomButton3(
                label: "Add New Item",
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const AddItemScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
