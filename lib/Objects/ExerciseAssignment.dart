import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ExerciseAssignment {
  final Exercise exercise;
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final DateTime dateCreated;
  final String? instructions;

  ExerciseAssignment({
    required this.exercise,
    required this.patient,
    required this.therapist,
    required this.dateCreated,
    this.instructions,
  });

  Map<String, dynamic> toMap() {
    return {
      'exercise_id': exercise.id,
      'patient_id': patient.id,
      'therapist_id': therapist.id,
      'dateCreated': Timestamp.fromDate(dateCreated),
      'instructions': instructions,
    };
  }

  factory ExerciseAssignment.fromMap(
    Map<String, dynamic> map,
    Exercise exercise,
    TheraportalUser patient,
    TheraportalUser therapist,
  ) {
    return ExerciseAssignment(
      exercise: exercise,
      patient: patient,
      therapist: therapist,
      dateCreated: (map['dateCreated'] as Timestamp).toDate(),
      instructions: map['instructions'],
    );
  }
}
