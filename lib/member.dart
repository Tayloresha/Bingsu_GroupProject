//import 'dart:ffi';

class Member {
  String id;
  String name;
  String relationship;
  int age;
  String? phoneNumber;
  String? address;
  String? occupation;
  String? education;
  String? bloodType;
  String? medicalHistory;
  String? birthday;

  Member({
    required this.id,
    required this.name,
    required this.relationship,
    required this.age,
    this.phoneNumber,
    this.address,
    this.occupation,
    this.education,
    this.bloodType,
    this.medicalHistory,
    this.birthday,
  });

  // Method to create a Member from a Firestore document
  factory Member.fromMap(Map<String, dynamic> data, String documentId) {
    return Member(
      id: documentId,
      name: data['name'] ?? '',
      relationship: data['relationship'] ?? '',
      age: data['age'] ?? 0,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      occupation: data['occupation'],
      education: data['education'],
      bloodType: data['bloodType'],
      medicalHistory: data['medicalHistory'],
      birthday: data['birthday'],
    );
  }

  // Method to convert a Member to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'relationship': relationship,
      'age': age,
      'phoneNumber': phoneNumber,
      'address': address,
      'occupation': occupation,
      'education': education,
      'bloodType': bloodType,
      'medicalHistory': medicalHistory,
      'birthday': birthday,
    };
  }
}
