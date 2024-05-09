import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/ExerciseFullView.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final TheraportalUser? therapist;
  final TheraportalUser? patient;
  final String? instructions;
  final DateTime? dateAssigned;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.therapist,
    this.patient,
    this.instructions,
    this.dateAssigned,
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
              fontSize: 18, // Increased font size
              color: Colors.black, // Set text color to black
            ),
            children: [
              TextSpan(text: exercise.name),
            ],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (instructions != null) ...[
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style.copyWith(
                        fontSize: 15, // Increased font size
                        color: Colors.black, // Set text color to black
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
                      fontSize: 16, // Increased font size
                      color: Colors.black, // Set text color to black
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
                      fontSize: 16, // Increased font size
                      color: Colors.black, // Set text color to black
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
                      fontSize: 16, // Increased font size
                      color: Colors.black, // Set text color to black
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
                        fontSize: 16, // Increased font size
                        color: Colors.black, // Set text color to black
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
                        fontSize: 16, // Increased font size
                        color: Colors.black, // Set text color to black
                      ),
                  children: <TextSpan>[
                    const TextSpan(
                      text: 'Date Assigned: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: dateAssigned.toString()),
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
              ),
            ),
          );
        },
      ),
    );
  }
}
