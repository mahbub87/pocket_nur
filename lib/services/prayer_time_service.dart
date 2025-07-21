import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';

class PrayerTimeService {
  static PrayerTimes? getPrayerTimes(Position? pos, DateTime dateTime) {
    if (pos == null) return null;
    
    final coords = Coordinates(pos.latitude, pos.longitude);
    final params = CalculationMethod.muslim_world_league.getParameters()
      ..madhab = Madhab.shafi;
    final date = DateComponents.from(dateTime);
    return PrayerTimes(coords, date, params);
  }
}