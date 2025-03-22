
import 'package:dressify_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/screens/landing_screen.dart'; 
// Import the pages you want to see in the app here. home will throw an error if the page is not imported here.

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dressify App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(), //This changes the default screen the app will show when launched. Change it to the screen you want to show first.
    );
  }
}