import 'package:flutter/material.dart';

// Stateless widget for the bottom navigation bar
class NavBar extends StatelessWidget {
  final int currentIndex; // Current selected tab index
  final Function(int) onTabTapped; // Function to handle tab tap events

  // Constructor to initialize NavBar with required parameters
  const NavBar({
    super.key, 
    required this.currentIndex, 
    required this.onTabTapped
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex, // Set the current active tab index
      onTap: onTabTapped, // Handle tab tap events
      backgroundColor: const Color.fromARGB(255, 116, 56, 183), // Background color of the navigation bar
      selectedItemColor: Colors.white, // Color for selected tab item
      unselectedItemColor: Colors.white.withOpacity(0.7), // Color for unselected tab items
      showUnselectedLabels: false, // Hide labels for unselected tab items
      items: const [
        // List of bottom navigation bar items
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today), // Icon for Schedule tab
          label: 'Schedule', // Label for Schedule tab
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assignment), // Icon for Reminders tab
          label: 'Reminders', // Label for Reminders tab
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people), // Icon for Members tab
          label: 'Members', // Label for Members tab
        ),
      ],
    );
  }
}
