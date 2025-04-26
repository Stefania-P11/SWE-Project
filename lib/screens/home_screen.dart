import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dressify_app/constants.dart';
import 'package:dressify_app/models/outfit.dart';
import 'package:dressify_app/screens/create_outfit_screen.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/services/item_service.dart';
import 'package:dressify_app/services/play_it_safe.dart';
import 'package:dressify_app/services/weather_service.dart';
import 'package:dressify_app/widgets/custom_app_bar.dart';
import 'package:dressify_app/widgets/custom_bottom_navbar.dart';
import 'package:dressify_app/widgets/custom_button_2.dart';
import 'package:dressify_app/widgets/item_count_display_column.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dressify_app/widgets/vertical_divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dressify_app/services/location_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dressify_app/models/item.dart'; // Needed to use Item.itemList
import 'package:weather/weather.dart';
import 'package:dressify_app/services/surprise_me_service.dart';

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

  String currentTemp = '';
  String tempRange = '';

  Set<int> usedBottomIds = {}; // track used bottoms

  bool _weatherLoaded = false;//ensure weather is fetched only once per app run, even if the screen is reloaded

  @override
  void initState() {
    super.initState();
    // Fetch item data and count when the screen initializes
    fetchData();

    // Fetch weather and location data when the screen initializes
    getUserWeatherAndLocation();
  }

  
