import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/ScheduleListPage.dart';
import 'package:theraportal/Pages/ScheduleSessionForm.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class CalendarTableView extends StatefulWidget {
  final List<Session> sessions;
  final TheraportalUser currentUser;
  final Function(List<Session>) onUpdateSessions;
  final List<Map<String, dynamic>> mapData;
  final Future<void> Function() refreshFunction;

  const CalendarTableView(
      {super.key,
      required this.sessions,
      required this.currentUser,
      required this.onUpdateSessions,
      required this.mapData,
      required this.refreshFunction});

  @override
  State<CalendarTableView> createState() => _CalendarTableViewState();
}

class _CalendarTableViewState extends State<CalendarTableView> {
  DateTime currentFocus = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        TableCalendar(
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              final hasSession = _hasSession(day);
              if (hasSession) {
                return Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
          calendarFormat: CalendarFormat.month,
          calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              )),
          availableCalendarFormats: const {CalendarFormat.month: ""},
          selectedDayPredicate: (day) {
            //selects the day
            return isSameDay(currentFocus, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              currentFocus = selectedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              currentFocus = focusedDay;
            });
          },
          focusedDay: currentFocus,
          firstDay: DateTime(2024),
          lastDay: DateTime(2025),
          daysOfWeekStyle: const DaysOfWeekStyle(
              weekdayStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              weekendStyle:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold
                      // color: Styles.lightGrey,
                      )),
          weekendDays: const [],
          holidayPredicate: _isUSHoliday,
          enabledDayPredicate: (day) {
            return Session.isCurrentDayOrLater(day);
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 14.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.42,
                child: ElevatedButton(
                  style: _hasSession(currentFocus)
                      ? const ButtonStyle()
                      : const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Color.fromARGB(138, 189, 189, 189))),
                  onPressed: _hasSession(currentFocus)
                      ? () {
                          List<Session> sessionDayList =
                              _sessionsOnDay(currentFocus);
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ScheduleListPage(
                                    sessions: sessionDayList,
                                    fullSessionList: false,
                                    daySelected: currentFocus,
                                    currentUser: widget.currentUser,
                                    refreshFunction: widget.refreshFunction,
                                    mapData: widget.mapData,
                                    onUpdateSessions: widget.onUpdateSessions,
                                  )));
                        }
                      : null,
                  child: Text('View Sessions',
                      style: _hasSession(currentFocus)
                          ? const TextStyle()
                          : const TextStyle(fontWeight: FontWeight.w300)),
                ),
              ),
              if (widget.currentUser.userType == UserType.Therapist) ...[
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.42,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      style: (Session.isCurrentDayOrLater(currentFocus))
                          ? const ButtonStyle()
                          : const ButtonStyle(
                              backgroundColor: MaterialStatePropertyAll(
                                  Color.fromARGB(138, 189, 189, 189))),
                      onPressed: (Session.isCurrentDayOrLater(currentFocus))
                          ? () async {
                              if (widget.mapData.isEmpty) {
                                alertFunction(
                                    context: context,
                                    title: "Cannot Schedule Session",
                                    content:
                                        "Your account does not have any patients assigned to it. You may add a patient to your account in the settings page above.",
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    btnText: "Close");
                              } else {
                                Session? session = await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (context) => ScheduleSessionForm(
                                    currentUser: widget.currentUser,
                                    day: currentFocus,
                                    sessionToEdit: null,
                                    mapData: widget.mapData,
                                    scheduledSessions: widget.sessions,
                                  ),
                                )) as Session?;
                                if (session != null) {
                                  widget.sessions.add(session);
                                  Session.sortSessions(widget.sessions);
                                  if (widget.sessions[0] == session) {
                                    //update mapData
                                  }
                                  widget.onUpdateSessions(widget.sessions);
                                }
                              }
                            }
                          : null,
                      child: Text('Schedule Session',
                          style: TextStyle(
                              fontSize: 12.4,
                              fontWeight:
                                  (Session.isCurrentDayOrLater(currentFocus))
                                      ? FontWeight.bold
                                      : FontWeight.w300)),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  bool _hasSession(DateTime day) {
    return widget.sessions
        .any((session) => isSameDay(session.getSessionStartTime(), day));
  }

  List<Session> _sessionsOnDay(DateTime day) {
    List<Session> sessionsOnDay = widget.sessions.where((session) {
      if (session.isWeekly && session.dateTime == null) {
        return session.dayOfWeek == Session.getDayOfWeek(day.weekday);
      } else {
        return isSameDay(session.dateTime!, day);
      }
    }).toList();
    //sort sessions
    Session.sortSessions(sessionsOnDay);
    return sessionsOnDay;
  }

  bool _isUSHoliday(DateTime date) {
    //New Year's Day (January 1)
    if (date.month == DateTime.january && date.day == 1) {
      return true;
    }

    //Martin Luther King Jr. Day (3rd Monday in January)
    if (date.month == DateTime.january &&
        date.weekday == DateTime.monday &&
        date.day > 14 &&
        date.day < 22) {
      return true;
    }

    //President's Day (3rd Monday in February)
    if (date.month == DateTime.february &&
        date.weekday == DateTime.monday &&
        date.day > 14 &&
        date.day < 22) {
      return true;
    }

    //Memorial Day (Last Monday in May)
    if (date.month == DateTime.may &&
        date.weekday == DateTime.monday &&
        date.day > 24 &&
        date.day < 32) {
      return true;
    }

    //Juneteenth National Independence Day (June 19)
    if (date.month == DateTime.june && date.day == 19) {
      return true;
    }

    //Independence Day (July 4)
    if (date.month == DateTime.july && date.day == 4) {
      return true;
    }

    //Labor Day (1st Monday in September)
    if (date.month == DateTime.september &&
        date.weekday == DateTime.monday &&
        date.day < 8) {
      return true;
    }

    //Indigenous People's Day / Colombus Day (2nd Monday in October)
    if (date.month == DateTime.october &&
        date.weekday == DateTime.monday &&
        date.day > 7 &&
        date.day < 15) {
      return true;
    }

    //Veteran's Day (November 11)
    if (date.month == DateTime.november && date.day == 11) {
      return true;
    }

    //Thanksgiving Day (4th Thursday in November)
    if (date.month == DateTime.november) {
      // Calculate the weekday of the first day of November
      DateTime firstDayOfNovember = DateTime(date.year, DateTime.november, 1);
      int firstDayOfWeek = firstDayOfNovember.weekday;

      // Calculate the date of the 4th Thursday in November
      int thanksgivingWeekday = DateTime.thursday;
      int daysToAdd = (thanksgivingWeekday - firstDayOfWeek + 7) % 7 + 3;
      DateTime fourthThursdayInNovember =
          firstDayOfNovember.add(Duration(days: daysToAdd));

      // Check if the given date is the same as the 4th Thursday in November
      if (date == fourthThursdayInNovember) {
        return true;
      }
    }

    //Christmas Day (December 25)
    if (date.month == DateTime.december && date.day == 25) {
      return true;
    }

    return false;
  }
}
