// Nora Alissa binti Ismail (2117862)
import 'package:flutter/material.dart';
import 'package:family_tracker/nav_bar.dart';
import 'package:family_tracker/pages/reminder_page.dart';
import 'package:family_tracker/pages/members_profile_page.dart';
import 'package:family_tracker/pages/schedule_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0; // Index to track the current active tab

  // List of pages to display in the bottom navigation bar
  final List<Widget> pages = [
    const SchedulePage(), // Page for scheduling
    const ReminderPage(), // Page for reminders
    const MembersProfilePage(), // Page for members' profiles
  ];

  // Function to update the current index when a tab is tapped
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          pages[currentIndex], // Display the current page based on currentIndex
      bottomNavigationBar: NavBar(
        currentIndex: currentIndex, // Pass current index to NavBar
        onTabTapped: onTabTapped, // Pass function to handle tab tapping
      ),
    );
  }
}
