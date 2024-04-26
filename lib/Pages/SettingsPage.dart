import 'package:flutter/material.dart';
import 'package:theraportal/Pages/LandingPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  const Body({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatelessWidget {
  const LargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Styles.darkGreyBlue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Update Account Information',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the update account information screen
                        Navigator.pushNamed(context, '/update_account');
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Styles.darkGreyBlue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Add a Therapist',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the add therapist screen
                        Navigator.pushNamed(context, '/add_therapist');
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Styles.darkGreyBlue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Add a Patient',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the add patient screen
                        Navigator.pushNamed(context, '/add_patient');
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Styles.darkGreyBlue,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ListTile(
                      title: const Text(
                        'Remove Assigned Patient',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        // Perform the action to remove assigned patient
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Logout and Delete Account buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    AuthRouter.logout();
                    Navigator.of(context)
                      ..popUntil((route) => !Navigator.of(context).canPop())
                      ..push(MaterialPageRoute(
                          builder: (context) => LandingPage()));
                  },
                  child: const Text('Logout'),
                ),
                const SizedBox(height: 8), // Add some space between buttons
                ElevatedButton(
                  onPressed: () {
                    // Perform the action to delete the account
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Delete Account?'),
                          content: const Text(
                              'Are you sure you want to delete your account? This action cannot be undone.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                // Dismiss the dialog
                                Navigator.pop(context);
                              },
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Perform the action to delete the account
                                // For example:
                                // AuthService.deleteAccount();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red),
                              child: const Text('Delete Account'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
    );
  }
}

class SettingsPage extends StatelessWidget {
  static const Key pageKey = Key("Settings Page");

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
