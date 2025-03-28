import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

Widget outfitItem(String label, double screenWidth, {VoidCallback? onTap, String? imageUrl}) {
  Widget item = Stack(
    alignment: const Alignment(0.0, -0.7),
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: screenWidth * 0.52,
                height: screenWidth * 0.52,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "lib/assets/images/item-image.png", // Fallback image
                  width: screenWidth * 0.52,
                  height: screenWidth * 0.52,
                  fit: BoxFit.cover,
                ),
              )
            : Image.asset(
                "lib/assets/images/item-image.png", // Default asset if no image URL
                width: screenWidth * 0.52,
                height: screenWidth * 0.52,
                fit: BoxFit.cover,
              ),
      ),
      Text(label, style: kButtons),
    ],
  );

  // If onTap is provided, wrap with GestureDetector to make it clickable
  if (onTap != null) {
    return GestureDetector(
      onTap: onTap,
      child: item,
    );
  } else {
    return item; // If onTap is not provided do not make the container clickable
  }
}
