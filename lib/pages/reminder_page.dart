/* 
Allows users to manage reminders within a Flutter application. It utilizes
Firebase for authentication and Firestore for data storage, alongside a 
local notification system for reminder alerts
*/

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tracker/auth.dart';
import 'package:family_tracker/notification_service.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:family_tracker/reminder.dart';
import 'package:intl/intl.dart';

class ReminderPage extends StatefulWidget {
  const ReminderPage({super.key});

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final User? user = Auth().currentUser;
  late NotificationService _notificationService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Reminder> _reminders = [];
  int _nextId = 0;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService(_firestore, user);
    _notificationService.initNotification();
    NotificationService.setOnReminderDeleted(_removeReminderById);
    _loadReminders();
  }

  //load reminders from firestore
  Future<void> _loadReminders() async {
    final snapshot = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid)
        .get();

    setState(() {
      _reminders.addAll(
        snapshot.docs.map((doc) => Reminder.fromMap(doc.data())).toList(),
      );
      _nextId = _reminders.isNotEmpty
          ? _reminders.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1
          : 0;
    });
  }

  //add reminder to firestore
  Future<void> _addReminder() async {
    final newReminder = Reminder(id: _nextId++, text: 'New Reminder');
    setState(() {
      _reminders.add(newReminder);
    });
    await _firestore.collection('reminders').add({
      'id': newReminder.id,
      'text': newReminder.text,
      'dateTime': newReminder.dateTime?.millisecondsSinceEpoch,
      'userId': user?.uid,
    });
  }

  //update reminder in firestore
  Future<void> _updateReminder(Reminder reminder) async {
    final doc = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid)
        .where('id', isEqualTo: reminder.id)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
    await doc.reference.update(reminder.toMap());
  }

  //delete reminder from firestore
  Future<void> _deleteReminder(Reminder reminder) async {
    setState(() {
      _reminders.remove(reminder);
    });
    final doc = await _firestore
        .collection('reminders')
        .where('userId', isEqualTo: user?.uid)
        .where('id', isEqualTo: reminder.id)
        .limit(1)
        .get()
        .then((snapshot) => snapshot.docs.first);
    await doc.reference.delete();
  }

  //pick date and time for reminder and schedule notification
  Future<void> _pickDateTime(Reminder reminder) async {
    DateTime? dateTime = await showOmniDateTimePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      lastDate: DateTime.now().add(
        const Duration(days: 3652),
      ),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(
        maxWidth: 350,
        maxHeight: 650,
      ),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1.drive(
            Tween(
              begin: 0,
              end: 1,
            ),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
      selectableDayPredicate: (dateTime) {
        return true;
      },
    );

    if (dateTime != null) {
      setState(() {
        reminder.dateTime = dateTime;
      });
      await _updateReminder(reminder);
      await _notificationService.scheduleNotification(
        dateTime,
        id: reminder.id,
        title: 'FamilyConnect Pro',
        body: 'Reminder: ${reminder.text}',
      );
    }
  }

  //edit reminder text
  void _editReminder(Reminder reminder) {
    TextEditingController controller =
        TextEditingController(text: reminder.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Reminder'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Reminder Text'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                setState(() {
                  reminder.text = controller.text;
                });
                await _updateReminder(reminder);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //remove reminder from list
  void _removeReminderById(int id) {
    setState(() {
      _reminders.removeWhere((element) => element.id == id);
    });
  }

  //format date and time
  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  //reminder item widget
  Widget _reminderItem(Reminder reminder) {
    return Dismissible(
      key: Key(reminder.id.toString()),
      onDismissed: (direction) {
        _deleteReminder(reminder);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reminder.text} removed'),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            reminder.text,
            style: const TextStyle(
                color: Colors.black87,
                fontSize: 16.0,
                fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            reminder.dateTime != null
                ? _formatDateTime(reminder.dateTime!)
                : 'No date selected',
            style: const TextStyle(color: Colors.black54),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => _pickDateTime(reminder),
                color: const Color.fromARGB(255, 116, 56, 183), // Purple color
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _editReminder(reminder),
                color: const Color.fromARGB(255, 70, 121, 231), // Blue color
              ),
            ],
          ),
        ),
      ),
    );
  }

  //title widget
  Widget _title() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.family_restroom, color: Colors.white),
        SizedBox(width: 8),
        Text(
          'Reminders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  //build widget: app bar, body, floating action button
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
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 222, 205, 240),
                  Color.fromARGB(255, 145, 169, 230), // Purple color
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(6.0),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _reminders.length,
                  itemBuilder: (context, index) {
                    return _reminderItem(_reminders[index]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        backgroundColor: const Color.fromARGB(255, 116, 56, 183),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
