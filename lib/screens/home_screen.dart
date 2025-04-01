import 'package:dressify_app/constants.dart';
import 'package:dressify_app/screens/create_outfit_screen.dart';
import 'package:dressify_app/screens/display_outfit_screen.dart';
import 'package:dressify_app/services/item_service.dart';
import 'package:dressify_app/services/weather_service.dart';
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
import 'package:weather/weather.dart';



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


  @override
  void initState() {
    super.initState();
    // Fetch item data and count when the screen initializes
    fetchData();
    //gets the users current location on the screen
    getUserLocation();

    getUserWeather();
  }

  Future<void> getUserWeather() async {
    try {
      WeatherService weatherService = WeatherService();
      Weather weather = await weatherService.getTheWeather();

      double? temp = weather.temperature?.fahrenheit;
      double? tempMin = weather.tempMin?.fahrenheit;
      double? tempMax = weather.tempMax?.fahrenheit;

      setState(() {
        if (temp != null) {
          currentTemp = '${temp.toStringAsFixed(0)}°F';
        } else {
          currentTemp = 'Unavailable';
        }

        if (tempMin != null && tempMax != null) {
          tempRange = '${tempMin.toStringAsFixed(0)}° - ${tempMax.toStringAsFixed(0)}°';
        } else {
          tempRange = 'Unavailable';
        }

      });
      print('Current Temp: $currentTemp');
      print('Temp Range: $tempRange');
    } catch (e) {
      setState(() {
        currentTemp = 'Unavailable';
        tempRange = 'Unavailable';
      });
    }
  }


  ///Gets the users location and updates location based on: coordinates and reverse geo-encoding
  Future<void> getUserLocation() async {
    try {
      //finds the positions coordinates of the user
      Position position = await determinePosition();

      //converts the coordinates correctly
      List<Placemark> cordinate = await placemarkFromCoordinates(position.latitude,position.longitude,);

      //checks if the coordinate data is there
      if (cordinate.isNotEmpty) {
        Placemark address =  cordinate[0];

        //checks if the address from the coordinates contains a locailty AKA city name
        if (address.locality != null) {
          //the location name gets updated with the city name
          setState(() {
            locationName =  address.locality!;
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
  Future<void> fetchData() async {
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
                    onPressed: () {
                      // TODO: Select an outfit from favorites and pass item IDs to OutfitSuggestionScreen
                      // OutfitSuggestionScreen will need to take 3 parameters: topId, bottomId, and shoeId

                      // TODO: Modify DisplayOutfitScreen to take a boolean parameter that determines
                      // whether the favorite button is displayed or not (since this is a favorite outfit)
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
