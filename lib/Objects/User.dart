import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  Patient,
  Therapist,
  Administrator;

  @override
  String toString() => name;
}

Map<String, UserType> userTypeMap = {
  "Patient": UserType.Patient,
  "Therapist": UserType.Therapist,
  "Administrator": UserType.Administrator
};

List<String> DefaultTherapistTypes = [
  "Art Therapist",
  "Athletic Trainer",
  "Certified Strength and Conditioning Specialist",
  "Dance Therapist",
  "Exercise Physiologist",
  "Music Therapist",
  "Occupational Therapist",
  "Physical Therapist",
  "Psychiatrist",
  "Psychologist",
  "Respiratory Therapist",
  "Social Worker",
  "Speech-Language Pathologist",
];

class TheraportalUser {
  String id;
  String email;
  String firstName;
  String lastName;

  String? groupId;
  UserType userType;
  Timestamp dateCreated;
  Timestamp? dateOfBirth;
  String referenceCode;
  String? therapistType;

  TheraportalUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.groupId,
    required this.userType,
    required this.dateCreated,
    required this.referenceCode,
    this.dateOfBirth,
    this.therapistType,
  });

  //factory constructor to create a User object from a map
  factory TheraportalUser.fromMap(Map<String, dynamic> user_map) {
    var user_type = user_map['user_type'];
    user_type = (user_type is String) ? userTypeMap[user_type] : user_type;
    user_map['org_reference_code'];
    return TheraportalUser(
        id: user_map['userId'],
        email: user_map['email'],
        firstName: user_map['first_name'],
        lastName: user_map['last_name'],
        groupId: user_map['org_reference_code'],
        userType: user_type,
        dateCreated:
            user_map['date_created'], //adjust according to Firestore timestamp
        referenceCode: user_map['user_reference_code'],
        dateOfBirth: user_map["date_of_birth"],
        therapistType: user_map['therapist_type']);
  }

  //method to convert User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'group_id': groupId,
      'user_type': userType.toString(),
      'date_created': dateCreated, //adjust according to Firestore timestamp
      'user_reference_code': referenceCode,
    };
  }
}
