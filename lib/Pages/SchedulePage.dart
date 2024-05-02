import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/ScheduleSessionsList.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  const Body({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  const LargeScreen({super.key, required this.currentUser});

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
              sessions: [
                Session(
                    dateTime: DateTime(2024, 5, 8),
                    additionalInfo: null,
                    isWeekly: false,
                    patient: currentUser,
                    therapist: currentUser),
              ],
              currentUser: widget.currentUser,
            ),
            ScheduledSessionsList(
              sessions: [
                Session(
                    dateTime: DateTime(2024, 5, 8),
                    additionalInfo: null,
                    isWeekly: false,
                    patient: currentUser,
                    therapist: currentUser),
              ],
              fullScheduleView: true,
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

  const SchedulePage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
      ),
    );
  }
}

class ScheduleSessionForm extends StatefulWidget {
  const ScheduleSessionForm({super.key});

  @override
  _ScheduleSessionFormState createState() => _ScheduleSessionFormState();
}

class _ScheduleSessionFormState extends State<ScheduleSessionForm> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late String _notes;
  late bool _isWeekly;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _notes = '';
    _isWeekly = false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Date: ${DateFormat('MM/dd/yyyy').format(_selectedDate)}'),
        ElevatedButton(
          onPressed: () => _selectDate(context),
          child: const Text('Select Date'),
        ),
        const SizedBox(height: 10),
        Text('Time: ${_selectedTime.format(context)}'),
        ElevatedButton(
          onPressed: () => _selectTime(context),
          child: const Text('Select Time'),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Notes',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text('Weekly Recurrence:'),
            const SizedBox(width: 10),
            Switch(
              value: _isWeekly,
              onChanged: (value) {
                setState(() {
                  _isWeekly = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            // Implement logic to save session
          },
          child: const Text('Schedule Session'),
        ),
      ],
    );
  }
}
