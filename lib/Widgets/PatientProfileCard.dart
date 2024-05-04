import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class PatientProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? organization;
  final Session? nextScheduledSession;
  final DateTime dateOfBirth;
  final String patientId;

  const PatientProfileCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.patientId,
    this.organization,
    this.nextScheduledSession,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromRGBO(151, 167, 231, 1),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          Icons.person,
          size: MediaQuery.of(context).size.height * 0.06,
        ),
        title: Text(
          '$firstName $lastName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth: ${DateFormat("MM/dd/yyyy").format(dateOfBirth)}',
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              'Organization: ${organization ?? "None"}',
              style: const TextStyle(color: Colors.black),
            ),
            Text(
              'Next Session: ${nextScheduledSession != null ? DateFormat('EEEE \'at\' h:mma \'(\'M/d/yy\')\'').format(nextScheduledSession!.getSessionStartTime()) : "Not Scheduled"}',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          color: Styles.lightGrey,
          onSelected: (String value) {
            switch (value) {
              case 'View Messages':
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommunicationPage(
                        withUserId: patientId, name: '$firstName $lastName')));
                break;
              case 'View Assigned Exercises':
                print('View Assigned Exercises selected');
                // Add logic to handle sending message
                break;
              case 'Add Exercise':
                print('Add Exercise selected');
                // Add logic to handle adding exercise
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'View Messages',
              child: Text('View Messages'),
            ),
            const PopupMenuItem<String>(
              value: 'View Assigned Exercises',
              child: Text('View Assigned Exercises'),
            ),
            const PopupMenuItem<String>(
              value: 'Add Exercise',
              child: Text('Add Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
