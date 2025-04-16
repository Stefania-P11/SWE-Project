import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
