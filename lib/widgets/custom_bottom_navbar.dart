import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/closet_items_screen.dart';
import 'package:dressify_app/screens/favorites_screen.dart';
import 'package:dressify_app/screens/home_screen.dart';
import 'package:dressify_app/screens/insights_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  void _navigateTo(BuildContext context, Widget screen) {
    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Avoid navigating to the same screen (if pressing the home icon from the home screen nothign should happen)
    if (screen.runtimeType.toString() == currentRoute) return;

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration:
            Duration(milliseconds: 0), // No animation when changing screens
        settings: RouteSettings(
            name: screen.runtimeType.toString()), // Set route name
      ),
    );
  }

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
          backgroundColor: kappBarColor,
          onTap: (index) {
            switch (index) {
              case 0:
                _navigateTo(context, const HomeScreen());
                break;
              case 1:
                _navigateTo(context, const ClosetItemsScreen());
                break;
              case 2:
                _navigateTo(context, const FavoritesScreen());
                break;
              case 3:
                _navigateTo(context, const InsightsScreen());
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset("lib/assets/icons/heroicons_home.svg"),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset("lib/assets/icons/solar_hanger-bold.svg"),
              label: 'Wardrobe',
            ),
            BottomNavigationBarItem(
              icon:
                  SvgPicture.asset("lib/assets/icons/solar_heart-outline.svg"),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                "lib/assets/icons/material-symbols-light_search-insights-rounded.svg",
              ),
              label: 'Insights',
            ),
          ],
        ),
      ],
    );
  }
}
