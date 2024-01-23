import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as t;

class TimeZoneer {
  factory TimeZoneer() => _this ?? TimeZoneer._();

  TimeZoneer._() {
    initializeTimeZones();
  }
  static TimeZoneer? _this;

  Future<String> getTimeZoneName() async =>
      FlutterNativeTimezone.getLocalTimezone();

  Future<t.Location> getLocation([String? timeZoneName]) async {
    if (timeZoneName == null || timeZoneName.isEmpty) {
      timeZoneName = await getTimeZoneName();
    }
    return t.getLocation(timeZoneName);
  }
}
