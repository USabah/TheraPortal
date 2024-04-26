import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
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
  LargeScreen({super.key, required this.currentUser});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late TheraportalUser currentUser;
  DatabaseRouter databaseRouter = DatabaseRouter();
  List<Map<String, dynamic>> mapData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    loadMapData();
  }

  Future<void> loadMapData() async {
    if (currentUser.userType == UserType.Patient) {
      try {
        mapData = await databaseRouter.getTherapistCardInfo(currentUser.id);
      } catch (e) {
        print('Error loading therapist data: $e');
      }
    } else if (currentUser.userType == UserType.Therapist) {
      try {
        mapData = await databaseRouter.getPatientCardInfo(currentUser.id);
      } catch (e) {
        print('Error loading patient data: $e');
      }
    }
    setState(() {
      isLoading = false; // Set loading state to false on error
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (currentUser.userType == UserType.Patient)
                    ...mapData.map((therapistInfo) {
                      TheraportalUser therapist = therapistInfo['therapist'];
                      String? groupName = therapistInfo['group_name'];
                      DateTime? nextSession = therapistInfo['next_session'];

                      return TherapistProfileCard(
                        firstName: therapist.firstName,
                        lastName: therapist.lastName,
                        therapistType: therapist.therapistType.toString(),
                        organization: groupName,
                        nextScheduledSession:
                            nextSession, //need to figure out how to format this
                        therapistId: therapist.id,
                      );
                    })
                  else if (currentUser.userType == UserType.Therapist)
                    ...mapData.map((patientInfo) {
                      TheraportalUser patient = patientInfo['patient'];
                      String? groupName = patientInfo['group_name'];
                      DateTime? nextSession = patientInfo['next_session'];

                      return PatientProfileCard(
                        firstName: patient.firstName,
                        lastName: patient.lastName,
                        dateOfBirth: patient.dateOfBirth!.toDate(),
                        organization: groupName,
                        nextScheduledSession:
                            nextSession, //need to figure out how to format this
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

  const HomePage({super.key, required this.currentUser});

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
