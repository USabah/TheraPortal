import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class ScheduleSessionForm extends StatefulWidget {
  final TheraportalUser currentUser;
  final TheraportalUser? selectedPatient;
  final DateTime? day;
  final Session? sessionToEdit;
  final List<Map<String, dynamic>> patientData;
  final List<Session> scheduledSessions;
  const ScheduleSessionForm(
      {super.key,
      required this.currentUser,
      this.sessionToEdit,
      required this.day,
      this.selectedPatient,
      required this.patientData,
      required this.scheduledSessions});

  @override
  _ScheduleSessionFormState createState() => _ScheduleSessionFormState();
}

class _ScheduleSessionFormState extends State<ScheduleSessionForm> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DayOfWeek? _selectedDayOfWeek;
  String? _additionalInfo;
  int? _sessionDuration;
  late bool _isWeekly;
  TheraportalUser? _selectedPatient;
  bool isLoading = false;
  DatabaseRouter databaseRouter = DatabaseRouter();

  @override
  void initState() {
    super.initState();
    if (widget.sessionToEdit != null) {
      _selectedDate = widget.sessionToEdit!.dateTime;
      _selectedTime = widget.sessionToEdit!.timeOfDay;
      _selectedDayOfWeek = widget.sessionToEdit!.dayOfWeek;
      _isWeekly = widget.sessionToEdit!.isWeekly;
      _additionalInfo = widget.sessionToEdit!.additionalInfo;
    } else {
      _selectedDate = widget.day!;
      _isWeekly = false;
    }
    _selectedPatient = widget.selectedPatient;
  }

  Session sessionFromClass() {
    if (_isWeekly) {
      return Session.weekly(
        patient: _selectedPatient!,
        therapist: widget.currentUser,
        isWeekly: true,
        dayOfWeek: _selectedDayOfWeek!,
        timeOfDay: _selectedTime!,
        durationInMinutes: _sessionDuration!,
        additionalInfo: _additionalInfo,
      );
    } else {
      DateTime dateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
      return Session(
          patient: _selectedPatient!,
          therapist: widget.currentUser,
          isWeekly: false,
          dateTime: dateTime,
          additionalInfo: _additionalInfo,
          durationInMinutes: _sessionDuration!);
    }
  }

  Future<bool> createSession(Session session) async {
    //push session to database
    return await databaseRouter.addSession(session);
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
      initialTime: _selectedTime ?? const TimeOfDay(hour: 13, minute: 0),
      initialEntryMode: TimePickerEntryMode.inputOnly,
      helpText: "Enter the Session Time",
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[800],
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  bool fieldsAreValid() {
    return _selectedPatient != null &&
        _sessionDuration != null &&
        _selectedTime != null &&
        ((!_isWeekly && _selectedDate != null) ||
            (_isWeekly && _selectedDayOfWeek != null));
  }

  Future<String?> checkListOfSessionsForOverlap(
      Session sessionToSchedule) async {
    //get patient's scheduled sessions
    List<Session> patientSessions =
        await databaseRouter.getAllUserSessions(sessionToSchedule.patient);
    for (var sessionToCheck in patientSessions) {
      if (Session.isDuringSession(sessionToSchedule, sessionToCheck)) {
        DateTime sessionStartTime = sessionToCheck.getSessionStartTime();
        DateTime sessionEndTime = sessionToCheck.getSessionEndTime();
        String formattedStartTime = DateFormat.jm().format(sessionStartTime);
        String formattedEndTime = DateFormat.jm().format(sessionEndTime);
        return "Patient already has a session scheduled at this time between $formattedStartTime - $formattedEndTime with ${sessionToCheck.therapist.fullNameDisplay(true)}";
      }
    }
    for (var sessionToCheck in widget.scheduledSessions) {
      if (Session.isDuringSession(sessionToSchedule, sessionToCheck)) {
        DateTime sessionStartTime = sessionToCheck.getSessionStartTime();
        DateTime sessionEndTime = sessionToCheck.getSessionEndTime();
        String formattedStartTime = DateFormat.jm().format(sessionStartTime);
        String formattedEndTime = DateFormat.jm().format(sessionEndTime);
        return "You already have a session scheduled at this time between $formattedStartTime - $formattedEndTime with ${sessionToCheck.patient.fullNameDisplay(false)}";
      }
    }
    return null; //no overlap
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Schedule Session"),
      ),
      body: (isLoading)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isWeekly)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: DropdownButtonFormField<DayOfWeek>(
                          dropdownColor: Styles.grey,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Select Day of Week',
                            labelStyle: TextStyle(
                                color: Styles.beige,
                                fontWeight: FontWeight.bold),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                          ),
                          value: _selectedDayOfWeek,
                          items: DayOfWeek.values
                              .map((day) => DropdownMenuItem(
                                    value: day,
                                    child: Text(
                                      day.toString(),
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedDayOfWeek = value;
                            });
                          },
                        ),
                      )
                    else
                      FieldWidget(
                        label: 'Date:',
                        value: DateFormat('MM/dd/yyyy').format(_selectedDate!),
                        onPressed: () => _selectDate(context),
                      ),
                    const SizedBox(height: 20),
                    FieldWidget(
                      label: 'Session Time:',
                      value: _selectedTime?.format(context) ?? 'Select Time',
                      onPressed: () => _selectTime(context),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 0),
                        child: DropdownButtonFormField<TheraportalUser>(
                          dropdownColor: Styles.grey,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Select Patient',
                            labelStyle: TextStyle(
                                color: Styles.beige,
                                fontWeight: FontWeight.bold),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                          ),
                          value: _selectedPatient,
                          items: widget.patientData
                              .map<DropdownMenuItem<TheraportalUser>>((data) {
                            final patient = data['patient'] as TheraportalUser;
                            return DropdownMenuItem(
                              value: patient,
                              child: Text(
                                patient.fullNameDisplay(false),
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPatient = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    FieldWidget(
                      label: 'Session Duration (minutes)',
                      value: _sessionDuration != null
                          ? '$_sessionDuration'
                          : 'Select Here',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Theme(
                              data: ThemeData.dark(), // Set dark theme
                              child: AlertDialog(
                                title: const Text(
                                    'Select Session Duration (minutes)'),
                                content: StatefulBuilder(
                                  builder: (context, setState) {
                                    return NumberPicker(
                                      minValue: 10,
                                      maxValue: 120,
                                      step: 5,
                                      value: _sessionDuration ?? 30,
                                      onChanged: (newValue) {
                                        setState(() {
                                          _sessionDuration =
                                              newValue; // Update the state variable
                                        });
                                      },
                                    );
                                  },
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _sessionDuration =
                                            _sessionDuration ?? 30;
                                      });
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      maxLength: 60,
                      decoration: const InputDecoration(
                        labelText: 'Additional Info (optional)',
                        labelStyle: TextStyle(
                            fontWeight: FontWeight.bold, color: Styles.beige),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _additionalInfo = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Weekly Recurrence:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Switch(
                          value: _isWeekly,
                          onChanged: (value) {
                            setState(() {
                              _isWeekly = value;
                            });
                          },
                        ),
                        IconButton(
                          onPressed: _showWeeklyToggleInfoDialog,
                          icon: const Icon(Icons.help_outline),
                          color: Colors.grey,
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: const ButtonStyle(
                              backgroundColor:
                                  MaterialStatePropertyAll(Colors.red)),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: (fieldsAreValid())
                              ? const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Styles.beige),
                                  // textStyle: MaterialStatePropertyAll(
                                  //     TextStyle(fontWeight: FontWeight.bold)),
                                )
                              : const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.grey),
                                  textStyle: MaterialStatePropertyAll(
                                      TextStyle(fontWeight: FontWeight.w300)),
                                ),
                          onPressed: (fieldsAreValid())
                              ? () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  Session session = sessionFromClass();
                                  //check if another session takes place at this time
                                  String? result =
                                      await checkListOfSessionsForOverlap(
                                          session);
                                  if (result != null) {
                                    //this means that there is an overlap in sessions
                                    alertFunction(
                                        context: context,
                                        title: "Cannot Schedule Session",
                                        content: result,
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        btnText: "Close");
                                  } else {
                                    bool success = await databaseRouter
                                        .addSession(session);
                                    if (!success) {
                                      alertFunction(
                                          context: context,
                                          title: "Error",
                                          content:
                                              "We could not add the session to your account at this time.",
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          btnText: "Close",
                                          isDismissable: false);
                                    } else {
                                      alertFunction(
                                          context: context,
                                          title: "Success",
                                          content:
                                              "Session successfully scheduled.",
                                          onPressed: () => Navigator.of(context)
                                            ..pop()
                                            ..pop(session),
                                          btnText: "Ok");
                                    }
                                  }
                                }
                              : null,
                          child: const Text('Schedule Session'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _showWeeklyToggleInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: const Text('Reschedule Weekly'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "If toggled on, the session will be scheduled on a weekly basis at the day/time selected. Otherwise, the session will be scheduled just for the specified date and time.",
                    style: TextStyle(
                      color: Colors.black,
                    ))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
