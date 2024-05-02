import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';

class CalendarTableView extends StatefulWidget {
  final List<Session> sessions;
  final TheraportalUser currentUser;

  const CalendarTableView(
      {super.key, required this.sessions, required this.currentUser});

  @override
  State<CalendarTableView> createState() => _CalendarTableViewState();
}

class _CalendarTableViewState extends State<CalendarTableView> {
  DateTime currentFocus = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ///TWO BUTTONS, ONE FOR VIEWING SESSIONS ON CURRENT DAY SELECTED (IF THERE IS ANY SESSION)
        ///ONE FOR ADDING A SESSION ON THAT DAY
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
            // Use `selectedDayPredicate` to determine which day is currently selected.
            // If this returns true, then `day` will be marked as selected.
            // Using `isSameDay` is recommended to disregard
            // the time-part of compared DateTime objects.
            return isSameDay(currentFocus,
                day); // Replace DateTime.now() with your selected day if needed
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              currentFocus = selectedDay;
            });
          },
          onFormatChanged: (format) {
            // Handle format change here
          },
          onPageChanged: (focusedDay) {
            // Handle page change here
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
          weekendDays: [],
          holidayPredicate: _isUSHoliday,
          enabledDayPredicate: (day) {
            final now = DateTime.now().toLocal();
            final selectedDay = day.toLocal();
            return selectedDay.compareTo(now) >= 0 ||
                isSameDay(selectedDay, now) ||
                isSameDay(day, now);
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
                      ? null
                      : () {
                          List<Session> sessionDayList =
                              _sessionsOnDay(currentFocus);

                          // Navigator.of(context).push(MaterialPageRoute(
                          //   builder: (context) => ScheduleSessionPage(
                          //     currentUser: currentUser,
                          //   ),
                          // ));
                        },
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
                      onPressed: () {
                        // Open the session form for the therapist to schedule sessions
                        // Navigator.of(context).push(MaterialPageRoute(
                        //   builder: (context) => ScheduleSessionPage(
                        //     currentUser: currentUser,
                        //   ),
                        // ));
                      },
                      child: const Text('Schedule Session',
                          style: TextStyle(
                            fontSize: 12.4,
                          )),
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
    return widget.sessions.any((session) => isSameDay(session.dateTime, day));
  }

  List<Session> _sessionsOnDay(DateTime day) {
    List<Session> sessionsOnDay = widget.sessions
        .where((session) => isSameDay(session.dateTime, day))
        .toList();
    //sort sessions by time
    sessionsOnDay.sort((a, b) => a.dateTime.compareTo(b.dateTime));
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

    //Washington's Birthday (3rd Monday in February)
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
