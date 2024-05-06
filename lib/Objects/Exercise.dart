import 'dart:typed_data';
import 'package:theraportal/Objects/TheraportalUser.dart';

class Exercise {
  String? id;
  final String bodyPart;
  final TheraportalUser creator;
  final DateTime dateCreated;
  final String name;
  final String exerciseDescription;
  final String? equipment;
  final String? fileName;
  final List<String>? secondaryMuscles;
  final String targetMuscle;
  final Uint8List? mediaContent; // GIFs/images/videos

  Exercise({
    this.id,
    required this.bodyPart,
    required this.creator,
    required this.dateCreated,
    required this.name,
    required this.exerciseDescription,
    this.equipment,
    this.fileName,
    this.secondaryMuscles,
    required this.targetMuscle,
    this.mediaContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body_part': bodyPart,
      'creator': creator.id,
      'date_created': dateCreated,
      'default_instructions': exerciseDescription,
      'equipment': equipment,
      'file_name': fileName,
      'name': name,
      'secondary_muscles': secondaryMuscles,
      'target_muscle': targetMuscle,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map, TheraportalUser creator) {
    return Exercise(
      id: map['id'],
      bodyPart: map['body_part'],
      creator: creator,
      dateCreated: map['date_created'],
      exerciseDescription: map['default_instructions'],
      equipment: map['equipment'],
      fileName: map['file_name'],
      name: map['name'],
      secondaryMuscles: map['secondary_muscles'] != null
          ? List<String>.from(map['secondary_muscles'])
          : null,
      targetMuscle: map['target_muscle'],
    );
  }
}
