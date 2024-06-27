import 'package:flutter/material.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/firestore.dart';

// Stateful widget to edit an existing member profile
class EditProfilePage extends StatefulWidget {
  final Member member; // Member to be edited

  const EditProfilePage({super.key, required this.member});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

// State class for EditProfilePage
class _EditProfilePageState extends State<EditProfilePage> {
  final FirestoreService firestoreService = FirestoreService(); // Firestore service instance
  late Member member; // Member object to hold the edited details
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form

  @override
  void initState() {
    super.initState();
    member = widget.member; // Initialize member with the passed member details
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'), // AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                initialValue: member.name, // Set initial value to current name
                onChanged: (value) => member.name = value, // Update member name
                validator: (value) => value!.isEmpty ? 'Enter a name' : null, // Validation
              ),
              const SizedBox(height: 20), // Space between form fields
              TextFormField(
                decoration: const InputDecoration(labelText: 'Relationship'),
                initialValue: member.relationship, // Set initial value to current relationship
                onChanged: (value) => member.relationship = value, // Update member relationship
                validator: (value) => value!.isEmpty ? 'Enter a relationship' : null, // Validation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                initialValue: member.age.toString(), // Set initial value to current age
                keyboardType: TextInputType.number, // Set input type to number
                onChanged: (value) => member.age = int.tryParse(value) ?? 0, // Update member age
                validator: (value) => value!.isEmpty ? 'Enter an age' : null, // Validation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                initialValue: member.phoneNumber, // Set initial value to current phone number
                onChanged: (value) => member.phoneNumber = value, // Update member phone number
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                initialValue: member.address, // Set initial value to current address
                onChanged: (value) => member.address = value, // Update member address
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Occupation'),
                initialValue: member.occupation, // Set initial value to current occupation
                onChanged: (value) => member.occupation = value, // Update member occupation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Education'),
                initialValue: member.education, // Set initial value to current education
                onChanged: (value) => member.education = value, // Update member education
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Blood Type'),
                initialValue: member.bloodType, // Set initial value to current blood type
                onChanged: (value) => member.bloodType = value, // Update member blood type
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medical History'),
                initialValue: member.medicalHistory, // Set initial value to current medical history
                onChanged: (value) => member.medicalHistory = value, // Update member medical history
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If form is valid, update the member in Firestore
                    await firestoreService.updateFamilyMember(member);
                    Navigator.pop(context, member); // Go back to the previous screen with the updated member
                  }
                },
                child: const Text('Save'), // Button text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
