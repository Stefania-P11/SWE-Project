// This screen will allow the user to add a new clothing item to their closet
// It will consist of:
//1) App Bar -- which I already added in.
//2) Body-- which will contain 6 elements: 1) "Add New Item" text (use one of the styles defined in the constants.dart (e.g kH1 or kH2)
                                        // 2) Container that will display the clothing item once uploaded (do not worry about the functionality yet-- but
                                        //    this containerwhen clicked will open a prompt asking the user if they want to upload an image from gallery or take a picture) To be done later on
                                        // 2) A text input field for the item name (this will take maximum 15 characters including whitespaces and will have a hint text: "Name your item")
                                              // -- the text input should have a label "Name" displayed above it.
                                        // 3) Category selection buttons that will allow the user to select the category the item should be added in (do not worry about the functionality-- just add the buttons)
                                        // 4) Temperature selection buttons that will allow the user to select the appropriate temperature for their item (can choose more than one; the 4 options are: hot, warm, cool and cold)
                                        // 5) A row containing 2 buttons: "Save" and "Cancel" (you can reuse the custom_button widget inside the widget folder)
//3) Bottom Navigation Bar -- which I have already added in.

import 'package:dressify_app/constants.dart'; // this allows us to use the constants defined in lib/constants.dart
import 'package:dressify_app/widgets/custom_app_bar.dart'; // this allows us to use the custom app bar defined in lib/widgets/custom_app_bar.dart
import 'package:dressify_app/widgets/custom_bottom_navbar.dart'; // this allows us to use the custom bottom navigation bar defined in lib/widgets/custom_bottom_navbar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width; // Please use these variables when setting padding, margins and container sizes to make the app responsive
    final screenHeight = MediaQuery.of(context).size.height; // Please use these variables when setting padding, margins and container sizes to make the app responsive
    
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),
      
      //App Bar
      appBar: CustomAppBar(), // this app bar is defined in lib/widgets/custom_app_bar.dart

      // Body -- HERE IS WHERE YOU WILL ADD THE 6 BODY ELEMENTS

      // This is what this should look like:
      // "Add New Item" -- use a defined constant for text style
      // Image Container
      // Text Input Field for item name
      // For the category and temperature selecton buttons, make the inactive versin have a white background and black text and flip it for the active version-- default to the first option being selected.
      // Category Selection Buttons
      // Temperature Selection Buttons
      // Row containing 2 buttons: "Save" and "Cancel" (you can reuse the custom_button widget inside the widget folder)
                // Here, we want to make the Save Button inactive as long as the user has not uploaded an image, chosen a name or selected Category and Temperature
                // Once all the fields are filled, the Save button should become active and the Cancel button should reset all fields to their default state.
                // You can worry about this part later on as it takes a bit of input validation effort

      bottomNavigationBar: const CustomNavBar() // this is defined in lib/widgets/custom_bottom_navbar.dart
    );
  }
}
