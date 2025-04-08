import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

Widget outfitItem(String label, double screenWidth,
    {VoidCallback? onTap, String? imageUrl}) {
  Widget item = Stack(
    alignment: const Alignment(0.0, -0.7),
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                width: screenWidth,
                height: 420,
                fit: BoxFit.fitWidth,
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                  "lib/assets/images/item-image.svg", // Fallback image
                  width: screenWidth,
                  height: 420,
                  fit: BoxFit.fitHeight,
                ),
              )
            : SvgPicture.asset(
                "lib/assets/images/item-image.svg", // Default asset if no image URL
                width: screenWidth,
                height: 420,
                fit: BoxFit.fitHeight,
              ),
      ),
      // 👇 Show label only if imageUrl is empty or null
      if (imageUrl == null || imageUrl.isEmpty) Text(label, style: kButtons),
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
