import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

Widget outfitItem(String label, double screenWidth) {
  return Stack(
    alignment: const Alignment(0.0, -0.7),
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16), // Adjust corner radius here
        child: IconButton(
          onPressed: () {},
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Image.asset(
            "lib/assets/images/item-image.png",
            width: screenWidth * 0.52,
            height: screenWidth * 0.52,
            fit: BoxFit.cover,
          ),
        ),
      ),
      Text(label, style: kButtons),
    ],
  );
}
