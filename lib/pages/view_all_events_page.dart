import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:family_tracker/pages/event_details_page.dart';
import 'package:family_tracker/pages/add_event_page.dart';

class ViewAllEventsPage extends StatelessWidget {
  const ViewAllEventsPage({super.key});

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Events'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('events').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event['title']),
                subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm')
                    .format(event['date'].toDate())),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventDetailsPage(eventId: event.id),
                    ),
                  );
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AddEventPage(eventId: event.id),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteEvent(context, event.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
