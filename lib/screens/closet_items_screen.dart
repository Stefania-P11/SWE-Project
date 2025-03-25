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


class ClosetItemsScreen extends StatelessWidget {
  const ClosetItemsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Please use these variables when setting padding, margins and container sizes to make the app responsive
    final screenHeight = MediaQuery.of(context).size.height; // Please use these variables when setting padding, margins and container sizes to make the app responsive
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      
      //App Bar
      appBar: CustomAppBar(), // this app bar is defined in lib/widgets/custom_app_bar.dart

      // Body -- HERE IS WHERE YOU WILL ADD THE 3 BODY ELEMENTS

      // This is what this should look like:
      // "Your Wardrobe" -- use a defined constant for text style
      // Container:
      //  - Row 1: Container 1, Container 2
      //  - Row 2: Container 3, Container 4
      //  - Row 3: Container 5, Container 6
      // NOTE: You should define a variable (e.g. numberOfItems) which will dictate how many containers will be created.
      //       For now, you can set it to a fixed number and keep changing it to see how the layout changes.
      //       Once we get the DB analytics and we know how many items we have in each category, that variable will then use that infomation to decide how many containers to build
      // This is the end of the main container
      // Row containing 4 filter buttons ( do not worry about the functionality but you cand have all filters appear as buttons with white background and black text,
      // and the selected filter will have a black background and white text -- we can default to All being selected). So just make the buttons change appearance when tapped for now)
      
      body: Center(
        child: CustomButton3(
          onPressed: () {
            // Add functionality here
             Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    const AddItemScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
          },
         label : 'Add New Item',
        ),
      ),

      bottomNavigationBar: const CustomNavBar() // this is defined in lib/widgets/custom_bottom_navbar.dart
    );
  }
}
