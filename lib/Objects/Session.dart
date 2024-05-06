import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
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
  String? id;

  Session(
      {required this.patient,
      required this.therapist,
      required this.isWeekly,
      required this.dateTime,
      required this.durationInMinutes,
      this.additionalInfo,
      this.id})
      : dayOfWeek = getDayOfWeek(dateTime!.weekday),
        timeOfDay = TimeOfDay.fromDateTime(dateTime);

  Session.weekly(
      {required this.patient,
      required this.therapist,
      required this.isWeekly,
      required this.dayOfWeek,
      required this.timeOfDay,
      required this.durationInMinutes, //default duration 30 minutes
      this.additionalInfo,
      this.id})
      : dateTime = null;

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
    //check if sessions begin at the same time
    if (scheduleStartTime.isAtSameMomentAs(checkStartTime)) {
      return true;
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

    ///if the session is rescheduled weekly, we need an additional check here for day and time lining up
    //no overlap
    return false;
  }

  static void sortSessions(List<Session> sessions) {
    sessions.sort(
        (a, b) => a.getSessionStartTime().compareTo(b.getSessionStartTime()));
  }

  static Session fromMap(Map<String, dynamic> map, TheraportalUser patient,
      TheraportalUser therapist, String docId) {
    if (map['is_weekly']) {
      return Session.weekly(
          patient: patient,
          therapist: therapist,
          isWeekly: true,
          dayOfWeek: DayOfWeek.fromString(map['day_of_week'])!,
          timeOfDay: Session.parseTimeOfDay(map['time_of_day']!),
          additionalInfo: map['additional_info'],
          durationInMinutes: map['duration_in_minutes'],
          id: docId);
    } else {
      return Session(
          patient: patient,
          therapist: therapist,
          dateTime: (map['scheduled_for'] as Timestamp).toDate(),
          additionalInfo: map['additional_info'],
          isWeekly: map['is_weekly'],
          durationInMinutes: map['duration_in_minutes'],
          id: docId);
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

  static TimeOfDay parseTimeOfDay(String timeString) {
    //remove the "TimeOfDay(" and ")" parts from the string
    String time = timeString.replaceAll('TimeOfDay(', '').replaceAll(')', '');
    //split the string into hours and minutes
    List<String> parts = time.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static bool isCurrentDayOrLater(DateTime selectedDay) {
    final now = DateTime.now().toLocal();
    final selectedDayLocal = selectedDay.toLocal();
    return selectedDayLocal.compareTo(now) >= 0 ||
        isSameDay(selectedDayLocal, now) ||
        isSameDay(selectedDay, now);
  }

  //get the next upcoming session for a patient and therapist
  static Session? getNextSession(
      List<Session> sessions, String patientId, String therapistId) {
    DateTime now = DateTime.now();
    for (int i = 0; i < sessions.length; i++) {
      Session session = sessions[i];
      if (session.getSessionStartTime().isAfter(now) &&
          session.patient.id == patientId &&
          session.therapist.id == therapistId) {
        return session;
      }
    }
    //if no upcoming session is found, return null
    return null;
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

  static void removeOldSessions(List<Session> userSessions) {
    userSessions.removeWhere(
        (session) => !isCurrentDayOrLater(session.getSessionStartTime()));
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

  static DayOfWeek? fromString(String a) {
    return {
      "Sunday": Sunday,
      "Monday": Monday,
      "Tuesday": Tuesday,
      "Wednesday": Wednesday,
      "Thursday": Thursday,
      "Friday": Friday,
      "Saturday": Saturday
    }[a];
  }
}
