import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton3 extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const CustomButton3({
    super.key,
    required this.onPressed,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    // Responsive dimensions based on screen width/height
    final double buttonWidth = screenSize.width * 0.45;  // 45% of screen width
    final double buttonHeight = screenSize.height * 0.06; // 6% of screen height
    final double borderRadius = screenSize.width * 0.025; 
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        backgroundColor: Colors.black,
        minimumSize: Size(buttonWidth, buttonHeight),
      ),
      child: Text(
        label,
        style: GoogleFonts.lato(
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
