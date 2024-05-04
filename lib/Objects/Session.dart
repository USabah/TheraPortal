import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:flutter/material.dart';

class Session {
  final TheraportalUser patient;
  final TheraportalUser therapist;
  final DateTime? dateTime;
  final DayOfWeek dayOfWeek;
  final TimeOfDay timeOfDay;
  final String? additionalInfo;
  final bool isWeekly;
  final int durationInMinutes;

  Session({
    required this.patient,
    required this.therapist,
    required this.isWeekly,
    required this.dateTime,
    required this.durationInMinutes,
    this.additionalInfo,
  })  : dayOfWeek = getDayOfWeek(dateTime!.weekday),
        timeOfDay = TimeOfDay.fromDateTime(dateTime);

  Session.weekly({
    required this.patient,
    required this.therapist,
    required this.isWeekly,
    required this.dayOfWeek,
    required this.timeOfDay,
    required this.durationInMinutes, //default duration 30 minutes
    this.additionalInfo,
  }) : dateTime = null;

  DateTime getSessionStartTime() {
    if (isWeekly) {
      final currentDayOfWeek = DateTime.now().weekday;
      final daysUntilNextSession = (dayOfWeek.index - currentDayOfWeek + 7) % 7;
      final nextSessionDate =
          DateTime.now().add(Duration(days: daysUntilNextSession));
      //combine the next session date with the time of the session
      return DateTime(
        nextSessionDate.year,
        nextSessionDate.month,
        nextSessionDate.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    } else {
      return dateTime!;
    }
  }

  DateTime getSessionEndTime() {
    return getSessionStartTime().add(Duration(minutes: durationInMinutes));
  }

  static bool isDuringSession(
      Session sessionToSchedule, Session sessionToCheck) {
    DateTime scheduleStartTime = sessionToSchedule.getSessionStartTime();
    DateTime scheduleEndTime = sessionToSchedule.getSessionEndTime();
    DateTime checkStartTime = sessionToCheck.getSessionStartTime();
    DateTime checkEndTime = sessionToCheck.getSessionEndTime();

    //check if sessionToCheck's end time is equal to sessionToSchedule's start time
    if (checkEndTime.isAtSameMomentAs(scheduleStartTime) ||
        scheduleEndTime.isAtSameMomentAs(checkStartTime)) {
      return false;
    }
    //check if sessionToCheck starts during sessionToSchedule
    if (checkStartTime.isAfter(scheduleStartTime) &&
        checkStartTime.isBefore(scheduleEndTime)) {
      return true;
    }
    //check if sessionToCheck ends during sessionToSchedule
    if (checkEndTime.isAfter(scheduleStartTime) &&
        checkEndTime.isBefore(scheduleEndTime)) {
      return true;
    }
    //check if sessionToCheck completely contains sessionToSchedule
    if (checkStartTime.isBefore(scheduleStartTime) &&
        checkEndTime.isAfter(scheduleEndTime)) {
      return true;
    }
    //check if sessionToCheck completely contained within sessionToSchedule
    if (scheduleStartTime.isBefore(checkStartTime) &&
        scheduleEndTime.isAfter(checkEndTime)) {
      return true;
    }
    //no overlap
    return false;
  }

  static void sortSessions(List<Session> sessions) {
    sessions.sort(
        (a, b) => a.getSessionStartTime().compareTo(b.getSessionStartTime()));
  }

  static Session fromMap(Map<String, dynamic> map, TheraportalUser patient,
      TheraportalUser therapist) {
    if (map['is_weekly']) {
      return Session.weekly(
          patient: patient,
          therapist: therapist,
          isWeekly: true,
          dayOfWeek: map['day_of_week'],
          timeOfDay: map['time_of_day'],
          additionalInfo: map['additional_info'],
          durationInMinutes: map['duration_in_minutes']);
    } else {
      return Session(
        patient: patient,
        therapist: therapist,
        dateTime: (map['scheduled_for'] as Timestamp).toDate(),
        additionalInfo: map['additional_info'],
        isWeekly: map['is_weekly'],
        durationInMinutes: map['duration_in_minutes'],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduled_for': dateTime,
      'day_of_week': dayOfWeek.toString(),
      'time_of_day': timeOfDay.toString(),
      'additional_info': additionalInfo,
      'is_weekly': isWeekly,
      'duration_in_minutes': durationInMinutes,
    };
  }

  static bool isCurrentDayOrLater(DateTime selectedDay) {
    final now = DateTime.now().toLocal();
    final selectedDayLocal = selectedDay.toLocal();
    return selectedDayLocal.compareTo(now) >= 0 ||
        isSameDay(selectedDayLocal, now) ||
        isSameDay(selectedDay, now);
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
