import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:flutter/material.dart';

class Session {
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final DateTime dateTime;
  final DayOfWeek? dayOfWeek;
  final TimeOfDay? timeOfDay;
  final String? additionalInfo;
  final bool isWeekly;

  Session({
    required this.patient,
    required this.therapist,
    required this.dateTime,
    this.additionalInfo,
    required this.isWeekly,
  })  : dayOfWeek = getDayOfWeek(dateTime.weekday),
        timeOfDay = TimeOfDay.fromDateTime(dateTime);

  Map<String, dynamic> toMap() {
    return {
      'scheduled_for': dateTime,
      'day_of_week': dayOfWeek?.toString(),
      'time_of_day': timeOfDay?.toString(),
      'additional_info': additionalInfo,
      'is_weekly': isWeekly,
    };
  }

  static Session fromMap(Map<String, dynamic> map) {
    return Session(
      patient: TheraportalUser.fromMap(map['patient']),
      therapist: TheraportalUser.fromMap(map['therapist']),
      dateTime: (map['scheduled_for'] as Timestamp).toDate(),
      additionalInfo: map['additional_info'],
      isWeekly: map['is_weekly'],
    );
  }

  static DayOfWeek getDayOfWeek(int day) {
    switch (day) {
      case DateTime.sunday:
        return DayOfWeek.Sunday;
      case DateTime.monday:
        return DayOfWeek.Monday;
      case DateTime.tuesday:
        return DayOfWeek.Tuesday;
      case DateTime.wednesday:
        return DayOfWeek.Wednesday;
      case DateTime.thursday:
        return DayOfWeek.Thursday;
      case DateTime.friday:
        return DayOfWeek.Friday;
      case DateTime.saturday:
        return DayOfWeek.Saturday;
      default:
        throw Exception('Invalid day of week');
    }
  }
}

enum DayOfWeek {
  Sunday,
  Monday,
  Tuesday,
  Wednesday,
  Thursday,
  Friday,
  Saturday;

  @override
  String toString() => name;
}
