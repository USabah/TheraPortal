import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';

class DatabaseRouter {
  FirebaseFirestore _firestore;

  DatabaseRouter({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<TheraportalUser> getUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('Users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null) {
          return TheraportalUser.fromMap(userData);
        }
      }
      throw Exception('User not found');
    } catch (e) {
      print('Error getting user: $e');
      rethrow;
    }
  }

  Future<String> addUser(TheraportalUser user) async {
    try {
      CollectionReference usersRef = _firestore.collection('Users');
      await usersRef.doc(user.id).set(user.toMap());
      return user.id;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  //check if a field exists
  Future<bool> fieldExists(
      String collectionName, String fieldName, dynamic fieldValue) async {
    final QuerySnapshot<Map<String, dynamic>> result = await _firestore
        .collection(collectionName)
        .where(fieldName, isEqualTo: fieldValue)
        .limit(
            1) // Limit to 1 document to optimize query (we only need to know if any exists)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getTherapistCardInfo(
      TheraportalUser currentUser, List<Session> userSessions) async {
    List<Map<String, dynamic>> therapists = [];

    try {
      List<String> therapistUserIds =
          await _getTherapistIdsForPatient(currentUser.id);
      for (String therapistUserId in therapistUserIds) {
        TheraportalUser therapist = await getUser(therapistUserId);
        String? groupName = await _getGroupName(therapist.groupId);
        Session? nextScheduledSession = (userSessions.isNotEmpty)
            ? Session.getNextSession(userSessions, currentUser.id, therapist.id)
            : null;
        // DateTime? nextScheduledSession =
        //     await _getNextScheduledSession(therapistUserId, patientUserId);

        therapists.add({
          "therapist": therapist,
          "group_name": groupName,
          "next_session": nextScheduledSession
        });
      }
      return therapists;
    } catch (e) {
      print('Error retrieving therapists: $e');
      return [];
    }
  }

  Future<List<String>> _getTherapistIdsForPatient(String patientUserId) async {
    QuerySnapshot assignmentsQuery = await _firestore
        .collection('Assignments')
        .where('patient_id', isEqualTo: patientUserId)
        .get();

    List<String> therapistIds = assignmentsQuery.docs
        .map((assignment) => assignment['therapist_id'] as String)
        .toList();

    return therapistIds;
  }

  Future<String?> _getGroupName(String? groupIdString) async {
    if (groupIdString == null || groupIdString == "") return null;
    DocumentSnapshot groupDoc =
        await _firestore.collection('Groups').doc(groupIdString).get();

    if (groupDoc.exists) {
      return groupDoc['name'] as String;
    } else {
      return null;
    }
  }

  // Future<DateTime?> _getNextScheduledSession(
  //     String therapistUserId, String patientUserId) async {
  //   QuerySnapshot sessionsQuery = await _firestore
  //       .collection('Assignments')
  //       .where('patient_id', isEqualTo: patientUserId)
  //       .where('therapist_id', isEqualTo: therapistUserId)
  //       .limit(1)
  //       .get();

  //   if (sessionsQuery.docs.isNotEmpty) {
  //     String assignmentId = sessionsQuery.docs.first.id;
  //     QuerySnapshot scheduledSessionsQuery = await _firestore
  //         .collection('Assignments')
  //         .doc(assignmentId)
  //         .collection('ScheduledSessions')
  //         .orderBy('scheduled_for', descending: false)
  //         .limit(1)
  //         .get();

  //     if (scheduledSessionsQuery.docs.isNotEmpty) {
  //       return scheduledSessionsQuery.docs.first['scheduled_for'].toDate();
  //     }
  //   }

  //   return null;
  // }

  Future<List<Map<String, dynamic>>> getPatientCardInfo(
      TheraportalUser currentUser, List<Session> userSessions) async {
    List<Map<String, dynamic>> patients = [];

    try {
      List<String> patientUserIds =
          await _getPatientIdsForTherapist(currentUser.id);
      for (String patientUserId in patientUserIds) {
        TheraportalUser patient = await getUser(patientUserId);
        String? groupName = await _getGroupName(patient.groupId);
        Session? nextScheduledSession = (userSessions.isNotEmpty)
            ? Session.getNextSession(userSessions, patient.id, currentUser.id)
            : null;

        patients.add({
          "patient": patient,
          "group_name": groupName,
          "next_session": nextScheduledSession
        });
      }
      return patients;
    } catch (e) {
      print('Error retrieving patients: $e');
      return [];
    }
  }

  Future<List<String>> _getPatientIdsForTherapist(
      String therapistUserId) async {
    QuerySnapshot assignmentsQuery = await _firestore
        .collection('Assignments')
        .where('therapist_id', isEqualTo: therapistUserId)
        .get();

    List<String> patientIds = assignmentsQuery.docs
        .map((assignment) => assignment['patient_id'] as String)
        .toList();

    return patientIds;
  }

  Future<Map<String, dynamic>> getSingleUserCardInfo(
      TheraportalUser user) async {
    String? groupName = await _getGroupName(user.groupId);

    if (user.userType == UserType.Patient) {
      return {
        "patient": user,
        "group_name": groupName,
        "next_session": null,
      };
    } else if (user.userType == UserType.Therapist) {
      return {
        "therapist": user,
        "group_name": groupName,
        "next_session": null,
      };
    } else {
      return {};
    }
  }

  Future<Stream<QuerySnapshot<Object?>>> fetchMessageStream(
      String user1Id, String user2Id) async {
    Stream<QuerySnapshot> stream = const Stream.empty();

    final messagesReference = await getMessagesReference(user1Id, user2Id);

    // Return a stream of the 'messages' subcollection of that document
    stream = messagesReference
        .orderBy('timestamp', descending: false)
        .limit(15)
        .snapshots();

    return stream;

    // testFireStore(user1Id, user2Id);
  }

  Future<CollectionReference<Map<String, dynamic>>> getMessagesReference(
      String user1Id, String user2Id) async {
    var concat_ids = _concatenateIds(user1Id, user2Id);
    var chatReference = await _firestore
        .collection('Communications')
        .where('concatenated_ids', isEqualTo: concat_ids)
        .snapshots()
        .first;
    DocumentReference docRef = chatReference.docs.first.reference;
    return docRef.collection('Messages');
  }

  //helper function to concatenate user IDs into a single string
  String _concatenateIds(String user1Id, String user2Id) {
    List<String> sortedIds = [user1Id, user2Id]..sort();
    return sortedIds.join('_');
  }

  Future<List<Map<String, dynamic>>> geUserMessagesInfo(
      String userId, UserType userType) async {
    List<Map<String, dynamic>> messageInfoList = [];
    List<String> messageIdsList = [];
    try {
      if (userType == UserType.Patient) {
        messageIdsList = await _getTherapistIdsForPatient(userId);
      } else if (userType == UserType.Therapist) {
        messageIdsList = await _getMessageIdsForTherapist(userId);
      }
      for (String messageId in messageIdsList) {
        Map<String, dynamic> messageInfo =
            await _getMessageInfo(userId, messageId);
        messageInfoList.add(messageInfo);
      }
      return messageInfoList;
    } catch (e) {
      print('Error fetching user messages: $e');
      return []; // Return empty list on error
    }
  }

  // Future<Stream<List<Map<String, dynamic>>>> userMessagesStream(
  //     String userId, UserType userType) async {
  //   StreamController<List<Map<String, dynamic>>> controller =
  //       StreamController<List<Map<String, dynamic>>>();

  //   try {
  //     List<String> messageIdsList = [];
  //     if (userType == UserType.Patient) {
  //       messageIdsList = await _getTherapistIdsForPatient(userId);
  //     } else if (userType == UserType.Therapist) {
  //       messageIdsList = await _getMessageIdsForTherapist(userId);
  //     }

  //     List<Map<String, dynamic>> messageInfoList = [];
  //     for (String messageId in messageIdsList) {
  //       Map<String, dynamic> messageInfo =
  //           await _getMessageInfo(userId, messageId);
  //       messageInfoList.add(messageInfo);
  //     }

  //     // Emit the initial list of message info
  //     controller.add(messageInfoList);

  //     // Listen for changes in the Messages subcollection
  //     _firestore
  //         .collection('Communications')
  //         .where('user1_id', isEqualTo: userId)
  //         .snapshots()
  //         .listen((snapshot) async {
  //       List<Map<String, dynamic>> updatedMessageInfoList = [];
  //       for (String messageId in messageIdsList) {
  //         Map<String, dynamic> messageInfo =
  //             await _getMessageInfo(userId, messageId);
  //         updatedMessageInfoList.add(messageInfo);
  //       }
  //       controller.add(updatedMessageInfoList);
  //     });

  //     return controller.stream;
  //   } catch (e) {
  //     controller.addError('Error fetching user messages: $e');
  //     return controller.stream; // Return stream with error message
  //   }
  // }

  Future<List<String>> _getMessageIdsForTherapist(String userId) async {
    List<String> patientIds = await _getPatientIdsForTherapist(userId);
    Set<String> therapistMessageIds = <String>{};

    //get therapistIds for each patient
    for (String patientId in patientIds) {
      List<String> therapistIds = await _getTherapistIdsForPatient(patientId);
      therapistMessageIds.addAll(therapistIds);
    }
    therapistMessageIds.remove(userId); //exclude current therapist (self)

    //merge patientIds and therapistIds into a single list
    List<String> messageIdsList = List.from(patientIds)
      ..addAll(therapistMessageIds);
    return messageIdsList;
  }

  Future<Map<String, dynamic>> _getMessageInfo(
      String currentUserId, String withUserId) async {
    String concatenatedIds = _concatenateIds(currentUserId, withUserId);
    TheraportalUser withUser = await getUser(withUserId);
    try {
      //check if a communication document exists with the specified concatenated_ids
      QuerySnapshot communicationQuery = await _firestore
          .collection('Communications')
          .where('concatenated_ids', isEqualTo: concatenatedIds)
          .limit(1)
          .get();

      String? messageContent;
      String? senderId;
      bool sentByCurrentUser = false;
      DateTime? messageTimestamp;

      if (communicationQuery.docs.isNotEmpty) {
        DocumentSnapshot communicationDoc = communicationQuery.docs.first;
        //get the most recent message
        QuerySnapshot messagesQuery = await communicationDoc.reference
            .collection('Messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesQuery.docs.isNotEmpty) {
          DocumentSnapshot messageDoc = messagesQuery.docs.first;
          messageContent = messageDoc['message_content'] as String?;
          senderId = messageDoc['sender_id'] as String?;
          Timestamp? timestamp = messageDoc['timestamp'] as Timestamp?;
          messageTimestamp = timestamp?.toDate();
        }
      } else {
        //communication document does not exist, create a new one
        await _createCommunicationDocument(
            concatenatedIds, currentUserId, withUserId);
      }
      sentByCurrentUser = (senderId == currentUserId);
      return {
        'messageContent': messageContent,
        'sentByCurrentUser': sentByCurrentUser,
        'userType': withUser.userType,
        'firstName': withUser.firstName,
        'lastName': withUser.lastName,
        'withUserId': withUserId,
        'messageTimestamp': messageTimestamp
      };
    } catch (e) {
      print('Error retrieving message info: $e');
      return {
        'messageContent': null,
        'sentByCurrentUser': null,
        'userType': null,
        'firstName': null,
        'lastName': null,
        'withUserId': null,
        'messageTimestamp': null
      };
    }
  }

  //helper to create a communication document
  Future<void> _createCommunicationDocument(
      String concatenatedIds, String user1Id, String user2Id) async {
    try {
      await _firestore.collection('Communications').doc(concatenatedIds).set({
        'user1_id': user1Id,
        'user2_id': user2Id,
        'concatenated_ids': concatenatedIds,
      });
      CollectionReference _ = _firestore
          .collection('Communications')
          .doc(concatenatedIds)
          .collection('Messages');
    } catch (e) {
      print('Error creating communication document: $e');
    }
  }

  Future<void> removeAssignment(String patientId, String therapistId) async {
    try {
      CollectionReference assignments =
          FirebaseFirestore.instance.collection('Assignments');
      QuerySnapshot querySnapshot = await assignments
          .where('patient_id', isEqualTo: patientId)
          .where('therapist_id', isEqualTo: therapistId)
          .get();
      querySnapshot.docs.forEach((doc) async {
        await assignments.doc(doc.id).delete();
      });
    } catch (e) {
      print('Error removing patient assignment: $e');
    }
  }

  Future<Object> createAssignmentFromReferenceCode(String currentUserId,
      String referenceCode, UserType assignmentType) async {
    try {
      var result =
          await _getUserByReferenceCodeAndType(referenceCode, assignmentType);

      if (result is String) {
        //user not found
        return result;
      } else if (result is DocumentSnapshot<Map<String, dynamic>>) {
        TheraportalUser user = TheraportalUser.fromMap(result.data()!);
        String patientId, therapistId;
        if (assignmentType == UserType.Patient) {
          patientId = user.id;
          therapistId = currentUserId;
        } else {
          patientId = currentUserId;
          therapistId = user.id;
        }
        //check if an assignment already exists
        bool assignmentAlreadyExists =
            await _assignmentExists(patientId, therapistId);
        if (assignmentAlreadyExists) {
          return '${assignmentType.toString()} is already assigned to your account!';
        }
        //create the assignment otherwise
        await _createAssignment(patientId, therapistId);

        return user;
      } else {
        // Handle unexpected type
        return 'Unexpected error occurred.';
      }
    } catch (e) {
      print('Error creating assignment: $e');
      return 'An error occurred while creating the assignment.';
    }
  }

  Future<Object> _getUserByReferenceCodeAndType(
      String referenceCode, UserType userType) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('Users')
        .where('user_reference_code', isEqualTo: referenceCode)
        .where('user_type', isEqualTo: userType.toString())
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first;
    } else {
      return 'Could not find a ${userType.toString().toLowerCase()} with that code.';
    }
  }

  Future<bool> _assignmentExists(String patientId, String therapistId) async {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('Assignments')
        .where('patient_id', isEqualTo: patientId)
        .where('therapist_id', isEqualTo: therapistId)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> _createAssignment(String patientId, String therapistId) async {
    try {
      DocumentReference assignmentRef =
          _firestore.collection('Assignments').doc();
      //set the data for the assignment document
      await assignmentRef.set({
        'patient_id': patientId,
        'therapist_id': therapistId,
      });
    } catch (e) {
      print('Error adding assignment: $e');
      throw e;
    }
  }

  Future<bool> updateReferenceCode(String userId, String referenceCode) async {
    try {
      DocumentReference userRef =
          FirebaseFirestore.instance.collection('Users').doc(userId);
      await userRef.update({'user_reference_code': referenceCode});
      return true;
    } catch (e) {
      print('Error updating reference code: $e');
      return false;
    }
  }

  Future<List<Session>> getAllUserSessions(TheraportalUser currentUser) async {
    List<Session> sessionList = [];
    //get session documents
    QuerySnapshot assignmentSnapshot = await _firestore
        .collection('Assignments')
        .where(
            (currentUser.userType == UserType.Therapist)
                ? 'therapist_id'
                : 'patient_id',
            isEqualTo: currentUser.id)
        .get();

    //extract sessions
    for (QueryDocumentSnapshot assignmentDoc in assignmentSnapshot.docs) {
      Map<String, dynamic> assignmentData =
          assignmentDoc.data() as Map<String, dynamic>;

      TheraportalUser patient = (currentUser.userType == UserType.Patient)
          ? currentUser
          : await getUser(assignmentData["patient_id"]);
      TheraportalUser therapist = (currentUser.userType == UserType.Therapist)
          ? currentUser
          : await getUser(assignmentData['therapist_id']);

      QuerySnapshot sessionSnapshot =
          await assignmentDoc.reference.collection('ScheduledSessions').get();
      sessionList.addAll(
          _extractSessionsFromSnapshot(sessionSnapshot, patient, therapist));
    }

    return sessionList;
  }

  List<Session> _extractSessionsFromSnapshot(QuerySnapshot snapshot,
      TheraportalUser patient, TheraportalUser therapist) {
    return snapshot.docs.map((doc) {
      return Session.fromMap(
          doc.data() as Map<String, dynamic>, patient, therapist);
    }).toList();
  }

  Future<bool> addSession(Session session) async {
    String patientId = session.patient.id;
    String therapistId = session.therapist.id;
    try {
      QuerySnapshot assignmentQuery = await FirebaseFirestore.instance
          .collection('Assignments')
          .where('patient_id', isEqualTo: patientId)
          .where('therapist_id', isEqualTo: therapistId)
          .get();

      //add session
      if (assignmentQuery.docs.isNotEmpty) {
        String assignmentId = assignmentQuery.docs.first.id;

        await FirebaseFirestore.instance
            .collection('Assignments')
            .doc(assignmentId)
            .collection('ScheduledSessions')
            .add(session.toMap());
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
    return true;
  }
}
