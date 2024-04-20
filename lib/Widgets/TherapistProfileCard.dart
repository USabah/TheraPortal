import 'package:flutter/material.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class TherapistProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String therapistType;
  final String? organization;
  final DateTime? nextScheduledSession;

  TherapistProfileCard({
    required this.firstName,
    required this.lastName,
    required this.therapistType,
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
          Icons.medical_services,
          size: MediaQuery.of(context).size.height * 0.06,
        ),
        title: Text('$firstName $lastName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Therapist Type: $therapistType'),
            Text('Organization: ${organization ?? "None"}'),
            Text(
              'Next Scheduled Session: ${nextScheduledSession != null ? nextScheduledSession!.toString() : "None"}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: Styles.lightGrey,
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {
            switch (value) {
              case 'Send Message':
                print('Send Message selected');
                // Add logic to handle sending message
                break;
              case 'View Assigned Exercises':
                print('View Assigned Exercises');
                // Add logic to handle adding note
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
          ],
        ),
      ),
    );
  }
}
