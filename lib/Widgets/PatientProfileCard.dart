import 'package:flutter/material.dart';

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
        leading: Icon(
          Icons.person,
          size: MediaQuery.sizeOf(context).height * 0.06,
        ),
        title: Text('$firstName $lastName'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date of Birth: $dateOfBirth'),
            Text('Organization: ${organization ?? "None"}'),
            Text(
                'Next Scheduled Session: ${nextScheduledSession != null ? nextScheduledSession!.toString() : "None"}'),
          ],
        ),
      ),
    );
  }
}
