import 'package:cloud_firestore/cloud_firestore.dart';
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
    final QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection(collectionName)
        .where(fieldName, isEqualTo: fieldValue)
        .limit(
            1) // Limit to 1 document to optimize query (we only need to know if any exists)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<List<Map<String, dynamic>>> getTherapistCardInfo(
      String patientUserId) async {
    List<Map<String, dynamic>> therapists = [];

    try {
      List<String> therapistUserIds =
          await _getTherapistIdsForPatient(patientUserId);
      for (String therapistUserId in therapistUserIds) {
        TheraportalUser therapist = await getUser(therapistUserId);
        String? groupName = await _getGroupName(therapist.groupId);
        DateTime? nextScheduledSession =
            await _getNextScheduledSession(therapistUserId, patientUserId);

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
    if (groupIdString == null) return null;
    DocumentSnapshot groupDoc =
        await _firestore.collection('Groups').doc(groupIdString).get();

    if (groupDoc.exists) {
      return groupDoc['name'] as String;
    } else {
      return null;
    }
  }

  Future<DateTime?> _getNextScheduledSession(
      String therapistUserId, String patientUserId) async {
    QuerySnapshot sessionsQuery = await _firestore
        .collection('Assignments')
        .where('patient_id', isEqualTo: patientUserId)
        .where('therapist_id', isEqualTo: therapistUserId)
        .limit(1)
        .get();

    if (sessionsQuery.docs.isNotEmpty) {
      String assignmentId = sessionsQuery.docs.first.id;
      QuerySnapshot scheduledSessionsQuery = await _firestore
          .collection('Assignments')
          .doc(assignmentId)
          .collection('ScheduledSessions')
          .orderBy('scheduled_for', descending: false)
          .limit(1)
          .get();

      if (scheduledSessionsQuery.docs.isNotEmpty) {
        return scheduledSessionsQuery.docs.first['scheduled_for'].toDate();
      }
    }

    return null;
  }

  Future<void> createAssignment(String patientId, String therapistId) async {
    try {
      DocumentReference assignmentRef =
          _firestore.collection('Assignments').doc();
      //set the data for the assignment document
      await assignmentRef.set({
        'patient_id': patientId,
        'therapist_id': therapistId,
      });

      //create empty subcollections
      await assignmentRef.collection('ExerciseAssignments').doc().set({});
      await assignmentRef.collection('ScheduledSessions').doc().set({});
    } catch (e) {
      print('Error adding assignment: $e');
      throw e; // Propagate the error if needed
    }
  }
}
