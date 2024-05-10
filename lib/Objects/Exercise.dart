import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';

class Exercise {
  String? id;
  final String bodyPart;
  final TheraportalUser? creator;
  final DateTime dateCreated;
  final String name;
  final String exerciseDescription;
  final String? equipment;
  final String? fileName;
  final List<String>? secondaryMuscles;
  final String targetMuscle;
  Uint8List? mediaContent; // GIFs/images/videos

  Exercise({
    this.id,
    required String bodyPart,
    required this.creator,
    required this.dateCreated,
    required String name,
    required this.exerciseDescription,
    String? equipment,
    this.fileName,
    List<String>? secondaryMuscles,
    required String targetMuscle,
    this.mediaContent,
  })  : bodyPart = _capitalizeWords(bodyPart),
        name = _capitalizeWords(name),
        equipment = equipment != null ? _capitalizeWords(equipment) : null,
        targetMuscle = _capitalizeWords(targetMuscle),
        secondaryMuscles = _capitalizeSecondaryMuscles(secondaryMuscles);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'body_part': bodyPart,
      'creator_id': creator?.id,
      'date_created': dateCreated,
      'default_instructions': exerciseDescription,
      'equipment': equipment,
      'file_name': fileName,
      'name': name,
      'secondary_muscles': secondaryMuscles,
      'target_muscle': targetMuscle,
    };
  }

  factory Exercise.fromMap(
      {required Map<String, dynamic> map, required TheraportalUser? creator}) {
    return Exercise(
      id: map['id'],
      bodyPart: map['body_part'],
      creator: creator,
      dateCreated: (map['date_created'] as Timestamp).toDate(),
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

  static String _capitalizeWords(String text) {
    return text.toLowerCase().split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  static List<String>? _capitalizeSecondaryMuscles(List<String>? muscles) {
    if (muscles == null) return null;
    return muscles.map((muscle) => _capitalizeWords(muscle)).toList();
  }
}
