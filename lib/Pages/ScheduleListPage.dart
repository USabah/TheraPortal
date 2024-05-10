import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/ScheduleSessionForm.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final List<Session> sessions;
  final List<Map<String, dynamic>> mapData;
  final bool fullSessionList;
  final TheraportalUser currentUser;
  final DateTime? day;

  ///temporary solution
  final Future<void> Function() refreshFunction;
  final Function(List<Session>) onUpdateSessions;
  const Body(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.day,
      required this.currentUser,
      required this.refreshFunction,
      required this.mapData,
      required this.onUpdateSessions});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        sessions: sessions,
        fullSessionList: fullSessionList,
        day: day,
        currentUser: currentUser,
        refreshFunction: refreshFunction,
        mapData: mapData,
        onUpdateSessions: onUpdateSessions,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  final List<Session> sessions;
  final bool fullSessionList;
  final DateTime? day;
  final Future<void> Function() refreshFunction;
  final List<Map<String, dynamic>> mapData;
  final Function(List<Session>) onUpdateSessions;
  const LargeScreen(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.day,
      required this.currentUser,
      required this.refreshFunction,
      required this.mapData,
      required this.onUpdateSessions});

  @override
  _LargeScreenState createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  bool isLoading = false;
  DatabaseRouter databaseRouter = DatabaseRouter();

  Future<void> onEditCallback(
      BuildContext context, Session sessionToEdit) async {
    Session? editedSession = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ScheduleSessionForm(
              currentUser: widget.currentUser,
              day: null,
              mapData: widget.mapData,
              scheduledSessions: widget.sessions,
              sessionToEdit: sessionToEdit,
              refreshFunction: widget.refreshFunction,
            ))) as Session?;
    if (editedSession != null) {
      //replace sessionToEdit in widget.sessions with edittedSession
      int index =
          widget.sessions.indexWhere((session) => session == sessionToEdit);
      if (index != -1) {
        widget.sessions[index] = editedSession;
        widget.onUpdateSessions(widget.sessions);
        setState(() {});
      }
    }
  }

  Future<void> onRemoveCallback(Session sessionToRemove) async {
    setState(() {
      isLoading = true;
    });
    bool success = await databaseRouter.removeSession(sessionToRemove);
    if (success) {
      widget.sessions.removeWhere((session) => session == sessionToRemove);
      alertFunction(
          context: context,
          title: "Removed Successfully",
          content: "Removed the session successfully.",
          onPressed: () => Navigator.of(context).pop(),
          btnText: "Ok");
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //group sessions by date
    final sessionsByDate = <String, List<Session>>{};
    for (final session in widget.sessions) {
      final date =
          DateFormat('EEEE, MMMM dd').format(session.getSessionStartTime());
      if (!sessionsByDate.containsKey(date)) {
        sessionsByDate[date] = [];
      }
      sessionsByDate[date]!.add(session);
    }

    return Scaffold(
      appBar: widget.fullSessionList
          ? null
          : AppBar(
              title: Text(
                  "${DateFormat('EEEE (MM/dd/yyyy)').format(widget.day!)} Sessions"),
            ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            isLoading = true;
          });
          await widget.refreshFunction();
          setState(() {
            isLoading = false;
          });
        },
        child: (isLoading)
            ? Container()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: widget.sessions.isEmpty
                    ? Column(
                        children: [
                          Center(
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
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                          )
                        ],
                      )
                    : Column(
                        children: [
                          for (final date in sessionsByDate.keys)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.fullSessionList)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0, horizontal: 16.0),
                                    child: Text(
                                      date,
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                for (final session in sessionsByDate[date]!)
                                  SessionCard(
                                    session: session,
                                    userType: widget.currentUser.userType,
                                    onUpdateSession: onEditCallback,
                                    onRemoveSession: onRemoveCallback,
                                  ),
                              ],
                            ),
                          SizedBox(
                            //allows for sliding card without clipping into scaffold
                            height: MediaQuery.of(context).size.height * 0.18,
                          )
                        ],
                      ),
              ),
      ),
    );
  }
}

class ScheduleListPage extends StatelessWidget {
  final List<Session> sessions;
  final bool fullSessionList;
  final DateTime? daySelected;
  final TheraportalUser currentUser;
  final Future<void> Function() refreshFunction;
  final List<Map<String, dynamic>> mapData;
  final Function(List<Session>) onUpdateSessions;
  static const Key pageKey = Key("Schedule List Page");

  const ScheduleListPage(
      {super.key,
      required this.sessions,
      required this.fullSessionList,
      this.daySelected,
      required this.currentUser,
      required this.refreshFunction,
      required this.mapData,
      required this.onUpdateSessions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        sessions: sessions,
        fullSessionList: fullSessionList,
        day: daySelected,
        currentUser: currentUser,
        refreshFunction: refreshFunction,
        mapData: mapData,
        onUpdateSessions: onUpdateSessions,
      ),
    );
  }
}
