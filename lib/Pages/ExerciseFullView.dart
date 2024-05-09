import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';

class ExerciseFullView extends StatelessWidget {
  final Exercise exercise;
  final String? instructions;
  final TheraportalUser? therapist;
  final TheraportalUser? patient;

  const ExerciseFullView({
    super.key,
    required this.exercise,
    this.instructions,
    this.therapist,
    this.patient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (instructions != null) ...[
              const Text(
                'Therapist\'s Instructions:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(instructions!),
              const SizedBox(height: 16),
            ],
            const Text(
              'Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(exercise.exerciseDescription),
            const SizedBox(height: 16),
            const Text(
              'Body Part:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(exercise.bodyPart),
            const SizedBox(height: 16),
            const Text(
              'Target Muscle:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(exercise.targetMuscle),
            const SizedBox(height: 16),
            if (exercise.equipment != null) ...[
              const Text(
                'Equipment:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(exercise.equipment!),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
