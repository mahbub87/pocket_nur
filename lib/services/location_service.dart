import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationService {
  static const _locationCacheKey = 'cached_readable_location';

  static Future<void> ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw Exception('Location permission denied');
      }
    }
  }

  static Future<Position> getBestPosition() async {
    Position? position = await Geolocator.getLastKnownPosition();
    if (position != null) return position;

    return Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    ).timeout(const Duration(seconds: 10));
  }

  static Future<String> getReadableLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_locationCacheKey);

    if (cached != null) {
      return cached;
    }

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${position.latitude}&lon=${position.longitude}&zoom=10&addressdetails=1');

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'FlutterApp (you@example.com)'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'];

        final city = address['city'] ??
            address['town'] ??
            address['village'] ??
            address['county'];
        final state = address['state'] ?? '';

        final parts = [
          if (city != null && city.isNotEmpty) city,
          if (state.isNotEmpty) state,
        ];

        final location = parts.join(', ');
        if (location.isNotEmpty) {
          await prefs.setString(_locationCacheKey, location);
          return location;
        }
      }
    } catch (e) {
      print('Nominatim error: $e');
    }

    return 'Unknown location (${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)})';
  }
}