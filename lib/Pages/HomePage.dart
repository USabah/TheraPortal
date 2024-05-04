import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  const Body({super.key, required this.currentUser, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
        mapData: mapData,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;
  const LargeScreen(
      {super.key, required this.currentUser, required this.mapData});

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
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
                  child: Column(
                    children: [
                      if (currentUser.userType == UserType.Patient)
                        ...mapData.map((therapistInfo) {
                          TheraportalUser therapist =
                              therapistInfo['therapist'];
                          String? groupName = therapistInfo['group_name'];
                          Session? nextSession = therapistInfo['next_session'];

                          return TherapistProfileCard(
                            firstName: therapist.firstName,
                            lastName: therapist.lastName,
                            therapistType: therapist.therapistType.toString(),
                            organization: groupName,
                            nextScheduledSession: nextSession,
                            therapistId: therapist.id,
                          );
                        })
                      else if (currentUser.userType == UserType.Therapist)
                        ...mapData.map((patientInfo) {
                          TheraportalUser patient = patientInfo['patient'];
                          String? groupName = patientInfo['group_name'];
                          Session? nextSession = patientInfo['next_session'];

                          return PatientProfileCard(
                            firstName: patient.firstName,
                            lastName: patient.lastName,
                            dateOfBirth: patient.dateOfBirth!.toDate(),
                            organization: groupName,
                            nextScheduledSession: nextSession,
                            patientId: patient.id,
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}

class HomePage extends StatelessWidget {
  static const Key pageKey = Key("Home Page");
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;

  const HomePage({super.key, required this.currentUser, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
        mapData: mapData,
      ),
    );
  }
}
