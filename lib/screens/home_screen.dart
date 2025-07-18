import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:adhan/adhan.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String hijriDate = 'Loading date...';
  String location = 'Getting location...';
  String cityName = '';
  PrayerTimes? prayerTimes;

  DateTime now = DateTime.now();
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeData();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _updateHijriDate();
    await _fetchLocationAndPrayerTimes();
  }

  void _updateHijriDate() {
    final hijri = HijriCalendar.now();
    setState(() {
      hijriDate = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
    });
  }

  Future<void> _fetchLocationAndPrayerTimes() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = '';
    });

    try {
      await _handleLocationPermissions();
      final position = await _getCurrentPosition();
      await _updateLocationName(position);
      await _calculatePrayerTimes(position);
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = _getUserFriendlyError(e);
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLocationPermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled');

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        throw Exception('Location permissions denied');
      }
    }
  }

  Future<Position> _getCurrentPosition() {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
        .timeout(const Duration(seconds: 15), onTimeout: () {
      throw TimeoutException('Location request timed out');
    });
  }

  Future<void> _updateLocationName(Position position) async {
    try {
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude)
          .timeout(const Duration(seconds: 5));

      cityName = placemarks.first.locality ??
          placemarks.first.subAdministrativeArea ??
          placemarks.first.administrativeArea ??
          '';

      setState(() {
        location = cityName.isNotEmpty
            ? '$cityName'
            : '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    } catch (_) {
      setState(() {
        location = '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    }
  }

  Future<void> _calculatePrayerTimes(Position position) async {
    final params = CalculationMethod.muslim_world_league.getParameters()..madhab = Madhab.shafi;
    final coordinates = Coordinates(position.latitude, position.longitude);
    final date = DateComponents.from(now);

    setState(() {
      prayerTimes = PrayerTimes(coordinates, date, params);
    });
  }

  String _getUserFriendlyError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (error is TimeoutException) return 'Request took too long';
    if (msg.contains('permission')) return 'Location permission required';
    if (msg.contains('disabled')) return 'Enable location services';
    return 'Failed to load data';
  }

  String getCurrentPrayer(PrayerTimes pt) {
  if (now.isBefore(pt.fajr)) return 'Isha';
  if (now.isBefore(pt.dhuhr)) return 'Fajr';
  if (now.isBefore(pt.asr)) return 'Dhuhr';
  if (now.isBefore(pt.maghrib)) return 'Asr';
  if (now.isBefore(pt.isha)) return 'Maghrib';
  return 'Isha';
}


  String getNextPrayer(PrayerTimes pt) {
  if (now.isBefore(pt.fajr)) return 'Fajr';
  if (now.isBefore(pt.dhuhr)) return 'Dhuhr';
  if (now.isBefore(pt.asr)) return 'Asr';
  if (now.isBefore(pt.maghrib)) return 'Maghrib';
  if (now.isBefore(pt.isha)) return 'Isha';
  return 'Fajr'; // Next day's fajr
}

  double sliderValue(PrayerTimes pt) {
  final currentPrayer = getCurrentPrayer(pt);
  final nextPrayer = getNextPrayer(pt);

  final start = _getPrayerTime(currentPrayer)!;
  final end = _getPrayerTime(nextPrayer)!;

  final total = end.difference(start).inSeconds;
  final elapsed = now.difference(start).inSeconds;

  return total == 0 ? 0 : (elapsed / total).clamp(0, 1);
}

  String remainingTime(PrayerTimes pt) {
    final next = _getPrayerTime(getNextPrayer(pt));
    if (next == null || now.isAfter(next)) return '0 mins';

    final diff = next.difference(now);
    return diff.inHours > 0
        ? '${diff.inHours}h ${diff.inMinutes.remainder(60)}m'
        : '${diff.inMinutes} mins left';
  }

  DateTime? _getPrayerTime(String prayer) {
    return switch (prayer) {
      'Fajr' => prayerTimes?.fajr,
      'Sunrise' => prayerTimes?.sunrise,
      'Dhuhr' => prayerTimes?.dhuhr,
      'Asr' => prayerTimes?.asr,
      'Maghrib' => prayerTimes?.maghrib,
      'Isha' => prayerTimes?.isha,
      _ => null,
    };
  }

  String formatTime(DateTime? time) {
    if (time == null) return '--:--';
    try {
      return TimeOfDay.fromDateTime(time).format(context);
    } catch (_) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               _buildTopRow(),
              const SizedBox(height: 16),
              _buildPrayerCard(),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildFeatureGrid(),
              const SizedBox(height: 16),
              _buildMoodSelector(),
            ],
          ),
        ),
      ),
        bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          hijriDate,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          location,
          style: TextStyle(fontWeight: FontWeight.w500, color: hasError ? Colors.red : null),
        ),
      ],
    );
  }

  Widget _buildPrayerCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF8F5F2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? Column(
                    children: [
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchLocationAndPrayerTimes,
                        child: const Text('Try Again'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrayerHeader(),
                      const SizedBox(height: 16),
                      _buildPrayerSlider(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildPrayerHeader() {
    final prayer = getCurrentPrayer(prayerTimes!);
    final startTime = formatTime(_getPrayerTime(prayer));
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(prayer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('$startTime (Start time)', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.wb_twilight, size: 32), // Placeholder icon
        ),
      ],
    );
  }

  Widget _buildPrayerSlider() {
  final currentPrayer = getCurrentPrayer(prayerTimes!);
  final nextPrayer = getNextPrayer(prayerTimes!);

  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDotLabel(currentPrayer),
          Text(
            remainingTime(prayerTimes!),
            style: const TextStyle(fontSize: 12),
          ),
          _buildDotLabel(nextPrayer),
        ],
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: sliderValue(prayerTimes!),
        minHeight: 4,
        backgroundColor: Colors.grey[300],
        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
      ),
    ],
  );
}

  
  Widget _buildDotLabel(String label) {
    return Row(
      children: [
        const Icon(Icons.circle, size: 10, color: Colors.teal),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
  Widget _buildFeatureGrid() {
    final features = [
      ('Quran', Icons.menu_book),
      ('Hadith', Icons.book),
      ('5 Pillars', Icons.view_in_ar),
      ('Dua', Icons.pan_tool_alt),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      children: features
          .map((f) => buildFeatureButton(f.$1, f.$2, context))
          .toList(),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.mood),
        title: const Text('Mood Selector'),
        onTap: () {},
      ),
    );
  }

  Widget _buildBottomNavBar() {
    const items = [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.book), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.self_improvement), label: ''),
      BottomNavigationBarItem(icon: Icon(Icons.settings), label: ''),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 0,
      onTap: (index) {},
      items: items,
    );
  }

  Widget buildFeatureButton(String label, IconData icon, BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

// Extra screen component
class PrayerScreen extends StatelessWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prayer Times')),
      body: const Center(child: Text('Prayer details here')),
    );
  }
}