/// Fetches items and outfits from Firestore and updates local counters.
Future<void> fetchData() async {

  if (kUsername.isEmpty) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final snapshot = await FirebaseFirestore.instance
        .collection('usernames')
        .where('uid', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      kUsername = snapshot.docs.first.id;
      print("kUsername loaded in HomeScreen: $kUsername");
    } else {
      print("Could not load username in HomeScreen");
    }
  }
}

  // Load items from Firestore if they haven't been loaded yet
  if (!Item.isLoaded) {
    await Item.fetchItems(kUsername);
    Item.isLoaded = true;
  }

  // Load outfits from Firestore if the list is currently empty
  if (Outfit.outfitList.isEmpty) {
    await Outfit.fetchOutfits(kUsername);
  }

  // Initialize counters for each category
  Map<String, int> itemCounts = {
    'topCount': 0,
    'bottomCount': 0,
    'shoeCount': 0,
  };

  // Tally items by category
  for (final item in Item.itemList) {
    if (item.category == 'Top') {
      itemCounts['topCount'] = itemCounts['topCount']! + 1;
    }
    if (item.category == 'Bottom') {
      itemCounts['bottomCount'] = itemCounts['bottomCount']! + 1;
    }
    if (item.category == 'Shoes') {
      itemCounts['shoeCount'] = itemCounts['shoeCount']! + 1;
    }
  }

  // Update the UI with the latest counts
  setState(() {
    topCount = itemCounts['topCount']!;
    bottomCount = itemCounts['bottomCount']!;
    shoeCount = itemCounts['shoeCount']!;
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
                  //'54°F', // TODO: Pull actual weather data dynamically
                  currentTemp,
                  style: GoogleFonts.lato(textStyle: kBodyLarge),
                ),
                // Temperature range (min/max)
                Text(
                  //'37° - 64°', // TODO: Pull actual weather data dynamically
                  tempRange,
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
                      // ✅ Don't re-fetch from Firestore; use the local outfitList
                      final safeOutfit = await PlayItSafeService.getSafeOutfit();

                      void regenerateAndReplace(BuildContext context) async {
                        final newOutfit = await PlayItSafeService.getSafeOutfit();
                        if (newOutfit != null) {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, _, __) =>
                                  OutfitSuggestionScreen(
                                showFavorite: false,
                                outfit: newOutfit,
                                onRegenerate: () =>
                                    regenerateAndReplace(context),
                                showDeleteIcon: false,
                              ),
                              transitionDuration: Duration.zero,
                              reverseTransitionDuration: Duration.zero,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('No more outfits to show!')),
                          );
                        }
                      }

                      if (safeOutfit != null) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, _, __) =>
                                OutfitSuggestionScreen(
                              showFavorite: false,
                              outfit: safeOutfit,
                              onRegenerate: () => regenerateAndReplace(context),
                              showDeleteIcon: false,
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
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
                    onPressed: () async {
                      setState(() => isLoading = true);

                      //ensure the items are loaded before generated outfit
                      if (!Item.isLoaded) {
                        await Item.fetchItems(kUsername);
                        Item.isLoaded = true;
                      }

                      final firstOutfit = await surpriseMe(Item.itemList);
                      setState(() => isLoading = false);

                      if (firstOutfit != null) {
                        usedBottomIds = {firstOutfit.bottomItem.id};
                        //generated logic with no animation
                        void handleRegenerate(BuildContext context) async {
                          // Ensure items are still loaded
                          if (!Item.isLoaded) {
                            await Item.fetchItems(kUsername);
                            Item.isLoaded = true;
                          }
                          
                          final newOutfit = await surpriseMe(
                            Item.itemList,
                            excludeBottomIds: usedBottomIds,
                          );

                          if (newOutfit != null) {
                            usedBottomIds.add(newOutfit.bottomItem.id);
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context,animation, secondaryAnimation) => OutfitSuggestionScreen(
                                  outfit: newOutfit,
                                  showFavorite: true,
                                  showDeleteIcon: false,
                                  onRegenerate: () => handleRegenerate(context),
                                ),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          } else {
                            usedBottomIds.clear();
                            final restartOutfit = await surpriseMe(Item.itemList);
                            if (restartOutfit != null) {
                              usedBottomIds = {restartOutfit.bottomItem.id};
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context,animation, secondaryAnimation) => OutfitSuggestionScreen(
                                    outfit: restartOutfit,
                                    showFavorite: true,
                                    showDeleteIcon: false,
                                    onRegenerate: () => handleRegenerate(context),
                                  ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No outfits available!!')),
                              );
                            }
                          }
                        }
                        //show first generated outfit
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context,animation, secondaryAnimation) => OutfitSuggestionScreen(
                              outfit: firstOutfit,
                              showFavorite: true,
                              showDeleteIcon: false,
                              onRegenerate: () => handleRegenerate(context),
                            ),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Could not generate an outfit.')),
                        );
                      }
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

  ///
  Future<void> getUserWeatherAndLocation() async {
    //check if the weather is loaded
    if (_weatherLoaded) {
      print('[HomeScreen] Weather already loaded, skipping fetch');
      return;
    }
    //
    try {
      Position position = await determinePosition();

      // Get weather
      //WeatherService weatherService = WeatherService();
      Weather weather = await WeatherService().getTheWeather();

      // Extract weather values
      double? temp = weather.temperature?.fahrenheit;
      double? tempMin = weather.tempMin?.fahrenheit;
      double? tempMax = weather.tempMax?.fahrenheit;

      // Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      String location =
          placemarks.isNotEmpty && placemarks.first.locality != null
              ? placemarks.first.locality!
              : 'Location unknown';

      // Update UI all at once
      setState(() {
        locationName = location;
        currentTemp =
            temp != null ? '${temp.toStringAsFixed(0)}°F' : 'Unavailable';
        tempRange = (tempMin != null && tempMax != null)
            ? '${tempMin.toStringAsFixed(0)}° - ${tempMax.toStringAsFixed(0)}°'
            : 'Unavailable';
        _weatherLoaded = true; // Mark as loaded
      });

      print('Location: $locationName');
      print('Current Temp: $currentTemp');
      print('Temp Range: $tempRange');

    print('[HomeScreen] Weather successfully updated');
    } catch (e) {
      setState(() {
        locationName = 'Location is not available';
        currentTemp = 'Unavailable';
        tempRange = 'Unavailable';
      });
      print('[HomeScreen] Failed to fetch weather or location: $e');
    }
  }
  //Ensure having a valid OutfitItem() --> this should return a proper image + label
  Widget outfitItem(String label, double width, {required String? imageUrl}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              width: width * 0.35,
              height: width * 0.35,
              fit: BoxFit.cover,
            )
          : Container(
              width: width * 0.35,
              height: width * 0.35,
              color: Colors.grey[300],
              child: const Center(child: Text('No Image')),
            ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
}
