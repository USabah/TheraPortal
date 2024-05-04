import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final List<Session> sessions;
  final bool fullSessionList;
  final TheraportalUser currentUser;
  final DateTime? day;
  const Body(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.day,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        sessions: sessions,
        fullSessionList: fullSessionList,
        day: day,
        currentUser: currentUser,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  final List<Session> sessions;
  final bool fullSessionList;
  final DateTime? day;
  const LargeScreen(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.day,
      required this.currentUser});

  @override
  _LargeScreenState createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //(widget.fullSessionList)
    return Scaffold(
      appBar: widget.fullSessionList
          ? null
          : AppBar(
              title: Text(
                  "${DateFormat('EEEE (MM/dd/yyyy)').format(widget.day!)} Sessions"),
            ),
      body: (widget.sessions.isEmpty)
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.currentUser.userType == UserType.Patient
                      ? "You have no scheduled sessions at the moment."
                      : "You have no scheduled sessions at the moment. To schedule a session, go to the calendar, select a date, and click on the \"Schedule Session\" button.",
                  style: const TextStyle(color: Styles.lightGrey),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              itemCount: widget.sessions.length,
              itemBuilder: (context, index) {
                final session = widget.sessions[index];
                return SessionCard(session: session);
              },
            ),
    );
  }
}

class ScheduleListPage extends StatelessWidget {
  final List<Session> sessions;
  final bool fullSessionList;
  final DateTime? daySelected;
  final TheraportalUser currentUser;
  static const Key pageKey = Key("Schedule List Page");

  const ScheduleListPage(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.daySelected,
      required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        sessions: sessions,
        fullSessionList: fullSessionList,
        day: daySelected,
        currentUser: currentUser,
      ),
    );
  }
}
