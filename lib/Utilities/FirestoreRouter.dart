import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRouter {
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
    var chatReference = await FirebaseFirestore.instance
        .collection('Communications')
        .where('concatenated_ids', isEqualTo: concat_ids)
        .snapshots()
        .first;
    DocumentReference docRef = chatReference.docs.first.reference;
    return docRef.collection('Messages');
  }

  //Helper function to concatenate user IDs into a single string
  String _concatenateIds(String user1Id, String user2Id) {
    List<String> sortedIds = [user1Id, user2Id]..sort();
    return sortedIds.join('_');
  }

  void testFireStore(String user1Id, String user2Id) {
    var concat_ids = _concatenateIds(user1Id, user2Id);
    FirebaseFirestore.instance
        .collection('Communications')
        .where('concatenated_ids', isEqualTo: concat_ids)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        print(doc.reference.path); // Print document paths
      });
    });
  }
}
