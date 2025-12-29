import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DirectionsService {
  static final String _apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Lấy tuyến đường từ điểm xuất phát đến điểm đến
  static Future<DirectionsResult?> getDirections({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    try {
      // Kiểm tra API Key
      if (_apiKey.isEmpty) {
        print('❌ ERROR:  GOOGLE_MAPS_API_KEY is empty! ');
        print('Please check your .env file');
        return null;
      }

      print('🔑 Using API Key: ${_apiKey. substring(0, 10)}...');
      print('📍 Origin: ${origin.latitude}, ${origin.longitude}');
      print('📍 Destination: ${destination.latitude}, ${destination.longitude}');
      print('🚗 Travel Mode: ${_getTravelModeString(mode)}');

      // FIX: Sử dụng Uri.https và queryParameters thay vì parse string
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': _getTravelModeString(mode),
          'key': _apiKey,
          'language': 'vi',
        },
      );

      print('🌐 Request URL: $uri');

      final response = await http.get(uri);

      print('📡 Response Status Code: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      if (response. statusCode == 200) {
        final data = json.decode(response.body);
        
        print('✅ Status: ${data['status']}');
        
        // Kiểm tra các trạng thái lỗi từ API
        if (data['status'] == 'REQUEST_DENIED') {
          print('❌ REQUEST_DENIED: ${data['error_message']}');
          print('Possible reasons: ');
          print('1. API Key is invalid');
          print('2. Directions API is not enabled');
          print('3. Billing is not enabled');
          return null;
        }
        
        if (data['status'] == 'ZERO_RESULTS') {
          print('❌ ZERO_RESULTS: No route found between these points');
          return null;
        }
        
        if (data['status'] == 'OVER_QUERY_LIMIT') {
          print('❌ OVER_QUERY_LIMIT: You have exceeded your quota');
          return null;
        }
        
        if (data['status'] == 'INVALID_REQUEST') {
          print('❌ INVALID_REQUEST:  The request is invalid');
          print('Error message: ${data['error_message']}');
          return null;
        }
        
        if (data['status'] == 'UNKNOWN_ERROR') {
          print('❌ UNKNOWN_ERROR:  Server error, try again');
          return null;
        }
        
        if (data['status'] == 'OK' && data['routes']. isNotEmpty) {
          print('✅ Route found successfully! ');
          print('📊 Number of routes: ${data['routes'].length}');
          return DirectionsResult.fromJson(data);
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        print('Response: ${response.body}');
      }
      
      return null;
    } catch (e, stackTrace) {
      print('❌ Exception in getDirections: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Chuyển đổi TravelMode thành string cho API
  static String _getTravelModeString(TravelMode mode) {
    switch (mode) {
      case TravelMode.driving:
        return 'driving';
      case TravelMode.walking:
        return 'walking';
      case TravelMode.bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
    }
  }

  /// Giải mã polyline từ Google Maps API
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded. length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }
}

/// Enum cho các loại phương tiện di chuyển
enum TravelMode {
  driving,
  walking,
  bicycling,
  transit,
}

/// Class chứa kết quả chỉ đường
class DirectionsResult {
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;
  final String startAddress;
  final String endAddress;
  final List<DirectionStep> steps;

  DirectionsResult({
    required this.polylinePoints,
    required this. distance,
    required this.duration,
    required this.startAddress,
    required this.endAddress,
    required this.steps,
  });

  factory DirectionsResult.fromJson(Map<String, dynamic> json) {
    final route = json['routes'][0];
    final leg = route['legs'][0];
    
    // Giải mã polyline
    final points = DirectionsService.decodePolyline(
      route['overview_polyline']['points'],
    );

    // Lấy các bước chỉ đường
    final List<DirectionStep> steps = (leg['steps'] as List)
        .map((step) => DirectionStep.fromJson(step))
        .toList();

    return DirectionsResult(
      polylinePoints: points,
      distance: leg['distance']['text'],
      duration: leg['duration']['text'],
      startAddress: leg['start_address'],
      endAddress: leg['end_address'],
      steps: steps,
    );
  }
}

/// Class chứa thông tin từng bước chỉ đường
class DirectionStep {
  final String instructions;
  final String distance;
  final String duration;
  final LatLng startLocation;
  final LatLng endLocation;

  DirectionStep({
    required this.instructions,
    required this.distance,
    required this.duration,
    required this.startLocation,
    required this.endLocation,
  });

  factory DirectionStep. fromJson(Map<String, dynamic> json) {
    return DirectionStep(
      instructions: json['html_instructions']
          .toString()
          .replaceAll(RegExp(r'<[^>]*>'), ''), // Loại bỏ HTML tags
      distance: json['distance']['text'],
      duration: json['duration']['text'],
      startLocation: LatLng(
        json['start_location']['lat'],
        json['start_location']['lng'],
      ),
      endLocation: LatLng(
        json['end_location']['lat'],
        json['end_location']['lng'],
      ),
    );
  }
}