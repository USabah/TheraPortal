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
      print(e);
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

  Future<TheraportalUser?> getUserFromFirestore(String userId) async {
    DocumentReference userRef = _firestore.collection('Users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data() as Map<String, dynamic>;
      return TheraportalUser.fromMap(userData);
    } else {
      return null;
    }
  }

  //check if a field exists
  Future<bool> fieldExists(
      String collectionPath, String fieldToCheck, dynamic value) async {
    CollectionReference collectionRef = _firestore.collection(collectionPath);

    QuerySnapshot querySnapshot =
        await collectionRef.where(fieldToCheck, isEqualTo: value).get();

    return querySnapshot.docs.isNotEmpty;
  }
}
