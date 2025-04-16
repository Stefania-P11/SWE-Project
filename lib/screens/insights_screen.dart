import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:dressify_app/constants.dart'; // Import global constants and styles

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(),
      body: const Center(
        child: Text(
          'Style insights and stats will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
