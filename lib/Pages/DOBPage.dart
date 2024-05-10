import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Pages/RegistrationPage.dart';
import 'package:theraportal/Widgets/Widgets.dart';
import 'package:intl/intl.dart';

class Body extends StatelessWidget {
  final Map<String, dynamic> userMap;
  const Body({super.key, required this.userMap});

  @override
  Widget build(BuildContext context) {
    if (userMap["user_type"] == UserType.Patient) {
      return ResponsiveWidget(
        largeScreen: LargeScreen(userMap: userMap),
      );
    } else {
      return ErrorWidget(
          const Text("Error: Page not accessible with current permissions"));
    }
  }
}

class LargeScreen extends StatefulWidget {
  final Map<String, dynamic> userMap;
  const LargeScreen({super.key, required this.userMap});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  DateTime? dob;
  String? errorMessage;
  bool continueBtnPressed = false;
  late Map<String, dynamic> userMap;

  @override
  void initState() {
    super.initState();
    userMap = widget.userMap;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Date of Birth'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Column(
                      children: <Widget>[
                        const Text(
                          "Please select the patient's date of birth",
                          style: TextStyle(color: Styles.beige),
                        ),
                        const SizedBox(
                            height: 8), //Add space between text and dropdown
                        //DOB selector
                        SizedBox(
                          height: size.height * 0.06,
                          width: size.width * 0.9,
                          child: ElevatedButton(
                            onPressed: () async {
                              final DateTime? selectedDate =
                                  await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                      initialEntryMode:
                                          DatePickerEntryMode.calendar,
                                      initialDatePickerMode:
                                          DatePickerMode.year,
                                      locale: const Locale('en', 'US'));

                              // Update dob variable with selected date
                              if (selectedDate != null) {
                                setState(() {
                                  dob = selectedDate;
                                  errorMessage = null;
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Styles.darkGrey), // Dark grey background
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Colors.white), // White text
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // Rounded corners
                                  side: const BorderSide(
                                      color: Colors.black), // White border
                                ),
                              ),
                            ),
                            child: Text(
                              dob != null
                                  ? DateFormat.yMd().format(dob!)
                                  : 'Select Date of Birth',
                              style: const TextStyle(color: Styles.beige),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        errorMessage != null && continueBtnPressed
                            ? Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              )
                            : const SizedBox(),
                        SizedBox(
                          height: size.height * 0.04,
                          width: size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () {
                              continueBtnPressed = true;
                              if (dob != null) {
                                userMap["date_of_birth"] =
                                    Timestamp.fromDate(dob!);
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        RegistrationPage(userMap: userMap)));
                              } else {
                                setState(() {
                                  errorMessage =
                                      "Please input the patient's date of birth.";
                                });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                Styles.beige,
                              ),
                              shape: MaterialStateProperty.all<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0))),
                              foregroundColor:
                                  MaterialStateProperty.all<Color?>(
                                Styles.dark,
                              ),
                            ),
                            child: const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DOBPage extends StatelessWidget {
  static const Key pageKey = Key("DOB Page");

  final Map<String, dynamic> userMap;

  const DOBPage({
    super.key,
    required this.userMap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(userMap: userMap),
    );
  }
}
