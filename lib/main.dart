import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mood_tracker/app/app.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'database/database.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  setup();
  showNotificationDaily();
  runApp(const MoodTrackerApp());
}

void showNotificationDaily() async {
  tz.initializeTimeZones();

  Future<PermissionStatus> permissionStatus =
      NotificationPermissions.requestNotificationPermissions(
          iosSettings: const NotificationSettingsIos(
              sound: true, badge: true, alert: true),
          openSettings: true);

  var androidChannel = const AndroidNotificationDetails(
      'channelID', 'channelName',
      channelDescription: 'channelDescription',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      playSound: true);

  var iosChannel = const IOSNotificationDetails(
    presentBadge: true,
    presentSound: true,
  );

  tz.setLocalLocation(tz.getLocation('Europe/Rome'));

  await flutterLocalNotificationsPlugin.periodicallyShow(
      0,
      'How are you feeling?',
      'Track your mood for today!',
      RepeatInterval.daily,
      NotificationDetails(
        android: androidChannel,
        iOS: iosChannel,
      ));
}
