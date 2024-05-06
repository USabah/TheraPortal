import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';

class ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final String? therapistInstructions;

  const ExerciseCard({
    required this.exercise,
    this.therapistInstructions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Body Part: ${exercise.bodyPart}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Target Muscle: ${exercise.targetMuscle}',
              style: const TextStyle(fontSize: 16),
            ),
            if (therapistInstructions != null) ...[
              const SizedBox(height: 8),
              Text(
                'Therapist Instructions: $therapistInstructions',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
