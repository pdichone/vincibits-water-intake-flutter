import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone_updated_gradle/flutter_native_timezone.dart';
import 'package:timezone/src/date_time.dart';

import 'dart:typed_data';

// import 'package:timezone/timezone.dart' as tz;
// import 'package:water_intake/utils/timezone.dart' as tz;
import 'package:water_intake/utils/timezone.dart';

NotificationDetails getNotificationDetails() {
  AndroidNotificationDetails android = AndroidNotificationDetails(
    'channel_id',
    'channel_name',
    visibility: NotificationVisibility.public,
    priority: Priority.max,
    importance: Importance.max,
    ledColor: const Color.fromARGB(255, 0, 200, 255),
    ledOffMs: 500,
    ledOnMs: 300,
    enableLights: true,
    color: Colors.blue,
    additionalFlags: Int32List.fromList([8]),
    category: AndroidNotificationCategory.reminder,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    enableVibration: true,
    vibrationPattern: Int64List.fromList([0, 1000, 1000, 1000]),
  );

  DarwinNotificationDetails ios = DarwinNotificationDetails();
  NotificationDetails details = NotificationDetails(android: android, iOS: ios);
  return details;
}

Future<void> setDailyStartNotification(TimeOfDay time, String user) async {
  try {
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    NotificationDetails notificationDetails = getNotificationDetails();
    await plugin.cancel(0);
    await plugin.periodicallyShow(
        0,
        "Good morning, $user",
        "Don't forget to dring enough water today",
        RepeatInterval.values[time.hour],
        // Time(time.hour, time.minute),
        notificationDetails);
  } catch (e) {
    print(e);
  }
}

Future<void> waterNotification(double left) async {
  try {
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    NotificationDetails notificationDetails = getNotificationDetails();

    final timeZone = TimeZoneer();

    // The device's timezone.
    String timeZoneName = await timeZone.getTimeZoneName();

    // Find the 'current location'
    final location = await timeZone.getLocation(timeZoneName);

    // final scheduledDate =
    //     tz.TZDateTime.from(tz.TZDateTime.local(DateTime.now().year), location);

    final scheduledDate = await FlutterNativeTimezone.getLocalTimezone();

    await plugin.cancel(1);
    await plugin.zonedSchedule(
        1,
        "Hey, it's time to drink water",
        "$left mL water left to drink today",
        scheduledDate as TZDateTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
    // await plugin.zonedSchedule(
    //     1,
    //     "Hey, it's time to drink water",
    //     "$left mL water left to drink today",
    //      DateTime.now().add(Duration(hours: 1, minutes: 30)),
    //     notificationDetails);
  } catch (e) {
    print(e);
  }
}

Future<void> cancelAllNotifications() async {
  try {
    FlutterLocalNotificationsPlugin plugin = FlutterLocalNotificationsPlugin();
    await plugin.cancelAll();
  } catch (e) {
    print(e);
  }
}
