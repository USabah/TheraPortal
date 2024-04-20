import 'package:flutter/material.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class PatientProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String? organization;
  final DateTime? nextScheduledSession;
  final String dateOfBirth;

  PatientProfileCard({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.organization,
    this.nextScheduledSession,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          Icons.person,
          size: MediaQuery.of(context).size.height * 0.06,
        ),
        title: Text('$firstName $lastName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date of Birth: $dateOfBirth'),
            Text('Organization: ${organization ?? "None"}'),
            Text(
              'Next Scheduled Session: ${nextScheduledSession != null ? nextScheduledSession!.toString() : "None"}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          color: Styles.lightGrey,
          onSelected: (String value) {
            switch (value) {
              case 'Send Message':
                print('Send Message selected');
                // Add logic to handle sending message
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
              value: 'Send Message',
              child: Text('Send Message'),
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
