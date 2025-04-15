import 'package:dressify_app/screens/home_screen.dart';
import 'package:flutter/material.dart'; // Import Flutter Material Design package
import 'package:dressify_app/widgets/custom_button.dart'; // Import the custom button widget
import 'package:dressify_app/constants.dart'; // Import global constants and styles
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dressify_app/widgets/label_input_field.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: screenHeight * 0.10, // Position 10% from the top
            left: screenWidth * 0.08, // Position 8% from the left
            child: SvgPicture.asset(
              "lib/assets/images/Logo_Type.svg",
              width: screenWidth * 0.85, // Logo width is 85% of screen width
            ),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('User Name:'),
                        const SizedBox(height: 40),
                        // Input field for username
                        // LabelInputField(
                        //   controller: username,
                        //   hintText: "Add a name for your outfit",
                        // ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text('Password:'),
                        const SizedBox(height: 40),
                        // Input field for username
                        // LabelInputField(
                        //   controller: username,
                        //   hintText: "Add a name for your outfit",
                        // ),
                      ],
                    ),
                  ],
                ),
              ])
        ],
      ),
    );
  }
}
