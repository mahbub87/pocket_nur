import 'package:hijri/hijri_calendar.dart';

class HijriService {
  static String getToday() {
    final hijri = HijriCalendar.now();
    return '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear}';
  }
}
