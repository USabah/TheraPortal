import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Pages/DOBPage.dart';
import 'package:theraportal/Pages/RegistrationPage.dart';
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

class LargeScreen extends StatefulWidget {
  const LargeScreen({Key? key}) : super(key: key);

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  UserType? selectedAccountType;
  String? errorMessage;
  bool continueBtnPressed = false;
  Map<String, dynamic> userMap = {};

  @override
  void initState() {
    super.initState();
    // Initialize the variables in initState
    selectedAccountType = null;
    errorMessage = null;
    continueBtnPressed = false;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Account Type'),
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'Please select your account type',
                          style: TextStyle(color: Styles.beige),
                        ),
                        const SizedBox(
                            height: 8), //Add space between text and dropdown
                        DropdownButtonFormField<UserType>(
                          value: selectedAccountType,
                          items: UserType.values.map((userType) {
                            return DropdownMenuItem<UserType>(
                              value: userType,
                              child: Text(
                                userType.toString(),
                                style: TextStyle(color: Styles.beige),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedAccountType = value;
                              errorMessage = null;
                              continueBtnPressed = false;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Select Option Here',
                            border: OutlineInputBorder(),
                          ),
                          dropdownColor: Colors.black,
                        ),
                        errorMessage != null && continueBtnPressed
                            ? Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              )
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: size.height * 0.04,
                          width: size.width * 0.8,
                          child: ElevatedButton(
                            onPressed: () {
                              continueBtnPressed = true;
                              switch (selectedAccountType) {
                                case UserType.Administrator:
                                  //Group creation page after registration
                                  userMap['user_type'] = selectedAccountType!;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          RegistrationPage(userMap: userMap)));
                                  break;
                                case UserType.Therapist:
                                  //Select therapist type
                                  userMap['user_type'] = selectedAccountType!;
                                  break;
                                case UserType.Patient:
                                  //Enter DOB
                                  userMap['user_type'] = selectedAccountType!;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) =>
                                          DOBPage(userMap: userMap)));
                                  break;
                                default:
                                  setState(() {
                                    errorMessage =
                                        "Please select an account type from above.";
                                  });
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all<Color?>(
                                Styles.orangeYellowish,
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

class AccountTypePage extends StatelessWidget {
  static const Key pageKey = Key("Account Type Page");

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
