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
        // tileColor: Styles.babyBlue,
        leading: Icon(Icons.medical_services,
            size: MediaQuery.sizeOf(context).height * 0.06),
        title: Text('$firstName $lastName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Therapist Type: $therapistType'),
            Text('Organization: ${organization ?? "None"}'),
            Text(
                'Next Scheduled Session: ${nextScheduledSession != null ? nextScheduledSession!.toString() : "None"}'),
          ],
        ),
      ),
    );
  }
}
