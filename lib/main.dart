

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

//import 'package:firebase_app_check/firebase_app_check.dart'; //it is used for App Check 
//import 'package:dressify_app/services/surprise_me_service.dart';



// Import the pages you want to see in the app here. home will throw an error if the page is not imported here.

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /*// Activate App Check in DEBUG mode
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Print debug token so you can register it in Firebase Console
  final token = await FirebaseAppCheck.instance.getToken(true);
  print("🔐 DEBUG APP CHECK TOKEN: $token");*/


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


      home: const ProfileSettingsScreen(username:'stefania'), //This changes the default screen the app will show when launched. Change it to the screen you want to show first.


    );
  }
}