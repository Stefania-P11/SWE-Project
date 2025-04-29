import 'package:dressify_app/screens/authentication_screen.dart';
import 'package:dressify_app/screens/home_screen.dart';
import 'package:flutter/material.dart'; // Import Flutter Material Design package
import 'package:dressify_app/widgets/custom_button.dart'; // Import the custom button widget
import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:flutter_svg/flutter_svg.dart';

/// LandingScreen - The initial screen that welcomes the user
/// Displays the app logo, title, and buttons for 'Create Account' and 'Log in'
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Set the background color defined in constants.dart
      // backgroundColor: kBackgroundColor,

      /// Stack is used to layer widgets on top of each other
      body: Stack(alignment: Alignment.center, children: [
        //Photo background
        Image.asset('lib/assets/images/LandingBackground.png',
            width: double.infinity, height: double.infinity, fit: BoxFit.cover),

        /// Display the welcome text at the top
        Positioned(
          top: screenHeight * 0.15, // Position 10% from the top of the screen
          left: screenWidth * 0.2, // Position 20% from the left
          child: Text(
            'Welcome to ', // Static welcome text
            style: kH1.copyWith(
                color:
                    kPressedColor), // Apply style defined in constants.dart
          ),
        ),

        /// Display the logo text (Logo_Type.png) below the logo
        Positioned(
          top: screenHeight * 0.40, // Position 55% from the top
          left: screenWidth * 0.08, // Position 8% from the left

          child: SvgPicture.asset(
            "lib/assets/images/Logo_type_color.svg",
            width: screenWidth * 0.85, // Logo width is 85% of screen width
          ),
        ),

        // Create Account button
          Positioned(
            top: screenHeight * 0.73,
            child: CustomButton(
              text: 'Create Account',
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AuthScreen(isLogin: false),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),

          // Log In button
          Positioned(
            top: screenHeight * 0.81,
            child: CustomButton(
              text: 'Log in',
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const AuthScreen(isLogin: true),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}