import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:family_tracker/pages/add_event_page.dart';
import 'package:family_tracker/pages/event_details_page.dart';
import 'package:family_tracker/pages/view_all_events_page.dart';
import 'package:family_tracker/auth.dart';
import 'package:table_calendar/table_calendar.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  _SchedulePageState createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    FirebaseFirestore.instance
        .collection('events')
        .snapshots()
        .listen((snapshot) {
      final Map<DateTime, List<dynamic>> events = {};
      for (var document in snapshot.docs) {
        DateTime eventDate = document['date'].toDate();
        DateTime eventDay =
            DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (events[eventDay] == null) {
          events[eventDay] = [];
        }
        events[eventDay]?.add(document);
      }
      setState(() {
        _events = events;
      });
    });
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Widget _title() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.family_restroom, color: Colors.white),
        SizedBox(width: 8),
        Text(
          'Family Schedule',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        centerTitle: true, // Center the title
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 111, 149, 231), // Blue color
                Color.fromARGB(255, 116, 56, 183), // Purple color
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await Auth().signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Container(
        color: Color.fromARGB(255, 250, 247, 252), // Single background color
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(6.0),
            ),
            TableCalendar(
              firstDay: DateTime.utc(2000, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onFormatChanged: (format) {
                if (_calendarFormat != format) {
                  setState(() {
                    _calendarFormat = format;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _getEventsForDay,
            ),
            Expanded(
              child: _selectedDay == null
                  ? Center(child: Text('Select a day to see events'))
                  : ListView.builder(
                      itemCount: _getEventsForDay(_selectedDay!).length,
                      itemBuilder: (context, index) {
                        final event = _getEventsForDay(_selectedDay!)[index];
                        return ListTile(
                          title: Text(event['title']),
                          subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm')
                              .format(event['date'].toDate())),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EventDetailsPage(eventId: event.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewAllEventsPage()),
                    );
                  },
                  child: const Text('View All Events'),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEventPage()),
          );
        },
        backgroundColor: const Color.fromARGB(255, 116, 56, 183),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
