import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  final List<Exercise> exercises;
  final Map<String, List<ExerciseAssignment>> exerciseAssignmentsMap;
  final Future<void> Function() refreshFunction;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment}) updateExerciseAssignments;
  const Body(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.refreshFunction,
      required this.exercises,
      required this.exerciseAssignmentsMap,
      required this.updateExerciseAssignments});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
        mapData: mapData,
        refreshFunction: refreshFunction,
        exercises: exercises,
        exerciseAssignmentsMap: exerciseAssignmentsMap,
        updateExerciseAssignments: updateExerciseAssignments,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  final Future<void> Function() refreshFunction;
  final List<Exercise> exercises;
  final Map<String, List<ExerciseAssignment>> exerciseAssignmentsMap;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment}) updateExerciseAssignments;
  const LargeScreen(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.refreshFunction,
      required this.exercises,
      required this.exerciseAssignmentsMap,
      required this.updateExerciseAssignments});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late TheraportalUser currentUser;
  DatabaseRouter databaseRouter = DatabaseRouter();
  late List<Map<String, dynamic>> mapData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    mapData = widget.mapData;
    currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          : (mapData.isEmpty)
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentUser.userType == UserType.Patient
                          ? "You have no assigned therapists at this time. Go to your settings page to add a therapist to your account."
                          : "You have no assigned patients at this time. Go to your settings page to add a patient to your account.",
                      style: const TextStyle(color: Styles.lightGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      if (currentUser.userType == UserType.Patient)
                        ...mapData.map((therapistInfo) {
                          TheraportalUser therapist =
                              therapistInfo['therapist'];
                          String? groupName = therapistInfo['group_name'];
                          Session? nextSession = therapistInfo['next_session'];

                          return TherapistProfileCard(
                            patient: currentUser,
                            therapist: therapist,
                            organization: groupName,
                            nextScheduledSession: nextSession,
                            therapistId: therapist.id,
                            exerciseAssignments:
                                widget.exerciseAssignmentsMap[therapist.id] ??
                                    [],
                          );
                        })
                      else if (currentUser.userType == UserType.Therapist)
                        ...mapData.map((patientInfo) {
                          TheraportalUser patient = patientInfo['patient'];
                          String? groupName = patientInfo['group_name'];
                          Session? nextSession = patientInfo['next_session'];

                          return PatientProfileCard(
                            therapist: currentUser,
                            patient: patient,
                            organization: groupName,
                            nextScheduledSession: nextSession,
                            exercises: widget.exercises,
                            exerciseAssignments:
                                widget.exerciseAssignmentsMap[patient.id] ?? [],
                            updateExerciseAssignments:
                                widget.updateExerciseAssignments,
                          );
                        }),
                      SizedBox(
                        //allows for sliding card without clipping into scaffold
                        height: MediaQuery.of(context).size.height * 0.18,
                      )
                    ],
                  ),
                ),
    ));
  }
}

class HomePage extends StatelessWidget {
  static const Key pageKey = Key("Home Page");
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  final Future<void> Function() refreshFunction;
  final List<Exercise> exercises;
  final Map<String, List<ExerciseAssignment>> exerciseAssignmentsMap;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment}) updateExerciseAssignments;

  const HomePage(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.refreshFunction,
      required this.exercises,
      required this.exerciseAssignmentsMap,
      required this.updateExerciseAssignments});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
        mapData: mapData,
        refreshFunction: refreshFunction,
        exercises: exercises,
        exerciseAssignmentsMap: exerciseAssignmentsMap,
        updateExerciseAssignments: updateExerciseAssignments,
      ),
    );
  }
}
