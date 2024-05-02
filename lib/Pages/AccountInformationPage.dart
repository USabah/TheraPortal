import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  const LargeScreen({super.key, required this.currentUser});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  DatabaseRouter databaseRouter = DatabaseRouter();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account Information Page"),
      ),
      body: Center(
        child: (isLoading)
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // const Text(
                    //   'Account Information',
                    //   style: TextStyle(
                    //     fontSize: 24,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 2,
                      child: Column(
                        children: [
                          _buildUserDetailTile(
                              'Full Name', widget.currentUser.fullName()),
                          _buildUserDetailTile(
                              'Email', widget.currentUser.email),
                          _buildUserDetailTile('User Type',
                              widget.currentUser.userType.toString()),
                          _buildUserDetailTile(
                              'Date Created',
                              DateFormat('MM/dd/yyyy').format(
                                  widget.currentUser.dateCreated.toDate())),
                          if (widget.currentUser.dateOfBirth != null)
                            _buildUserDetailTile(
                                'Date of Birth',
                                DateFormat('MM/dd/yyyy').format(
                                    widget.currentUser.dateOfBirth!.toDate())),
                          _buildUserDetailTile('Reference Code',
                              widget.currentUser.referenceCode),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        String referenceCode = await generateReferenceCode();
                        if (await databaseRouter.updateReferenceCode(
                            widget.currentUser.id, referenceCode)) {
                          widget.currentUser.referenceCode = referenceCode;
                          alertFunction(
                              context: context,
                              title: "Success",
                              content:
                                  "Successfully updated reference code to '$referenceCode'.",
                              onPressed: () => Navigator.of(context).pop(),
                              btnText: "Ok",
                              isDismissable: true);
                        } else {
                          alertFunction(
                              context: context,
                              title: "Update Failed",
                              content:
                                  "Failed to update reference code. Please try again later.",
                              onPressed: () => Navigator.of(context).pop(),
                              btnText: "Close");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(''),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                        setState(() {
                          isLoading = false;
                        });
                      },
                      child: const Text('Update Reference Code'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<String> generateReferenceCode() async {
    int codeLength = 6;
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    String code = '';

    try {
      while (true) {
        code = String.fromCharCodes(Iterable.generate(
            codeLength, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

        if (!(await databaseRouter.fieldExists(
            'Users', 'user_reference_code', code))) {
          break; //unique code found
        }
      }
    } catch (e) {
      print('Error generating reference code: $e');
      throw Exception('Failed to generate reference code');
    }

    return code;
  }

  Widget _buildUserDetailTile(String title, String value) {
    return Container(
      height: 100,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26, // Increase the font size as needed
              fontFamily: "Sans-Serif"),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
              fontSize: 20, // Increase the font size as needed
              fontFamily: "Sans-Serif"),
        ),
      ),
    );
  }
}

class AccountInformationPage extends StatelessWidget {
  static const Key pageKey = Key("Account Information Page");
  final TheraportalUser currentUser;
  const AccountInformationPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        currentUser: currentUser,
      ),
    );
  }
}
