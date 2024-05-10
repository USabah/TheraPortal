import 'package:flutter/material.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Widgets/ExerciseCard.dart';
import 'package:theraportal/Widgets/Styles.dart';

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
            ? "${otherUser.fullNameDisplay(false)}'s Assigned Exercises"
            : "Exercises Assigned by ${otherUser.fullNameDisplay(true)}"),
      ),
      body: (exerciseAssignments.isEmpty)
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: Text(
                (isTherapist)
                    ? "You haven't assigned any exercises for ${otherUser.fullNameDisplay(false)} at this time. You can assign from the home screen by clicking on the patient card's menu."
                    : "${otherUser.fullNameDisplay(true)} has not assigned any exercises for you yet.",
                style: const TextStyle(color: Styles.lightGrey),
                textAlign: TextAlign.center,
              )),
            )
          : ListView.builder(
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
