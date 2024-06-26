import 'package:family_tracker/pages/event_details_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:family_tracker/auth.dart';
import 'package:family_tracker/pages/reminder_page.dart';
import 'package:family_tracker/pages/login_register_page.dart';
import 'package:family_tracker/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tracker/pages/schedule_page.dart';
import 'package:family_tracker/pages/view_all_events_page.dart';
import 'package:family_tracker/pages/add_event_page.dart';
import 'package:family_tracker/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Family Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WidgetTree(),
      routes: {
        '/schedule_page': (context) => const SchedulePage(),
        '/reminder_page': (context) => const ReminderPage(),
        '/view_all_events': (context) => const ViewAllEventsPage(),
        '/add_event': (context) => AddEventPage(),
        '/home': (context) => const HomePage(),
        '/event_details': (context) => EventDetailsPage(
              eventId: '',
            ),
      },
    );
  }
}

class WidgetTree extends StatefulWidget {
  const WidgetTree({super.key});

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user == null) {
            return const LoginPage();
          } else {
            // Initialize NotificationService with Firestore and user info
            final notificationService =
                NotificationService(FirebaseFirestore.instance, user);
            notificationService.initNotification();
            return const HomePage(); // Navigate to HomePage after login
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
