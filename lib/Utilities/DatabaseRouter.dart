import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';

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
          doc.data() as Map<String, dynamic>, patient, therapist, doc.id);
    }).toList();
  }

  Future<String?> addSession(Session session) async {
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

        DocumentReference sessionRef = await FirebaseFirestore.instance
            .collection('Assignments')
            .doc(assignmentId)
            .collection('ScheduledSessions')
            .add(session.toMap());

        // Return the document ID of the added session
        return sessionRef.id;
      } else {
        return null;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> updateSession(Session session) async {
    try {
      String patientId = session.patient.id;
      String therapistId = session.therapist.id;
      QuerySnapshot assignmentQuery = await FirebaseFirestore.instance
          .collection('Assignments')
          .where('patient_id', isEqualTo: patientId)
          .where('therapist_id', isEqualTo: therapistId)
          .get();
      //check if assignment exists
      if (assignmentQuery.docs.isNotEmpty) {
        String assignmentId = assignmentQuery.docs.first.id;
        DocumentSnapshot sessionSnapshot = await FirebaseFirestore.instance
            .collection('Assignments')
            .doc(assignmentId)
            .collection('ScheduledSessions')
            .doc(session.id) // Query directly by the document ID
            .get();
        if (sessionSnapshot.exists) {
          //update the session document with new data
          await sessionSnapshot.reference.update(session.toMap());
          return true;
        } else {
          print("session doesn't exist");
          return false;
        }
      } else {
        print("assignment doesn't exist");
        return false;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> removeSession(Session session) async {
    try {
      String patientId = session.patient.id;
      String therapistId = session.therapist.id;
      QuerySnapshot assignmentQuery = await FirebaseFirestore.instance
          .collection('Assignments')
          .where('patient_id', isEqualTo: patientId)
          .where('therapist_id', isEqualTo: therapistId)
          .get();

      //check if assignment exists
      if (assignmentQuery.docs.isNotEmpty) {
        String assignmentId = assignmentQuery.docs.first.id;
        DocumentReference sessionRef = FirebaseFirestore.instance
            .collection('Assignments')
            .doc(assignmentId)
            .collection('ScheduledSessions')
            .doc(session.id);

        DocumentSnapshot sessionSnapshot = await sessionRef.get();
        if (sessionSnapshot.exists) {
          //remove session
          await sessionRef.delete();
          return true;
        } else {
          print("Session doesn't exist");
          return false;
        }
      } else {
        print("Assignment doesn't exist");
        return false;
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<String?> addExercise(Exercise newExercise) async {
    try {
      CollectionReference exerciseRef = _firestore.collection('Exercises');
      DocumentReference docRef = await exerciseRef.add(newExercise.toMap());
      await docRef.update({'id': docRef.id});
      return docRef.id;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<List<Exercise>> getUserExercises(TheraportalUser user) async {
    List<Exercise> exercises = [];
    if (user.userType == UserType.Therapist) {
      QuerySnapshot nullCreatorIdSnapshot = await FirebaseFirestore.instance
          .collection('Exercises')
          .where('creator_id', isNull: true)
          .get();

      QuerySnapshot userCreatorIdSnapshot = await FirebaseFirestore.instance
          .collection('Exercises')
          .where('creator_id', isEqualTo: user.id)
          .get();

      List<QueryDocumentSnapshot> combinedSnapshots = [];
      combinedSnapshots.addAll(nullCreatorIdSnapshot.docs);
      combinedSnapshots.addAll(userCreatorIdSnapshot.docs);

      List<String?> creatorIds = combinedSnapshots
          .map((exerciseDoc) => exerciseDoc.get('creator_id') as String?)
          .where((creatorId) => creatorId != null)
          .toList();

      Map<String, TheraportalUser> creators = await fetchUsersByIds(creatorIds);

      exercises.addAll(combinedSnapshots.map((exerciseDoc) {
        Map<String, dynamic> data = exerciseDoc.data() as Map<String, dynamic>;
        String? creatorId = data['creator_id'];
        TheraportalUser? creator;
        if (creatorId != null) {
          creator = creators[creatorId];
        }
        data['id'] = exerciseDoc.id;
        return Exercise.fromMap(map: data, creator: creator);
      }));
    }

    return exercises;
  }

  Future<Map<String, List<ExerciseAssignment>>> getUserExerciseAssignments(
      TheraportalUser currentUser) async {
    Map<String, List<ExerciseAssignment>> userExerciseAssignments = {};

    CollectionReference assignmentsRef =
        currentUser.userType == UserType.Patient
            ? FirebaseFirestore.instance.collection('Assignments')
            : FirebaseFirestore.instance.collection('Assignments');

    bool isPatient = currentUser.userType == UserType.Patient;
    String fieldName = (isPatient) ? 'patient_id' : 'therapist_id';
    QuerySnapshot assignmentsSnapshot =
        await assignmentsRef.where(fieldName, isEqualTo: currentUser.id).get();

    for (QueryDocumentSnapshot assignmentDoc in assignmentsSnapshot.docs) {
      //get the other ID (depending on user type)
      String otherId = (isPatient)
          ? assignmentDoc.get('therapist_id')
          : assignmentDoc.get('patient_id');
      TheraportalUser otherUser = await getUser(otherId);
      //initialize the list for the other ID if it doesn't exist
      userExerciseAssignments.putIfAbsent(otherId, () => []);

      CollectionReference exerciseAssignmentsRef =
          assignmentDoc.reference.collection('ExerciseAssignments');
      QuerySnapshot exerciseAssignmentsSnapshot =
          await exerciseAssignmentsRef.get();

      for (QueryDocumentSnapshot exerciseAssignmentDoc
          in exerciseAssignmentsSnapshot.docs) {
        //convert the document data to ExerciseAssignment object
        Map<String, dynamic> map =
            exerciseAssignmentDoc.data() as Map<String, dynamic>;
        String exerciseId = map["exercise_id"];
        Exercise exercise = await getExerciseById(exerciseId);
        ExerciseAssignment exerciseAssignment = ExerciseAssignment.fromMap(
            map: map,
            exercise: exercise,
            patient: (isPatient) ? currentUser : otherUser,
            therapist: (isPatient) ? otherUser : currentUser);

        //add the exercise assignment to the list under the other ID
        userExerciseAssignments[otherId]!.add(exerciseAssignment);
      }
    }

    return userExerciseAssignments;
  }

  Future<Map<String, TheraportalUser>> fetchUsersByIds(
      List<String?> userIds) async {
    Map<String, TheraportalUser> users = {};
    for (String? userId in userIds) {
      if (userId != null) {
        TheraportalUser user = await getUser(userId);
        users[userId] = user;
      }
    }
    return users;
  }

  Future<Exercise> getExerciseById(String exercise_id) async {
    try {
      DocumentReference exerciseDocRef =
          FirebaseFirestore.instance.collection('Exercises').doc(exercise_id);
      DocumentSnapshot exerciseDocSnapshot = await exerciseDocRef.get();

      //check if the document exists
      if (exerciseDocSnapshot.exists) {
        Map<String, dynamic> map =
            exerciseDocSnapshot.data() as Map<String, dynamic>;
        TheraportalUser? creator;
        if (map["creator_id"] != null) {
          creator = map["creator_id"];
        }
        Exercise exercise = Exercise.fromMap(
          map: map,
          creator: creator,
        );
        return exercise;
      } else {
        throw Exception('Exercise with ID $exercise_id not found.');
      }
    } catch (e) {
      print('Error fetching exercise: $e');
      rethrow;
    }
  }

  Future<bool> addExerciseAssignment(
      ExerciseAssignment exerciseAssignment) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Assignments')
          .where('patient_id', isEqualTo: exerciseAssignment.patient.id)
          .where('therapist_id', isEqualTo: exerciseAssignment.therapist.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference exerciseDocRef = querySnapshot.docs.first.reference;
        await exerciseDocRef.collection('ExerciseAssignments').add(
              exerciseAssignment.toMap(),
            );
      } else {
        //document doesn't exist
        return false;
      }
      return true;
    } catch (e) {
      print('Error adding exercise assignment: $e');
      return false;
    }
  }

  Future<bool> removeExerciseAssignment(
      String exerciseId, String patientId, String therapistId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Assignments')
          .where('patient_id', isEqualTo: patientId)
          .where('therapist_id', isEqualTo: therapistId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference assignmentDocRef = querySnapshot.docs.first.reference;
        QuerySnapshot<Map<String, dynamic>> exerciseAssignmentQuerySnapshot =
            await assignmentDocRef
                .collection('ExerciseAssignments')
                .where('exercise_id', isEqualTo: exerciseId)
                .get();

        if (exerciseAssignmentQuerySnapshot.docs.isNotEmpty) {
          //remove the exercise assignment document
          await exerciseAssignmentQuerySnapshot.docs.first.reference.delete();
          return true;
        } else {
          //exercise assignment document not found
          return false;
        }
      } else {
        //assignment document not found
        return false;
      }
    } catch (e) {
      print('Error removing exercise assignment: $e');
      return false;
    }
  }
}
