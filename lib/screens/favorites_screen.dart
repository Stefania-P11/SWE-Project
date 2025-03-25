import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: const Center(
        child: Text(
          'Your favorite outfits will appear here!',
          style: TextStyle(fontSize: 18),
        ),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }
}
