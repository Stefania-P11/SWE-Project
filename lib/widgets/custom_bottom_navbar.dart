import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: Image.asset("lib/assets/icons/heroicons_home.png"),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("lib/assets/icons/solar_hanger-bold.png"),
          label: 'Wardrobe',
        ),
        BottomNavigationBarItem(
          icon: Image.asset("lib/assets/icons/solar_heart-outline.png"),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Image.asset(
            "lib/assets/icons/material-symbols-light_search-insights-rounded.png",
          ),
          label: 'Insights',
        ),
      ],
    );
  }
}
