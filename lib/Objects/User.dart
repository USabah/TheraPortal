import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  Patient,
  Therapist,
  Administrator;

  @override
  String toString() => name;
}

class User {
  String id;
  String email;
  String firstName;
  String lastName;

  String groupId;
  UserType userType;
  DateTime dateCreated;
  String referenceCode;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.groupId,
    required this.userType,
    required this.dateCreated,
    required this.referenceCode,
  });

  //factory constructor to create a User object from a map
  factory User.fromMap(Map<String, dynamic> user_map) {
    return User(
      id: user_map['id'],
      email: user_map['email'],
      firstName: user_map['first_name'],
      lastName: user_map['last_name'],
      groupId: user_map['group_id'],
      userType: user_map['user_type'],
      dateCreated: (user_map['date_created'] as Timestamp)
          .toDate(), //adjust according to Firestore timestamp
      referenceCode: user_map['reference_code'] ?? '',
    );
  }

  //method to convert User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'group_id': groupId,
      'user_type': userType,
      'date_created':
          dateCreated as Timestamp, //adjust according to Firestore timestamp
      'reference_code': referenceCode,
    };
  }
}
