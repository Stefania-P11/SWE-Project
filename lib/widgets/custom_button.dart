import 'package:flutter/material.dart';
import '../constants.dart';


class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: screenWidth * 0.25),
      child: Material(
        color: kButtonColor, 
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: screenWidth * 0.36,
            height: MediaQuery.of(context).size.height * 0.06,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(10),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: kButtons(screenWidth),
            ),
          ),
        ),
      ),
    );
  }
}
