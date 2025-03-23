import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

class CustomButton2 extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton2({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: kButtonColor,
        foregroundColor: Colors.white,
        minimumSize: const Size(215, 46),
      ),
      child: Text(
        text,
        style: kButtons2(screenWidth),
      ),
    );
  }
}
