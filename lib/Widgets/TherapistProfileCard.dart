import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class TherapistProfileCard extends StatelessWidget {
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final String? organization;
  final Session? nextScheduledSession;
  final String therapistId;

  const TherapistProfileCard({
    super.key,
    required this.therapistId,
    this.organization,
    this.nextScheduledSession,
    required this.patient,
    required this.therapist,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 255, 184, 180),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          Icons.medical_services,
          size: MediaQuery.of(context).size.height * 0.06,
        ),
        title: Text(
          therapist.fullNameDisplay(true),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Therapist Type: ${therapist.therapistType}',
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
          color: Styles.lightGrey,
          icon: const Icon(Icons.more_vert),
          onSelected: (String value) {
            switch (value) {
              case 'View Messages':
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CommunicationPage(
                        withUserId: therapistId,
                        name: therapist.fullNameDisplay(true))));
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
