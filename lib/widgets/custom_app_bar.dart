


     
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants.dart';

import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  
  final bool showBackButton;

  // If the user is on the OutfitSuggestedScreen, replace the menu icon with a back arrow
  // to allow them to return to the home page
  const CustomAppBar({super.key, this.showBackButton = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kBackgroundColor,
      title: SvgPicture.asset("lib/assets/icons/Logo_type.svg"),
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black, size: 40),
              onPressed: () => Navigator.pop(context),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SvgPicture.asset('lib/assets/icons/menu.svg'),
            ),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Handle profile navigation
          },
          icon: SvgPicture.asset('lib/assets/icons/account.svg'),
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
