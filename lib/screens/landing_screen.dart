import 'package:flutter/material.dart';
import 'package:dressify_app/widgets/custom_button.dart';
import 'package:dressify_app/constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: screenHeight * 0.1,
            left: screenWidth * 0.2,
            child: Text(
              'Welcome to ',
              style: kH1,
              ),
            
          ),
          Positioned(
            top: screenHeight * 0.25,
            left: screenWidth * 0.15,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFD9D9D9),
                    shape: OvalBorder(),
                  ),
                ),
                Image.asset('lib/assets/images/Logo_Mark.png', width: screenWidth * 0.4),
              ],
            ),
          ),
          
   
          Positioned(
            top: screenHeight * 0.55,
            left: screenWidth * 0.08,
            child: Image.asset("lib/assets/images/Logo_Type.png", width: screenWidth * 0.85),
          ),
          Positioned(
            left: screenWidth * 0.32,
            top: screenHeight * 0.73,
            child: CustomButton(
              text: 'Create Account',
              onPressed: () {
                // TODO: Implement navigation
              },
            ),
          ),
          Positioned(
            left: screenWidth * 0.32,
            top: screenHeight * 0.81,
            child: CustomButton(
              text: 'Log in',
              onPressed: () {
                // TODO: Implement navigation
              },
            ),
          ),
        ],
      ),
    );
  }
}