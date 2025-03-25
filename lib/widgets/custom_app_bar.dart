


     
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final bool showBackButton;

  // If the user is on the OutfitSuggestedScreen, replace the menu icon with a back arrow
  // to allow them to return to the home page
  const CustomAppBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kBackgroundColor,
      title: Image.asset("lib/assets/icons/header_logo_type.png"),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black, size: 40),
              onPressed: () => Navigator.pop(context),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset('lib/assets/icons/menu.png'),
            ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Handle profile navigation
          },
          icon: Image.asset('lib/assets/icons/account.png'),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: Colors.black,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
