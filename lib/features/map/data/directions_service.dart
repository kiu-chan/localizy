import 'dart:convert';
import 'package:flutter/material.dart';
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
    String language = 'vi', // Thêm tham số language
  }) async {
    try {
      if (_apiKey.isEmpty) {
        debugPrint('[Directions] GOOGLE_MAPS_API_KEY is empty — check .env');
        return null;
      }

      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/directions/json',
        {
          'origin': '${origin.latitude},${origin.longitude}',
          'destination': '${destination.latitude},${destination.longitude}',
          'mode': _getTravelModeString(mode),
          'key': _apiKey,
          'language': language,
          'alternatives': 'false',
          'units': 'metric',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final status = data['status'];

        if (status == 'OK' && data['routes'].isNotEmpty) {
          return DirectionsResult.fromJson(data);
        }
        debugPrint(
            '[Directions] $status: ${data['error_message'] ?? 'no route'}');
      } else {
        debugPrint('[Directions] HTTP error: ${response.statusCode}');
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('[Directions] Exception in getDirections: $e');
      debugPrint('Stack trace:  $stackTrace');
      return null;
    }
  }

  /// Chuyển đổi TravelMode thành string cho API
  static String _getTravelModeString(TravelMode mode) {
    switch (mode) {
      case TravelMode. driving:
        return 'driving';
      case TravelMode. walking:
        return 'walking';
      case TravelMode. bicycling:
        return 'bicycling';
      case TravelMode.transit:
        return 'transit';
    }
  }

  /// Giải mã polyline từ Google Maps API
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
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
    
    // CÁCH 1: Sử dụng polyline chi tiết từ từng step (CHÍNH XÁC NHẤT)
    List<LatLng> allPoints = [];
    
    for (var step in leg['steps']) {
      if (step['polyline'] != null && step['polyline']['points'] != null) {
        final stepPoints = DirectionsService.decodePolyline(
          step['polyline']['points'],
        );
        allPoints.addAll(stepPoints);
      }
    }
    
    // CÁCH 2: Fallback về overview_polyline nếu không có step polyline
    if (allPoints.isEmpty) {
      allPoints = DirectionsService.decodePolyline(
        route['overview_polyline']['points'],
      );
    }

    // Lấy các bước chỉ đường
    final List<DirectionStep> steps = (leg['steps'] as List)
        .map((step) => DirectionStep.fromJson(step))
        .toList();

    return DirectionsResult(
      polylinePoints: allPoints,
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
  final List<LatLng> polylinePoints; // Thêm polyline cho từng step

  DirectionStep({
    required this.instructions,
    required this.distance,
    required this.duration,
    required this. startLocation,
    required this. endLocation,
    required this. polylinePoints,
  });

  factory DirectionStep.fromJson(Map<String, dynamic> json) {
    // Giải mã polyline cho step này
    List<LatLng> stepPoints = [];
    if (json['polyline'] != null && json['polyline']['points'] != null) {
      stepPoints = DirectionsService.decodePolyline(
        json['polyline']['points'],
      );
    }

    return DirectionStep(
      instructions:  json['html_instructions']
          . toString()
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
      polylinePoints: stepPoints,
    );
  }
}