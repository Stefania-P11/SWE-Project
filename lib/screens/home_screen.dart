import 'package:dressify_app/constants.dart';
import 'package:dressify_app/features/play_it_safe.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/screens/create_outfit_screen.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/services/item_service.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/widgets/custom_button_2.dart';
import 'package:dressify_app/widgets/item_count_display_column.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dressify_app/widgets/vertical_divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dressify_app/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dressify_app/models/item.dart'; // Needed to use Item.itemList

/// HomeScreen - Displays weather, wardrobe insights, and action buttons
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to indicate if data is still loading
  bool isLoading = true;

  // Counters for items in the wardrobe
  int topCount = 0;
  int bottomCount = 0;
  int shoeCount = 0;

  //shows the users location name
  String locationName = 'Getting location name...';

  @override
  void initState() {
    super.initState();
    // Fetch item data and count when the screen initializes
    fetchData();
    //gets the users current location on the screen
    getUserLocation();
  }

  ///Gets the users location and updates location based on: coordinates and reverse geo-encoding
  Future<void> getUserLocation() async {
    try {
      //finds the positions coordinates of the user
      Position position = await determinePosition();

      //converts the coordinates correctly
      List<Placemark> cordinate = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      //checks if the coordinate data is there
      if (cordinate.isNotEmpty) {
        Placemark address = cordinate[0];

        //checks if the address from the coordinates contains a locailty AKA city name
        if (address.locality != null) {
          //the location name gets updated with the city name
          setState(() {
            locationName = address.locality!;
          });
          print("Location: $locationName");
        } else {
          //the location gets updated to unknown since the address does not have a city
          setState(() {
            locationName = 'Location is unknown';
          });
        }
        //coordinate data is not there, so the location name is unknown
      } else {
        setState(() {
          locationName = 'Location is unknown';
        });
      }
      //catches any error that doesn't allow access to location
    } catch (e) {
      setState(() {
        locationName = 'Location is not available ';
      });
    }
  }

  /// Fetch item data and count items by category using ItemService
  /*Future<void> fetchData() async {
    // Create an instance of ItemService to fetch and count items
    ItemService itemService = ItemService();

    // Fetch item counts for different categories
    Map<String, int> itemCounts =
        await itemService.fetchAndCountItems(kUsername);

    // Update state with the fetched item counts and stop loading indicator
    setState(() {
      topCount = itemCounts['topCount'] ?? 0;
      bottomCount = itemCounts['bottomCount'] ?? 0;
      shoeCount = itemCounts['shoeCount'] ?? 0;
      isLoading = false;
    });
  }*/

  // CHANGED: Count items from local memory for demo (no Firestore)
  Future<void> fetchData() async {
    int tops = Item.itemList.where((item) => item.category == 'Top').length;
    int bottoms = Item.itemList.where((item) => item.category == 'Bottom').length;
    int shoes = Item.itemList.where((item) => item.category == 'Shoes').length;

    // Update state using local-only counts
    setState(() {
      topCount = tops;
      bottomCount = bottoms;
      shoeCount = shoes;
      isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to adjust layout dynamically
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      // Background color for the entire screen
      backgroundColor: const Color.fromARGB(255, 239, 240, 240),

      // Custom App Bar at the top
      appBar: CustomAppBar(),

      // Main body of the screen
      body: Container(
        padding: EdgeInsets.only(top: screenHeight * 0.06),
        child: Column(
          spacing: screenHeight * 0.02, // Vertical spacing between widgets
          children: [
            // Weather information section
            Column(
              spacing: 0, // No spacing between widgets
              children: [
                // Weather condition icon
                SvgPicture.asset(
                  'lib/assets/icons/fluent_weather-hail-day-24-regular.svg',
                ),
                // Location name
                Text(
                  // TODO: Pull actual location data dynamically
                  locationName,
                  textAlign: TextAlign.center,
                  style: kBodyMedium,
                ),
                // Current temperature
                Text(
                  '54°F', // TODO: Pull actual weather data dynamically
                  style: GoogleFonts.lato(textStyle: kBodyLarge),
                ),
                // Temperature range (min/max)
                Text(
                  '37° - 64°', // TODO: Pull actual weather data dynamically
                  style: kBodyMedium,
                ),
              ],
            ),

            // Wardrobe Insights section
            Column(
              spacing: screenHeight * 0.012, // Space between widgets
              children: [
                // Section title
                Text('Insight your wardrobe',
                    textAlign: TextAlign.center, style: kH3),
                // Container to hold item count display
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  // Show CircularProgressIndicator while data is loading
                  child: isLoading
                      ? const Center(
                          child:
                              CircularProgressIndicator(), // Show loader while fetching data
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Display item count for Tops
                            BuildCountColumn('Tops', topCount, kH3),
                            // Vertical divider between items
                            BuildDivider(screenWidth, screenHeight),
                            // Display item count for Bottoms
                            BuildCountColumn('Bottoms', bottomCount, kH3),
                            // Vertical divider between items
                            BuildDivider(screenWidth, screenHeight),
                            // Display item count for Shoes
                            BuildCountColumn('Shoes', shoeCount, kH3),
                          ],
                        ),
                ),
              ],
            ),

            // Button Section - Action buttons
            Container(
              child: Column(
                spacing: screenHeight * 0.01, // Space between buttons
                children: [
                  // Button to navigate to Create Outfit screen
                  CustomButton2(
                    text: 'CREATE OUTFIT',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateOutfitScreen(),
                        ),
                      );
                    },
                  ),
                  // Button to play it safe - show favorite outfit
                  CustomButton2(
                    text: 'PLAY IT SAFE',
                    onPressed: () async {
                      // Step 1: Fetch all outfits from Firestore for the current user
                      await Outfit.fetchOutfits(kUsername);

                      // Step 2: Retrieve a random "safe" outfit from the loaded list
                      final safeOutfit = PlayItSafeService.getSafeOutfit();

                      // Step 3: Define a helper method to regenerate and replace the current screen
                      void regenerateAndReplace(BuildContext context) {
                        final newOutfit = PlayItSafeService.getSafeOutfit();

                        // If a new outfit is available, replace the current screen with the new one (no page flip animation)
                        if (newOutfit != null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      OutfitSuggestionScreen(
                                showFavorite:
                                    false, // Don't show favorite icons in play-it-safe mode
                                outfit:
                                    newOutfit, // Display the new randomly selected outfit
                                onRegenerate: () => regenerateAndReplace(
                                    context), // 👈 Call recursively
                                showDeleteIcon:
                                    false, // Hide the delete (trash) icon
                              ),
                              transitionDuration:
                                  Duration.zero, // Disable transition animation
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          // If no new outfit is available, show a snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No more outfits to show!')),
                          );
                        }
                      }

                      // Step 4: If a safe outfit exists, navigate to OutfitSuggestionScreen
                      if (safeOutfit != null) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    OutfitSuggestionScreen(
                              showFavorite: false, // Don't show favorite icons
                              outfit:
                                  safeOutfit, // Display the initial safe outfit
                              onRegenerate: () => regenerateAndReplace(
                                  context), // Setup regenerate logic
                              showDeleteIcon:
                                  false, // Hide delete icon in play-it-safe mode
                            ),
                            transitionDuration:
                                Duration.zero, // Disable page flip animation
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        // Step 5: If no saved outfits are found, show a snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('No saved outfits available!')),
                        );
                      }
                    },
                  ),

                  // Button to generate a random outfit
                  CustomButton2(
                    text: 'SURPRISE ME',
                    onPressed: () {
                      // TODO: Implement AI feature to generate random outfits
                      // Retrieve the ID's of the outfit components and pass to OutfitSuggestionScreen
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

      // Bottom Navigation Bar
      bottomNavigationBar: const CustomNavBar(),
    );
  }
}
