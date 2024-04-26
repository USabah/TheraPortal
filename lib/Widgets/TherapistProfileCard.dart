import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class TherapistProfileCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String therapistType;
  final String? organization;
  final DateTime? nextScheduledSession;
  final String therapistId;

  const TherapistProfileCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.therapistType,
    required this.therapistId,
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
        title: Text('$firstName ${lastName[0]}.'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Therapist Type: $therapistType'),
            Text('Organization: ${organization ?? "None"}'),
            Text(
              'Next Session: ${nextScheduledSession != null ? DateFormat('EEEE \'at\' h:mma \'(\'M/d/yy\')\'').format(nextScheduledSession!) : "Not Scheduled"}',
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: Styles.lightGrey,
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {
            switch (value) {
              case 'View Messages':
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommunicationPage(
                        withUserId: therapistId,
                        name: '$firstName ${lastName[0]}.')));
                break;
              case 'View Assigned Exercises':
                print('View Assigned Exercises');
                // Add logic to handle adding note
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
          ],
        ),
      ),
    );
  }
}
