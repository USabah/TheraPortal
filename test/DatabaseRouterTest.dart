import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

Future<void> runDatabaseTests() async {
  final firestore = FakeFirebaseFirestore();
  DatabaseRouter databaseRouter = DatabaseRouter(firestore: firestore);
  const userId = 'some-user-id';
  final userData = {
    'userId': userId,
    'email': 'test@example.com',
    'first_name': 'Test',
    'last_name': 'User',
    // 'org_reference_code': 'some-group-id',
    'user_type': UserType.Patient,
    'date_created': Timestamp.now(),
    'user_reference_code': 'some-reference-code',
  };
  test('createUser should return an identifier', () async {
    TheraportalUser user = TheraportalUser.fromMap(userData);
    String id = await databaseRouter.addUser(user);
    expect(id, isA<String>());
  });
  test('getUser should return a TheraportalUser', () async {
    final user = await databaseRouter.getUser(userId);
    expect(user, isA<TheraportalUser>());
  });
}
