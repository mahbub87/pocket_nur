import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../controllers/home_controller.dart';

class PrayerCard extends StatelessWidget {
  const PrayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<HomeController>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: const Color(0xFFF8F5F2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : controller.hasError
            ? Column(
                children: [
                  Text(
                    controller.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => controller.fetchLocationAndPrayerTimes(),
                    child: const Text('Try Again'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrayerHeader(context, controller),
                  const SizedBox(height: 16),
                  if (controller.prayerTimes != null)
                    _buildPrayerSlider(controller),
                ],
              ),
      ),
    );
  }

  Widget _buildPrayerHeader(BuildContext context, HomeController controller) {
    final prayer = _getCurrentPrayer(controller);
    final startTime = _formatTime(context, _getPrayerTime(controller, prayer));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prayer,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '$startTime (Start time)',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.deepPurple),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: const Icon(Icons.wb_twilight, size: 32),
        ),
      ],
    );
  }

  Widget _buildPrayerSlider(HomeController controller) {
    final currentPrayer = _getCurrentPrayer(controller);
    final nextPrayer = _getNextPrayer(controller);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildDotLabel(currentPrayer),
            Text(
              _remainingTime(controller),
              style: const TextStyle(fontSize: 12),
            ),
            _buildDotLabel(nextPrayer),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _sliderValue(controller),
          minHeight: 4,
          backgroundColor: Colors.grey[300],
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
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

  // Helper methods moved from original code
  String _getCurrentPrayer(HomeController controller) {
    final pt = controller.prayerTimes!;
    final now = controller.now;
    if (now.isBefore(pt.fajr)) return 'Isha';
    if (now.isBefore(pt.dhuhr)) return 'Fajr';
    if (now.isBefore(pt.asr)) return 'Dhuhr';
    if (now.isBefore(pt.maghrib)) return 'Asr';
    if (now.isBefore(pt.isha)) return 'Maghrib';
    return 'Isha';
  }

  String _getNextPrayer(HomeController controller) {
    final pt = controller.prayerTimes!;
    final now = controller.now;
    if (now.isBefore(pt.fajr)) return 'Fajr';
    if (now.isBefore(pt.dhuhr)) return 'Dhuhr';
    if (now.isBefore(pt.asr)) return 'Asr';
    if (now.isBefore(pt.maghrib)) return 'Maghrib';
    if (now.isBefore(pt.isha)) return 'Isha';
    return 'Fajr';
  }

  double _sliderValue(HomeController controller) {
    final now = controller.now;
    final currentPrayer = _getCurrentPrayer(controller);
    final nextPrayer = _getNextPrayer(controller);

    final start = _getPrayerTime(controller, currentPrayer);
    final endRaw = _getPrayerTime(controller, nextPrayer);

    if (start == null || endRaw == null) return 0.0;

    var startTime = start;
    var endTime = endRaw;

    // Adjust for cross-midnight
    if (endTime.isBefore(startTime)) {
      endTime = endTime.add(const Duration(days: 1));
    }
    if (startTime.isAfter(now)) {
      startTime = startTime.subtract(const Duration(days: 1));
      endTime = endTime.subtract(const Duration(days: 1));
      // re-check endTime in case subtracting puts it before start
      if (endTime.isBefore(startTime)) {
        endTime = endTime.add(const Duration(days: 1));
      }
    }

    final total = endTime.difference(startTime).inSeconds;
    final elapsed = now.difference(startTime).inSeconds;

    if (total <= 0) return 0.0;

    final progress = elapsed / total;
    
    // Clamp result between 0.01 and 0.99 for UI smoothness
    return progress.clamp(0.01, 0.99);
  }

  String _remainingTime(HomeController controller) {
    final now = controller.now;
    var next = _getPrayerTime(controller, _getNextPrayer(controller));

    if (next == null) return '0 mins';

    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }

    final diff = next.difference(now);
    return diff.inHours > 0
        ? '${diff.inHours}h ${diff.inMinutes.remainder(60)}m'
        : '${diff.inMinutes} mins left';
  }

  DateTime? _getPrayerTime(HomeController controller, String prayer) {
    final pt = controller.prayerTimes;
    return switch (prayer) {
      'Fajr' => pt?.fajr,
      'Sunrise' => pt?.sunrise,
      'Dhuhr' => pt?.dhuhr,
      'Asr' => pt?.asr,
      'Maghrib' => pt?.maghrib,
      'Isha' => pt?.isha,
      _ => null,
    };
  }

  String _formatTime(BuildContext context, DateTime? time) {
    if (time == null) return '--:--';
    try {
      return TimeOfDay.fromDateTime(time).format(context);
    } catch (_) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }
}
