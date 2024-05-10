import 'package:flutter/material.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Widgets/ExerciseCard.dart';

class ExerciseAssignmentsView extends StatelessWidget {
  final List<ExerciseAssignment> exerciseAssignments;
  final bool isTherapist;
  final TheraportalUser otherUser;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment})? updateExerciseAssignments;

  const ExerciseAssignmentsView({
    super.key,
    required this.exerciseAssignments,
    required this.isTherapist,
    this.updateExerciseAssignments,
    required this.otherUser,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text((isTherapist)
            ? "${otherUser.fullNameDisplay(false)} Assigned Exercises"
            : "Exercises Assigned by ${otherUser.fullNameDisplay(true)}"),
      ),
      body: ListView.builder(
        itemCount: exerciseAssignments.length,
        itemBuilder: (context, index) {
          final assignment = exerciseAssignments[index];
          return ExerciseCard(
            exercise: assignment.exercise,
            therapist: assignment.therapist,
            patient: assignment.patient,
            instructions: assignment.instructions,
            dateAssigned: assignment.dateCreated,
            updateExerciseAssignments: updateExerciseAssignments,
            isCreationView: false,
            isTherapist: isTherapist,
          );
        },
      ),
    );
  }
}
