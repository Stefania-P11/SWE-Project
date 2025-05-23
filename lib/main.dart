

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/change_password_screen.dart';
import 'package:dressify_app/screens/home_screen.dart';
import 'package:dressify_app/screens/insights_screen.dart';
import 'package:dressify_app/screens/landing_screen.dart';
import 'package:dressify_app/screens/profile_settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:dressify_app/screens/closet_items_screen.dart';
import 'models/item.dart';




// Import the pages you want to see in the app here. home will throw an error if the page is not imported here.

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


kUsername = "stefania";


  
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