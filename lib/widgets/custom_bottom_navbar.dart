import 'package:dressify_app/constants.dart';
import 'package:flutter/material.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          Container(
            color: Colors.black,
            height: 1.0,
            width: double.infinity,
          ),
        
        
        BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: kBackgroundColor,
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
        ),
      ],
    
    );
  }
}
