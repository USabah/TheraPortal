import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Pages/ExerciseAssignmentsView.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class TherapistProfileCard extends StatelessWidget {
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final String? organization;
  final Session? nextScheduledSession;
  final String therapistId;
  final List<ExerciseAssignment> exerciseAssignments;

  const TherapistProfileCard({
    super.key,
    required this.therapistId,
    this.organization,
    this.nextScheduledSession,
    required this.patient,
    required this.therapist,
    required this.exerciseAssignments,
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
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Therapist Type: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '${therapist.therapistType}',
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Organization: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: organization ?? "None",
                  ),
                ],
              ),
            ),
            Text.rich(
              TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(
                    text: 'Next Session: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: nextScheduledSession != null
                        ? DateFormat('EEEE \'at\' h:mma \'(\'M/d/yy\')\'')
                            .format(nextScheduledSession!.getSessionStartTime())
                        : "Not Scheduled",
                  ),
                ],
              ),
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
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExerciseAssignmentsView(
                          exerciseAssignments: exerciseAssignments,
                          isTherapist: false,
                          updateExerciseAssignments: null,
                          otherUser: therapist,
                        )));
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
