import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';


class CustomButton3 extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isActive;


  const CustomButton3({
    super.key,
    required this.onPressed,
    required this.label,
    this.isActive = true,
  });


  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Responsive dimensions based on screen width/height
    final double buttonWidth = screenSize.width * 0.4;  // 45% of screen width
    final double buttonHeight = screenSize.height * 0.055; // 6% of screen height
    final double borderRadius = 45; 
    
    return ElevatedButton(
      onPressed: isActive ? onPressed : null, // Disable button when inactive
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: isActive ? Colors.black : Colors.white,
        minimumSize: Size(buttonWidth, buttonHeight),
      ),
      child: Text(
        label,
        style: kButtons.copyWith(fontWeight: FontWeight.w600, color: isActive ? Colors.white : Colors.black),
        
      ),
    );
  }
}
