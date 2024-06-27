// Nora Alissa binti Ismail (2117862)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tracker/member.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getFamilyMembers() {
    return _db.collection('family_members').snapshots();
  }

  Future<void> addFamilyMember(Member member) {
    return _db.collection('family_members').add(member.toMap());
  }

  Future<void> updateFamilyMember(Member member) {
    return _db
        .collection('family_members')
        .doc(member.id)
        .update(member.toMap());
  }

  Future<void> deleteMember(String docID) async {
    await _db.collection('family_members').doc(docID).delete();
  }
}
