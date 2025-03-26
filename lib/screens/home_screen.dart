import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/add_item_screen.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/widgets/custom_button_2.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),

      //App Bar
      appBar: CustomAppBar(),

      // Body
      body: Container(
        padding: EdgeInsets.only(top: screenHeight * 0.06),
        child: Column(
          spacing: screenHeight * 0.02,
          children: [
            //Weather
            Column(
              spacing: 0,
              children: [
                //Condition
                Image.asset(
                  'lib/assets/icons/fluent_weather-hail-day-24-regular.png',
                ),
                //Location
                Text(
                  'Fairfax', // TODO: Pull actual location data
                  textAlign: TextAlign.center,
                  style: kBodyMedium,
                ),
                //Temperature
                Text(
                  '54°F', // TODO: Pull actual weather data
                  style: GoogleFonts.lato(textStyle: kBodyLarge),
                ),
                Text(
                  '37° - 64°', // TODO: Pull actual weather data. I am also not sure what the range represents--maybe we don't need this
                  style: kBodyMedium,
                ),
              ],
            ),

            // Insights
            Column(
              spacing: screenHeight * 0.012,
              children: [
                Text('Insight your wardrobe',
                    textAlign: TextAlign.center, style: kH3),
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Row(
                    spacing: screenWidth * 0.05,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            '45', // TODO: pull actual data from database
                            textAlign: TextAlign.center,
                            style: kH3,
                          ),
                          Text(
                            'Tops',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.playfairDisplay(textStyle: kH3),
                          )
                        ],
                      ),
                      Container(
                        width: screenWidth * 0.005,
                        height: screenHeight * 0.12,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF302D30),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '23', // TODO: Pull actual data from database
                            textAlign: TextAlign.center,
                            style: kH2,
                          ),
                          Text(
                            'Bottoms',
                            textAlign: TextAlign.center,
                            style: kH3,
                          ),
                        ],
                      ),
                      Container(
                        width: screenWidth * 0.005,
                        height: screenHeight * 0.12,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF302D30),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '12', // TODO: Pull actual data from database
                            textAlign: TextAlign.center,
                            style: kH2,
                          ),
                          Text(
                            'Shoes',
                            textAlign: TextAlign.center,
                            style: kH3,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Buttons
            Container(
              // padding: EdgeInsets.all(20),
              child: Column(
                spacing: screenHeight * 0.01,
                children: [
                  CustomButton2(
                    text: 'CREATE OUTFIT',
                    onPressed: () {
                    
                      // TODO: Implement button functionality after the create outfit page is complete
                    },
                  ),
                  CustomButton2(
                    text: 'PLAY IT SAFE',
                    onPressed: () {
                      // TODO: before navigating we need to select an outfit from favorites, retrieve each item's ID
                      // and pass them to the OutfitSuggestionScreen so the images can be displayed
                      // The OutfitSuggestionScreen will be modidfied to maybe take 3 parameters: topId, bottomID and shoeID

                      // TODO: When we navigate to the display outfit screen by clicking this button-- we should not see the option to add an outfit to favorites
                      // as the item is already pulled from the user's favorite outfits. We will need to modify the DisplayOutfitScreen to take a boolean argument
                      // that will determine whether the favorite button is displayed or not.
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const OutfitSuggestionScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                  CustomButton2(
                    // TODO: Implement AI feature and retrieve the ID's of the outfit components to pass to OutfitSuggestionScreen.
                    text: 'SURPRISE ME',
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  const OutfitSuggestionScreen(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
