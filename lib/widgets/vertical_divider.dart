import 'package:flutter/material.dart';


Widget BuildDivider(double screenWidth, double screenHeight) {
  return Container(
    width: screenWidth * 0.005,
    height: screenHeight * 0.12,
    decoration: const BoxDecoration(
      color: Color(0xFF302D30),
    ),
  );
}