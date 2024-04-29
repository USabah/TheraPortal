import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Pages/AddAssignmentPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
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

class LargeScreen extends StatelessWidget {
  final TheraportalUser currentUser;
  List<Map<String, dynamic>> mapData;
  bool isPoppingToLandingScreen = false;
  LargeScreen({super.key, required this.currentUser, required this.mapData});

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
            Navigator.of(context).pop(mapData);
          } else {
            Navigator.of(context).pop();
          }
        },
        child: Column(
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
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                        onTap: () {
                          // Navigate to the update account information screen
                          // Navigator.pushNamed(context, '/update_account');
                        },
                      ),
                    ),
                  ),
                  if (currentUser.userType == UserType.Patient) ...[
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
                          onTap: () {
                            // Navigate to the add therapist screen
                            // Navigator.pushNamed(context, '/add_therapist');
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
                            List<Map<String, dynamic>>? tempMapData =
                                await showDialog<List<Map<String, dynamic>>>(
                              context: context,
                              builder: (context) => RemoveAssignmentDialog(
                                mapData: mapData,
                                currentUserType: currentUser.userType,
                              ),
                            );
                            if (tempMapData != null) {
                              mapData = tempMapData;
                            }
                          },
                        ),
                      ),
                    )
                  ],
                  if (currentUser.userType == UserType.Therapist) ...[
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
                                await Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) => AddAssignmentPage(
                                              currentUser: currentUser,
                                              mapData: mapData,
                                            ))) as List<Map<String, dynamic>>?;
                            if (tempMapData != null) {
                              mapData = tempMapData;
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
                            List<Map<String, dynamic>>? tempMapData =
                                await showDialog<List<Map<String, dynamic>>>(
                              context: context,
                              builder: (context) => RemoveAssignmentDialog(
                                mapData: mapData,
                                currentUserType: currentUser.userType,
                              ),
                            );
                            if (tempMapData != null) {
                              mapData = tempMapData;
                            }
                          },
                        ),
                      ),
                    )
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
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // isPoppingToLandingScreen = true;
                                  AuthRouter.logout(); // Perform logout
                                  Navigator.of(context).popUntil((route) =>
                                      !Navigator.of(context).canPop());
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
                  const SizedBox(height: 8), // Add some space between buttons
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
                                  isPoppingToLandingScreen = true;

                                  ///Need to fill this in
                                  // AuthService.deleteAccount();
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
  static const Key pageKey = Key("Settings Page");

  const SettingsPage(
      {super.key, required this.currentUser, required this.mapData});

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
