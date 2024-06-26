import 'package:flutter/material.dart';
import 'package:family_tracker/member.dart';
import 'package:family_tracker/pages/edit_profile_page.dart';
import 'package:family_tracker/firestore.dart';

class MemberDetailPage extends StatefulWidget {
  final Member member;
  final String docID;

  const MemberDetailPage(
      {super.key, required this.member, required this.docID});

  @override
  _MemberDetailPageState createState() => _MemberDetailPageState();
}

class _MemberDetailPageState extends State<MemberDetailPage> {
  final FirestoreService firestoreService = FirestoreService();
  late Member member;

  @override
  void initState() {
    super.initState();
    member = widget.member;
  }

  void _deleteMember() async {
    await firestoreService.deleteMember(widget.docID);
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(member.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Member'),
                  content: const Text(
                      'Are you sure you want to delete this member?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteMember();
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
          buildName(member),
          const SizedBox(height: 24),
          buildDetails(member),
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
              member = updatedMember;
            });
          }
        },
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

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

  Widget buildDetails(Member member) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              buildButton(member.age.toString(), 'Age'),
              buildDivider(),
              buildButton(member.birthday ?? 'N/A', 'Birthday'),
              buildDivider(),
              buildButton(member.bloodType ?? 'N/A', 'Blood Type'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        buildDetail(member.phoneNumber ?? 'N/A', 'Phone Number'),
        buildDetail(member.occupation ?? 'N/A', 'Occupation'),
        buildDetail(member.address ?? 'N/A', 'Address'),
        buildDetail(member.education ?? 'N/A', 'Education'),
        buildDetail(member.medicalHistory ?? 'N/A', 'Medical History'),
      ],
    );
  }

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

  Widget buildDivider() => Container(
        height: 24,
        child: const VerticalDivider(),
      );

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
