import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Objects/User.dart';

class DatabaseRouter {
  //check if a field exists
  Future<bool> fieldExists(
      String collectionPath, String fieldToCheck, dynamic value) async {
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection(collectionPath);

    QuerySnapshot querySnapshot =
        await collectionRef.where(fieldToCheck, isEqualTo: value).get();

    return querySnapshot.docs.isNotEmpty;
  }

  //add a user to the database
  Future<void> addUser(TheraportalUser user) async {
    CollectionReference usersRef =
        FirebaseFirestore.instance.collection('Users');
    await usersRef.doc(user.id).set(user.toMap());
  }

  Future<TheraportalUser?> getUserFromFirestore(String userId) async {
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('Users').doc(userId);
    DocumentSnapshot userSnapshot = await userRef.get();
    if (userSnapshot.exists) {
      //cast the data to a map and convert to a User
      Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      TheraportalUser user = TheraportalUser.fromMap(userData);
      return user;
    } else {
      return null;
    }
  }
}
