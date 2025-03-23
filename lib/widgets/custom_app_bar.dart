import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset("lib/assets/icons/header_logo_type.png"),
      backgroundColor: kappBarColor,
      leading: Image.asset('lib/assets/icons/menu.png'),
      actions: [
        IconButton(
          onPressed: () {
            // TODO: Implement navigation
          },
          icon: Image.asset('lib/assets/icons/account.png'),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
