import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/ExerciseFullView.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final TheraportalUser therapist;
  final TheraportalUser patient;
  final String? instructions;
  final DateTime? dateAssigned;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment})? updateExerciseAssignments;
  final bool isCreationView;
  final bool isTherapist;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.therapist,
    required this.patient,
    this.instructions,
    this.dateAssigned,
    required this.updateExerciseAssignments,
    required this.isCreationView,
    required this.isTherapist,
  });

  @override
  Widget build(BuildContext context) {
    const int descCutoffValue = 100;
    String description = exercise.exerciseDescription;
    if (description.length > descCutoffValue) {
      int lastSpaceIndex = description.lastIndexOf(' ', descCutoffValue - 1);
      if (lastSpaceIndex != -1) {
        description = '${description.substring(0, lastSpaceIndex)}...';
      } else {
        description = '${description.substring(0, descCutoffValue)}...';
      }
    }

    return Card(
      color: const Color.fromARGB(255, 235, 227, 190),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: RichText(
          text: TextSpan(
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
            children: [
              TextSpan(text: exercise.name),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (instructions != null && instructions!.trim() != "") ...[
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Therapist\'s Instructions: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: instructions),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Description: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Body Part: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: exercise.bodyPart),
                ],
              ),
            ),
            RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                children: <TextSpan>[
                  const TextSpan(
                    text: 'Target Muscle: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: exercise.targetMuscle),
                ],
              ),
            ),
            if (exercise.equipment != null) ...[
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Equipment: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: exercise.equipment),
                  ],
                ),
              ),
            ],
            if (dateAssigned != null) ...[
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Date Assigned: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: DateFormat('MM/dd/yyyy \'at\' hh:mm a')
                          .format(dateAssigned!),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseFullView(
                exercise: exercise,
                instructions: instructions,
                therapist: therapist,
                patient: patient,
                updateExerciseAssignments: updateExerciseAssignments,
                isCreationView: isCreationView,
                isTherapist: isTherapist,
              ),
            ),
          );
        },
      ),
    );
  }
}
