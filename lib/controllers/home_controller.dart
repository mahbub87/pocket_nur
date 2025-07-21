import 'dart:async';
import 'package:flutter/material.dart';
import 'package:adhan/adhan.dart';
import '../services/hijri_service.dart';
import '../services/location_service.dart';
import '../services/prayer_time_service.dart';

class HomeController extends ChangeNotifier {
  String hijriDate = 'Loading date...';
  String location = 'Getting location...';
  PrayerTimes? prayerTimes;

  DateTime now = DateTime.now();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  Timer? _timer;

  HomeController() {
    _initializeData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      now = DateTime.now();
      notifyListeners();
    });
  }

  void disposeController() {
    _timer?.cancel();
  }

  Future<void> _initializeData() async {
    _updateHijriDate();
    await fetchLocationAndPrayerTimes();
  }

  void _updateHijriDate() {
    hijriDate = HijriService.getToday();
    notifyListeners();
  }

  Future<void> fetchLocationAndPrayerTimes() async {
    isLoading = true;
    hasError = false;
    errorMessage = '';
    notifyListeners();

    try {
      await LocationService.ensurePermissions();
      final position = await LocationService.getBestPosition();
      location = await LocationService.getReadableLocation(position);
      prayerTimes = PrayerTimeService.getPrayerTimes(position, now);

      if (prayerTimes == null) {
        throw Exception('Failed to calculate prayer times');
      }
      
    } catch (e) {
      hasError = true;
      errorMessage = _getUserFriendlyError(e);
      prayerTimes = null; // Ensure prayerTimes is null on error
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String _getUserFriendlyError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (error is TimeoutException) return 'Request took too long';
    if (msg.contains('permission')) return 'Location permission required';
    if (msg.contains('disabled')) return 'Enable location services';
    return 'Failed to load data';
  }
}
