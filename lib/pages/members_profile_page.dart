import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:family_tracker/pages/create_profile_page.dart';
import 'package:family_tracker/pages/members_detail_page.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/firestore.dart';

// Main widget for displaying the members profile page
class MembersProfilePage extends StatefulWidget {
  const MembersProfilePage({super.key});

  @override
  _MembersProfilePageState createState() => _MembersProfilePageState();
}

// State class for MembersProfilePage
class _MembersProfilePageState extends State<MembersProfilePage> {
  final FirestoreService firestoreService = FirestoreService();

  // Navigate to create profile page and add new member if created
  void _navigateToCreateProfile(BuildContext context) async {
    final newMember = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateProfilePage(),
      ),
    );

    if (newMember != null) {
      setState(() {
        // Data will be updated via Firestore stream
      });
    }
  }

  // Widget to display the title with an icon
  Widget _title() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.family_restroom, color: Colors.white),
        SizedBox(width: 8),
        Text(
          "Family Members' Profile",
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
      // App bar with title and gradient background
      appBar: AppBar(
        title: _title(),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 111, 149, 231),
                Color.fromARGB(255, 116, 56, 183),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      // Main body with gradient background and stream builder to display members
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 222, 205, 240),
                  Color.fromARGB(255, 145, 169, 230),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // StreamBuilder to listen for real-time updates from Firestore
          StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getFamilyMembers(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<DocumentSnapshot> membersList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: membersList.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = membersList[index];
                    String docID = document.id;
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;

                    Member member = Member.fromMap(data, docID);

                    // Card to display each member's information
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          member.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          "${member.age} • ${member.relationship}",
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: const Icon(Icons.person),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => MemberDetailPage(
                                member: member,
                                docID: docID,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                // Display error message if there's an error in the stream
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // Display a loading indicator while waiting for data
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      // Floating action button to navigate to create profile page
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCreateProfile(context),
        backgroundColor: const Color.fromARGB(255, 116, 56, 183),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
