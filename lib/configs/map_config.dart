import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapConfig {
  // Vị trí mặc định (Paris)
  static const LatLng defaultPosition = LatLng(48.8566, 2.3522);
  
  // Zoom levels
  static const double defaultZoom = 15.0;
  static const double navigationZoom = 18.0;
  static const double minZoom = 2.0;
  static const double maxZoom = 20.0;
  
  // Camera settings
  static const double navigationTilt = 45.0;
  static const double normalTilt = 0.0;
  static const double navigationBearing = 0.0;
  
  // Navigation settings
  static const double distanceFilter = 5.0; // meters
  static const double stepCompletionDistance = 20.0; // meters
  static const double boundsPadding = 100.0;
  
  // Map types
  static const MapType defaultMapType = MapType.normal;
  
  // UI settings
  static const bool showMyLocationButton = false;
  static const bool showZoomControls = false;
  static const bool showCompass = true;
  static const bool showMapToolbar = false;
  
  // Animation duration
  static const Duration cameraAnimationDuration = Duration(milliseconds: 500);
  static const Duration snackBarDuration = Duration(seconds: 2);
  static const Duration navigationSnackBarDuration = Duration(seconds: 3);
}