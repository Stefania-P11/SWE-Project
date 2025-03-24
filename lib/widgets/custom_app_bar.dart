import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset("lib/assets/icons/header_logo_type.png"),
      backgroundColor: kBackgroundColor,
      leading: Image.asset('lib/assets/icons/menu.png'),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement navigation
          },
          icon: Image.asset('lib/assets/icons/account.png'),
        ),
      ],
       bottom: PreferredSize(
      preferredSize: const Size.fromHeight(1.0), // height of the line
      child: Container(
        color: Colors.black, // adjust color & opacity
        height: 1.0,
        width: double.infinity,
      ),
    ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
