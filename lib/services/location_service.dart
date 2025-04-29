import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:geolocator_apple/geolocator_apple.dart';

///Determines the users position by checking there location service and permissions
///Then, it returns the correct coordinates of the user
Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  //checks if the location services are working or not
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    //the location services are not working and are disabled
    return Future.error('Location services are disabled.');
  }

  //checks if the permissions are working 
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    //permission here are denied, which means you have to request again for it
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  //permissions are denied here forever
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  //gives access to location of the device
  return await Geolocator.getCurrentPosition(locationSettings: getLocationSettings());
}

///Returns the location settings of a device based on current platform it's on: Andriod, Apple, or Web.
LocationSettings getLocationSettings() {
  if (defaultTargetPlatform == TargetPlatform.android) {
    //returns the location settings for android devices
    return AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      forceLocationManager: true,
      intervalDuration: const Duration(seconds: 10),
      //(Optional) Set foreground notification config to keep the app alive 
      //when going to the background
      foregroundNotificationConfig: const ForegroundNotificationConfig(
        notificationText: "Location access",
        notificationTitle: "Dressify is accessing your location",
        enableWakeLock: true,
      )
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
    //returns the location settings for apple devices
    return AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.fitness,
      distanceFilter: 100,
      pauseLocationUpdatesAutomatically: true,
      showBackgroundLocationIndicator: false,
    );
  } else if (kIsWeb) {
    //returns the location settings for web platforms
    return WebSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
      maximumAge: Duration(minutes: 5),
    );
  } else {
    return LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
  }
}