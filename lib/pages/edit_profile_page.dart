import 'package:flutter/material.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/firestore.dart';
//import 'package:family_tracker/textfield_widget.dart';

class EditProfilePage extends StatefulWidget {
  final Member member;

  const EditProfilePage({super.key, required this.member});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirestoreService firestoreService = FirestoreService();
  late Member member;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                initialValue: member.name,
                onChanged: (value) => member.name = value,
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Relationship'),
                initialValue: member.relationship,
                onChanged: (value) => member.relationship = value,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a relationship' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                initialValue: member.age.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) => member.age = int.tryParse(value) ?? 0,
                validator: (value) => value!.isEmpty ? 'Enter an age' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                initialValue: member.phoneNumber,
                onChanged: (value) => member.phoneNumber = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                initialValue: member.address,
                onChanged: (value) => member.address = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Occupation'),
                initialValue: member.occupation,
                onChanged: (value) => member.occupation = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Education'),
                initialValue: member.education,
                onChanged: (value) => member.education = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Blood Type'),
                initialValue: member.bloodType,
                onChanged: (value) => member.bloodType = value,
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medical History'),
                initialValue: member.medicalHistory,
                onChanged: (value) => member.medicalHistory = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await firestoreService.updateFamilyMember(member);
                    Navigator.pop(context, member);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
