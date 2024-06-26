import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore firestore;
  final User? user;

  NotificationService(this.firestore, this.user) {
    _configureLocalTimeZone();
  }

  Future<void> initNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('family_restroom');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true);

    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) async {
        if (notificationResponse.payload != null) {
          final int id = int.parse(notificationResponse.payload!);
          await _deleteReminderById(id);
        }
      },
    );
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future<void> showNotification(
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(id, title, body, notificationDetails(),
        payload: payLoad);
  }

  Future<void> scheduleNotification(DateTime scheduledDate,
      {int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: id.toString(),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void _configureLocalTimeZone() {
    tz.initializeTimeZones();
    tz.setLocalLocation(
        tz.getLocation('America/Detroit')); // Set your local timezone
  }

  Future<void> _deleteReminderById(int id) async {
    final snapshot = await firestore
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid)
        .where('id', isEqualTo: id)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      await snapshot.docs.first.reference.delete();
    }

    // Notify the UI to update the reminder list
    _onReminderDeleted?.call(id);
  }

  // A callback to notify UI about reminder deletion
  static Function(int)? _onReminderDeleted;

  static void setOnReminderDeleted(Function(int) callback) {
    _onReminderDeleted = callback;
  }
}
