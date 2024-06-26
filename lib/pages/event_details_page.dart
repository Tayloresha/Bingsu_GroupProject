import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventDetailsPage extends StatefulWidget {
  final String eventId;

  EventDetailsPage({required this.eventId});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  List<String> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
  }

  Future<void> _fetchEventDetails() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
    setState(() {
      _titleController.text = doc['title'];
      _selectedDate = (doc['date'] as Timestamp).toDate();
      _selectedTime = TimeOfDay.fromDateTime(_selectedDate!);
      _selectedMembers = List<String>.from(doc['members']);
    });
  }

  void _updateEvent() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null) {
      final DateTime fullDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .update({
        'title': _titleController.text,
        'date': fullDateTime,
        'members': _selectedMembers,
      }).then((_) {
        Navigator.pop(context);
      });
    }
  }

  void _deleteEvent() {
    FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .delete()
        .then((_) {
      Navigator.pop(context);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _selectTime(BuildContext context) async {
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
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteEvent,
          ),
        ],
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
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16.0),
              ListTile(
                title: Text(_selectedTime == null
                    ? 'No time chosen'
                    : _selectedTime!.format(context)),
                trailing: Icon(Icons.access_time),
                onTap: () => _selectTime(context),
              ),
              SizedBox(height: 16.0),
              FutureBuilder<List<String>>(
                future: _fetchMembers(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final members = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    hint: Text('Select Members'),
                    items: members.map((String member) {
                      return DropdownMenuItem<String>(
                        value: member,
                        child: Text(member),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        if (newValue != null &&
                            !_selectedMembers.contains(newValue)) {
                          _selectedMembers.add(newValue);
                        }
                      });
                    },
                    validator: (value) {
                      if (_selectedMembers.isEmpty) {
                        return 'Please select at least one member';
                      }
                      return null;
                    },
                  );
                },
              ),
              Wrap(
                children: _selectedMembers.map((member) {
                  return Chip(
                    label: Text(member),
                    onDeleted: () {
                      setState(() {
                        _selectedMembers.remove(member);
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateEvent,
                child: Text('Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _fetchMembers() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('family_members').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }
}
