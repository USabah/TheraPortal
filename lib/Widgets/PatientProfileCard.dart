import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/CommunicationPage.dart';
import 'package:theraportal/Pages/ExerciseSelector.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class PatientProfileCard extends StatelessWidget {
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final Session? nextScheduledSession;
  final List<Exercise> exercises;
  final List<ExerciseAssignment> exerciseAssignments;
  final String? organization;

  const PatientProfileCard({
    super.key,
    this.nextScheduledSession,
    required this.exercises,
    required this.exerciseAssignments,
    required this.patient,
    required this.therapist,
    this.organization,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromARGB(255, 181, 190, 226),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        leading: Icon(
          Icons.person,
          size: MediaQuery.of(context).size.height * 0.06,
        ),
        title: Text(
          patient.fullNameDisplay(false),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date of Birth: ${DateFormat("MM/dd/yyyy").format(patient.dateOfBirth!.toDate())}',
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
                        withUserId: patient.id,
                        name: patient.fullNameDisplay(false))));
                break;
              case 'View Assigned Exercises':
                print('View Assigned Exercises selected');
                // Add logic to handle sending message
                break;
              case 'Assign Exercise':
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ExerciseSelector(
                        fullExerciseList: exercises,
                        patientExerciseAssignmentList: exerciseAssignments,
                        therapist: therapist,
                        patient: patient)));
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
              value: 'Assign Exercise',
              child: Text('Assign Exercise'),
            ),
          ],
        ),
      ),
    );
  }
}
