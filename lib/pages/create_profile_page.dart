import 'package:flutter/material.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/firestore.dart';

// Stateful widget to create a new member profile
class CreateProfilePage extends StatefulWidget {
  const CreateProfilePage({super.key});

  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

// State class for CreateProfilePage
class _CreateProfilePageState extends State<CreateProfilePage> {
  final FirestoreService firestoreService = FirestoreService(); // Firestore service instance
  final _formKey = GlobalKey<FormState>(); // GlobalKey for the form
  late Member member;

  @override
  void initState() {
    super.initState();
    // Initialize member with default values
    member = Member(id: '', name: '', relationship: '', age: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Profile'), // AppBar title
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the form
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Full Name'),
                onChanged: (value) => member.name = value, // Update member name
                validator: (value) => value!.isEmpty ? 'Enter a name' : null, // Validation
              ),
              const SizedBox(height: 20), // Space between form fields
              TextFormField(
                decoration: const InputDecoration(labelText: 'Relationship'),
                onChanged: (value) => member.relationship = value, // Update member relationship
                validator: (value) => value!.isEmpty ? 'Enter a relationship' : null, // Validation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number, // Set input type to number
                onChanged: (value) => member.age = int.tryParse(value) ?? 0, // Update member age
                validator: (value) => value!.isEmpty ? 'Enter an age' : null, // Validation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                onChanged: (value) => member.phoneNumber = value, // Update member phone number
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Address'),
                onChanged: (value) => member.address = value, // Update member address
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Occupation'),
                onChanged: (value) => member.occupation = value, // Update member occupation
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Education'),
                onChanged: (value) => member.education = value, // Update member education
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Blood Type'),
                onChanged: (value) => member.bloodType = value, // Update member blood type
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Medical History'),
                onChanged: (value) => member.medicalHistory = value, // Update member medical history
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Birthday'),
                onChanged: (value) => member.birthday = value, // Update member birthday
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // If form is valid, add the new member to Firestore
                    await firestoreService.addFamilyMember(member);
                    Navigator.pop(context, member); // Go back to the previous screen with the new member
                  }
                },
                child: const Text('Create'), // Button text
              ),
            ],
          ),
        ),
      ),
    );
  }
}
