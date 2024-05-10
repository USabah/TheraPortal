import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/AccountInformationPage.dart';
import 'package:theraportal/Pages/AddAssignmentPage.dart';
import 'package:theraportal/Pages/ExerciseCreatorForm.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  final List<Exercise> exerciseCache;
  final List<Session> userSessions;
  const Body(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.exerciseCache,
      required this.userSessions});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
        mapData: mapData,
        exerciseCache: exerciseCache,
        userSessions: userSessions,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  List<Map<String, dynamic>> mapData;
  final List<Exercise> exerciseCache;
  final List<Session> userSessions;

  LargeScreen(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.exerciseCache,
      required this.userSessions});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  bool isPoppingToLandingScreen = false;

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (!isPoppingToLandingScreen) {
            Navigator.of(context).pop(
                [widget.mapData, widget.exerciseCache, widget.userSessions]);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: (isLoading)
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Styles.darkGreyBlue,
                              borderRadius: BorderRadius.circular(21.0),
                            ),
                            child: ListTile(
                              title: const Center(
                                  child: Text(
                                'Account Information',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        AccountInformationPage(
                                            currentUser: widget.currentUser)));
                              },
                            ),
                          ),
                        ),
                        if (widget.currentUser.userType ==
                            UserType.Patient) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Styles.darkGreyBlue,
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: ListTile(
                                title: const Center(
                                    child: Text(
                                  'Add a Therapist',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                onTap: () async {
                                  List<Map<String, dynamic>>? tempMapData =
                                      await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAssignmentPage(
                                                        currentUser:
                                                            widget.currentUser,
                                                        mapData: widget.mapData,
                                                      )))
                                          as List<Map<String, dynamic>>?;
                                  if (tempMapData != null) {
                                    widget.mapData = tempMapData;
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Styles.darkGreyBlue,
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: ListTile(
                                title: const Center(
                                    child: Text(
                                  'Remove Assigned Therapist',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                onTap: () async {
                                  List<dynamic>? tempData =
                                      await showDialog<List<dynamic>?>(
                                    context: context,
                                    builder: (context) =>
                                        RemoveAssignmentDialog(
                                      mapData: widget.mapData,
                                      currentUserType:
                                          widget.currentUser.userType,
                                    ),
                                  );
                                  if (tempData != null) {
                                    List<Map<String, dynamic>> tempMapData =
                                        tempData[0];
                                    String assignmentId = tempData[1];
                                    widget.mapData = tempMapData;
                                    widget.userSessions.removeWhere((session) =>
                                        session.patient.id ==
                                            widget.currentUser.id &&
                                        session.therapist.id == assignmentId);
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                        if (widget.currentUser.userType ==
                            UserType.Therapist) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Styles.darkGreyBlue,
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: ListTile(
                                title: const Center(
                                  child: Text(
                                    'Add a Patient',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onTap: () async {
                                  List<Map<String, dynamic>>? tempMapData =
                                      await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      AddAssignmentPage(
                                                        currentUser:
                                                            widget.currentUser,
                                                        mapData: widget.mapData,
                                                      )))
                                          as List<Map<String, dynamic>>?;
                                  if (tempMapData != null) {
                                    widget.mapData = tempMapData;
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Styles.darkGreyBlue,
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: ListTile(
                                title: const Center(
                                    child: Text(
                                  'Remove Assigned Patient',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                onTap: () async {
                                  List<dynamic>? tempData =
                                      await showDialog<List<dynamic>?>(
                                    context: context,
                                    builder: (context) =>
                                        RemoveAssignmentDialog(
                                      mapData: widget.mapData,
                                      currentUserType:
                                          widget.currentUser.userType,
                                    ),
                                  );
                                  if (tempData != null) {
                                    List<Map<String, dynamic>> tempMapData =
                                        tempData[0];
                                    String assignmentId = tempData[1];
                                    widget.mapData = tempMapData;
                                    widget.userSessions.removeWhere((session) =>
                                        session.patient.id == assignmentId &&
                                        session.therapist.id ==
                                            widget.currentUser.id);
                                  }
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Styles.darkGreyBlue,
                                borderRadius: BorderRadius.circular(21.0),
                              ),
                              child: ListTile(
                                title: const Center(
                                    child: Text(
                                  'Create Exercise',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                )),
                                onTap: () async {
                                  Exercise? exercise =
                                      await Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ExerciseCreatorForm(
                                                    numExercisesCreated: widget
                                                            .exerciseCache
                                                            .length -
                                                        ExerciseConstants
                                                            .numDefaultExercises,
                                                    user: widget.currentUser,
                                                  ))) as Exercise?;
                                  if (exercise != null) {
                                    widget.exerciseCache.add(exercise);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  //Logout and Delete Account buttons
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.grey.shade300,
                                  title: const Text('Logout'),
                                  content: const Text(
                                    'Are you sure you want to logout?',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context); // Close the dialog
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // isPoppingToLandingScreen = true;
                                        AuthRouter.logout(); // Perform logout
                                        Navigator.of(context).popUntil(
                                            (route) => !Navigator.of(context)
                                                .canPop());
                                        // Navigator.of(context).push(MaterialPageRoute(
                                        //     builder: (context) => LandingPage()));
                                      },
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Logout'),
                        ),
                        const SizedBox(
                            height: 8), // Add some space between buttons
                        ElevatedButton(
                          onPressed: () {
                            // Perform the action to delete the account
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: Colors.grey.shade300,
                                  title: const Text('Delete Account?'),
                                  content: const Text(
                                      'Are you sure you want to delete your account? This action cannot be undone.',
                                      style: TextStyle(color: Colors.black)),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        //Dismiss the dialog
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          isLoading = true;
                                        });
                                        isPoppingToLandingScreen = true;

                                        DatabaseRouter()
                                            .deleteAccount(widget.currentUser);
                                        setState(() {
                                          isLoading = false;
                                        });
                                        alertFunction(
                                            context: context,
                                            title: "Account Deleted",
                                            content:
                                                "Successfully deleted your account. Thank you for using TheraPortal!",
                                            onPressed: () =>
                                                Navigator.of(context).popUntil(
                                                    (route) =>
                                                        !Navigator.of(context)
                                                            .canPop()),
                                            btnText: "Ok");
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red),
                                      child: const Text(
                                        'Delete Account',
                                        style: TextStyle(color: Colors.black),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 35.0))
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  final List<Exercise> exerciseCache;
  final List<Session> userSessions;
  static const Key pageKey = Key("Settings Page");

  const SettingsPage(
      {super.key,
      required this.currentUser,
      required this.mapData,
      required this.exerciseCache,
      required this.userSessions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
        mapData: mapData,
        exerciseCache: exerciseCache,
        userSessions: userSessions,
      ),
    );
  }
}
