import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Pages/ScheduleListPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Session> userSessions;
  final List<Map<String, dynamic>> mapData;
  final Function(List<Session>) onUpdateSessions;
  final Future<void> Function() refreshFunction;
  const Body(
      {super.key,
      required this.currentUser,
      required this.userSessions,
      required this.onUpdateSessions,
      required this.mapData,
      required this.refreshFunction});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
        userSessions: userSessions,
        onUpdateSessions: onUpdateSessions,
        mapData: mapData,
        refreshFunction: refreshFunction,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  List<Session> userSessions;
  final Function(List<Session>) onUpdateSessions;
  final List<Map<String, dynamic>> mapData;
  final Future<void> Function() refreshFunction;
  LargeScreen(
      {super.key,
      required this.currentUser,
      required this.userSessions,
      required this.onUpdateSessions,
      required this.mapData,
      required this.refreshFunction});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen>
    with TickerProviderStateMixin {
  late TheraportalUser currentUser;
  late TabController _tabController;
  DatabaseRouter databaseRouter = DatabaseRouter();

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    _tabController = TabController(length: 2, vsync: this);
  }

  void localUpdateSessions(List<Session> updatedSessions) {
    setState(() {
      widget.userSessions = updatedSessions;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.white,
          tabs: const [
            Tab(
              text: 'Calendar',
            ),
            Tab(text: 'Sessions'),
          ],
        ),
        Expanded(
            child: TabBarView(
          controller: _tabController,
          children: [
            CalendarTableView(
              sessions: widget.userSessions,
              currentUser: widget.currentUser,
              onUpdateSessions: localUpdateSessions,
              mapData: widget.mapData,
              refreshFunction: widget.refreshFunction,
            ),
            ScheduleListPage(
              sessions: widget.userSessions,
              fullSessionList: true,
              currentUser: currentUser,
              refreshFunction: widget.refreshFunction,
              mapData: widget.mapData,
              onUpdateSessions: widget.onUpdateSessions,
            ),
          ],
        )),
      ],
    );
  }
}

class SchedulePage extends StatelessWidget {
  static const Key pageKey = Key("Schedule Page");
  final TheraportalUser currentUser;
  final List<Session> userSessions;
  final Function(List<Session>) onUpdateSessions;
  final List<Map<String, dynamic>> mapData;
  final Future<void> Function() refreshFunction;

  const SchedulePage(
      {super.key,
      required this.currentUser,
      required this.userSessions,
      required this.onUpdateSessions,
      required this.mapData,
      required this.refreshFunction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
        userSessions: userSessions,
        onUpdateSessions: onUpdateSessions,
        mapData: mapData,
        refreshFunction: refreshFunction,
      ),
    );
  }
}
