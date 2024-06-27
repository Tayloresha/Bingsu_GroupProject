import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tracker/member.dart';

// Service class to handle Firestore database operations
class FirestoreService {
  // Instance of FirebaseFirestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream to get real-time updates of family members collection
  Stream<QuerySnapshot> getFamilyMembers() {
    return _db.collection('family_members').snapshots();
  }

  // Function to add a new family member to the collection
  Future<void> addFamilyMember(Member member) {
    return _db.collection('family_members').add(member.toMap());
  }

  // Function to update an existing family member's details
  Future<void> updateFamilyMember(Member member) {
    return _db
        .collection('family_members')
        .doc(member.id)
        .update(member.toMap());
  }

  // Function to delete a family member from the collection
  Future<void> deleteMember(String docID) async {
    await _db.collection('family_members').doc(docID).delete();
  }
}
