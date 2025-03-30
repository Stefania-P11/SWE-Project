import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dressify_app/constants.dart';

Widget BuildCountColumn(String label, int count, TextStyle textStyle) {
  return Column(
    children: [
      Text(
        '$count',
        textAlign: TextAlign.center,
        style: textStyle,
      ),
      Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.playfairDisplay(textStyle: kH3),
      ),
    ],
  );
}


