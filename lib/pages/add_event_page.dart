import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddEventPage extends StatefulWidget {
  final String? eventId;

  AddEventPage({this.eventId});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEventData();
    }
  }

  Future<void> _loadEventData() async {
    DocumentSnapshot event = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    DateTime eventDate = event['date'].toDate();
    setState(() {
      _titleController.text = event['title'];
      _selectedDate = eventDate;
      _selectedTime = TimeOfDay(hour: eventDate.hour, minute: eventDate.minute);
      _selectedMembers = List<String>.from(event['members']);
    });
  }

  void _addOrUpdateEvent() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      DateTime eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      if (widget.eventId == null) {
        FirebaseFirestore.instance.collection('events').add({
          'title': _titleController.text,
          'date': eventDateTime,
          'members': _selectedMembers,
        }).then((_) {
          Navigator.pop(context);
        });
      } else {
        FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'title': _titleController.text,
          'date': eventDateTime,
          'members': _selectedMembers,
        }).then((_) {
          Navigator.pop(context);
        });
      }
    }
  }

  Future<List<String>> _fetchFamilyMembers() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('family_members').get();
    return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventId == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Event Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an event title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(_selectedDate == null
                    ? 'No date chosen'
                    : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                trailing: Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'No time chosen'
                    : _selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: _selectTime,
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<String>>(
                future: _fetchFamilyMembers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return DropdownButtonFormField(
                    items: snapshot.data!
                        .map((member) => DropdownMenuItem(
                              child: Text(member),
                              value: member,
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (!_selectedMembers.contains(value)) {
                        setState(() {
                          _selectedMembers.add(value as String);
                        });
                      }
                    },
                    decoration: InputDecoration(labelText: 'Select Members'),
                  );
                },
              ),
              Wrap(
                children: _selectedMembers
                    .map((member) => Chip(
                          label: Text(member),
                          onDeleted: () {
                            setState(() {
                              _selectedMembers.remove(member);
                            });
                          },
                        ))
                    .toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _addOrUpdateEvent,
                child:
                    Text(widget.eventId == null ? 'Add Event' : 'Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
