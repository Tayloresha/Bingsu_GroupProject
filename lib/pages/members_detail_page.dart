import 'package:flutter/material.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/pages/edit_profile_page.dart';
import 'package:family_tracker/firestore.dart';

// Stateful widget to display detailed information of a member
class MemberDetailPage extends StatefulWidget {
  final Member member; // The member to display details for
  final String docID; // The document ID of the member in Firestore

  const MemberDetailPage({super.key, required this.member, required this.docID});

  @override
  _MemberDetailPageState createState() => _MemberDetailPageState();
}

// State class for MemberDetailPage
class _MemberDetailPageState extends State<MemberDetailPage> {
  final FirestoreService firestoreService = FirestoreService();
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member; // Initialize the member with the passed member data
  }

  // Method to delete the member from Firestore
  void _deleteMember() async {
    await firestoreService.deleteMember(widget.docID);
    Navigator.of(context).pop(); // Go back to the previous screen after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name), // Display the member's name as the title
        actions: [
          IconButton(
            icon: const Icon(Icons.delete), // Delete icon button in the app bar
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Member'),
                  content: const Text('Are you sure you want to delete this member?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(), // Close the dialog
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteMember(); // Call the delete method
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          buildName(member), // Display the member's name and relationship
          const SizedBox(height: 24),
          buildDetails(member), // Display detailed information of the member
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedMember = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EditProfilePage(member: member),
            ),
          );

          if (updatedMember != null) {
            setState(() {
              member = updatedMember; // Update the member details if edited
            });
          }
        },
        child: const Icon(Icons.edit), // Edit icon button
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Widget to display the member's name and relationship
  Widget buildName(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          member.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          member.relationship,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  // Widget to display detailed information of the member
  Widget buildDetails(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildButton(member.age.toString(), 'Age'), // Display age
              buildDivider(),
              buildButton(member.birthday ?? 'N/A', 'Birthday'), // Display birthday
              buildDivider(),
              buildButton(member.bloodType ?? 'N/A', 'Blood Type'), // Display blood type
            ],
          ),
        ),
        const SizedBox(height: 24),
        buildDetail(member.phoneNumber ?? 'N/A', 'Phone Number'), // Display phone number
        buildDetail(member.occupation ?? 'N/A', 'Occupation'), // Display occupation
        buildDetail(member.address ?? 'N/A', 'Address'), // Display address
        buildDetail(member.education ?? 'N/A', 'Education'), // Display education
        buildDetail(member.medicalHistory ?? 'N/A', 'Medical History'), // Display medical history
      ],
    );
  }

  // Widget to display each detail with a label
  Widget buildButton(String detail, String label) {
    return MaterialButton(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
      onPressed: () {},
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            detail,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  // Widget to create a vertical divider
  Widget buildDivider() => Container(
        height: 24,
        child: const VerticalDivider(),
      );

  // Widget to display each detailed information of the member
  Widget buildDetail(String detail, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: const TextStyle(fontSize: 16, height: 1.4),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
