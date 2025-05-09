//This file will contain the background/font colors, text styles and other design components that we will use throughout the app
//It is useful to only use constants because if we wanted to change the style of the headers for example, ity will only have to be done once here and it will apply to the entire app.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Constant for the username used in Firestore
String kUsername = ""; // Replaced with actual username in handleAuth()

// COLORS

const Color kBackgroundColor = Color.fromARGB(255, 255, 255, 255);
const Color kOvalShapeColor = Colors.white;
const Color kButtonColor = Color(0xFF302D30);
const Color kappBarColor = Color.fromARGB(255, 255, 255, 255);
const Color kPressedColor = Color(0xFFD37F59);

// TEXT STYLES

TextStyle kH1 = GoogleFonts.playfairDisplay(
  textStyle: TextStyle(
    color: Colors.black,
    fontSize: 48,
    fontStyle: FontStyle.italic,
    fontFamily: 'Playfair Display',
    fontWeight: FontWeight.w400,
  ),
);

TextStyle kH2 = GoogleFonts.playfairDisplay(
  textStyle: TextStyle(
    color: Color(0xFF302D30),
    fontSize: 24,
    fontWeight: FontWeight.w400,
  ),
);

TextStyle kH3 = GoogleFonts.playfairDisplay(
  textStyle: TextStyle(
    color: const Color(0xFF302D30),
    fontSize: 18,
    fontWeight: FontWeight.w400,
  ),
);

TextStyle kBodyLarge = GoogleFonts.lato(
  textStyle: TextStyle(
    color: Colors.black,
    fontSize: 36, // Larger text for primary numbers
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w800,
  ),
);

TextStyle kBodyMedium = GoogleFonts.lato(
  textStyle: TextStyle(
    color: Colors.black,
    fontSize: 24, // Medium text for secondary numbers
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.w400,
  ),
);

TextStyle kButtons = GoogleFonts.lato(
  textStyle: TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontFamily: 'Lato',
    fontWeight: FontWeight.w400,
  ),
);

TextStyle kButtons2(double screenWidth) => GoogleFonts.lato(
      textStyle: TextStyle(
        color: Colors.white,
        fontSize: screenWidth * 0.045, // Adjust for responsiveness
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
      ),
    );

TextStyle kHintText = TextStyle(
  color: Color(0xFFCBCBCB),
  fontSize: 18,
  fontFamily: 'Lato',
  fontWeight: FontWeight.w400,
);

const TextStyle kErrorMessage = TextStyle(
  color: Colors.red,
  fontSize: 12, 
  fontFamily: 'Lato', 
  fontWeight: FontWeight.w400, 
);
