import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Pages/SignInPage.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Utilities/FieldValidator.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final Map<String, dynamic> userMap;
  const Body({super.key, required this.userMap});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(userMap: userMap),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final Map<String, dynamic> userMap;
  const LargeScreen({super.key, required this.userMap});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late Map<String, dynamic> userMap;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _emailConfirmationController =
      TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();

  DatabaseRouter databaseRouter = DatabaseRouter();

  bool isLoading = false;
  bool hidePassword = true;
  bool hideReEnterPassword = true;
  String? _emailError;
  String? _emailConfirmationError;
  String? _passwordError;
  String? _passwordConfirmationError;
  String? _firstNameError;
  String? _lastNameError;
  String? _orgCodeError;

  @override
  void initState() {
    super.initState();
    userMap = widget.userMap;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _orgCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (isLoading)
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Registration'),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Account Email',
                          errorText: _emailError,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _emailError = null;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _emailConfirmationController,
                        decoration: InputDecoration(
                          labelText: 'Re-enter Email',
                          errorText: _emailConfirmationError,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _emailConfirmationError = null;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: hidePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _passwordError,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            child: Icon((hidePassword)
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded),
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _passwordError = null;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _passwordConfirmationController,
                        obscureText: hideReEnterPassword,
                        decoration: InputDecoration(
                          labelText: 'Re-enter Password',
                          errorText: _passwordConfirmationError,
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                hideReEnterPassword = !hideReEnterPassword;
                              });
                            },
                            child: Icon((hideReEnterPassword)
                                ? Icons.visibility_rounded
                                : Icons.visibility_off_rounded),
                          ),
                        ),
                        onChanged: (_) {
                          setState(() {
                            _passwordConfirmationError = null;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          errorText: _firstNameError,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _firstNameError = null;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          errorText: _lastNameError,
                        ),
                        onChanged: (_) {
                          setState(() {
                            _lastNameError = null;
                          });
                        },
                      ),
                      //organization code option only if the user is not an admin
                      if (userMap["user_type"] != UserType.Administrator)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: TextFormField(
                            controller: _orgCodeController,
                            decoration: InputDecoration(
                              labelText: 'Organization Code (optional)',
                              errorText: _orgCodeError,
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  alertFunction(
                                      context: context,
                                      title: 'Organization Code',
                                      content:
                                          "If you were brought to TheraPortal via an organization or social service, see if they provided you with their group's reference code. Alternatively, you can return to this later via your account settings.",
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      btnText: 'Close');
                                },
                                child: const Icon(Icons
                                    .help_outline), // Change the icon as needed
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {
                                _orgCodeError = null;
                              });
                            },
                          ),
                        ),
                      const SizedBox(
                        height: 8,
                      ),
                      SizedBox(
                        height: size.height * 0.04,
                        width: size.width * 0.8,
                        child: ElevatedButton(
                          onPressed: _submitForm,
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              Styles.beige,
                            ),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            foregroundColor: MaterialStateProperty.all<Color?>(
                              Styles.dark,
                            ),
                          ),
                          child: const Text('Register'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void _showOrgCodeInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Organization Code'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "If you were brought to TheraPortal via an organization or social service, see if they provided you with their group's reference code. Alternatively, you can return to this later via your account settings.",
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

  String fixNameCapitalization(String input) {
    if (input.isEmpty) {
      return input; // Return empty string if input is empty
    }
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
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

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    userMap["email"] = _emailController.text.trim();
    userMap["password"] = _passwordController.text.trim();
    userMap["first_name"] =
        fixNameCapitalization(_firstNameController.text.trim());
    userMap["last_name"] =
        fixNameCapitalization(_lastNameController.text.trim());
    userMap["org_reference_code"] = _orgCodeController.text.trim();

    _emailError = FieldValidator.validateEmailField(userMap["email"]);
    if (userMap["email"].toLowerCase() !=
        _emailConfirmationController.text.trim().toLowerCase()) {
      _emailConfirmationError = "Emails do not match";
    }
    _passwordError = FieldValidator.validatePassword(userMap["password"]);
    if (userMap["password"] != _passwordConfirmationController.text.trim()) {
      _passwordConfirmationError = "Passwords do not match";
    }
    _firstNameError = FieldValidator.validateFirstName(userMap["first_name"]);
    _lastNameError = FieldValidator.validateLastName(userMap["last_name"]);
    _orgCodeError = await FieldValidator.organizationCode(
        userMap["org_reference_code"], userMap["user_type"]);

    //Check if form is valid
    if (_emailError == null &&
        _passwordError == null &&
        _firstNameError == null &&
        _lastNameError == null &&
        _orgCodeError == null &&
        _emailConfirmationError == null &&
        _passwordConfirmationError == null) {
      dynamic res =
          await AuthRouter.registerUser(userMap["email"], userMap["password"]);
      if (res is String) {
        if (res == 'weak-password') {
          _passwordError = 'Error: The password provided is too weak';
        } else if (res == 'email-already-in-use') {
          _emailError = 'Error: The account already exists for that email';
        }
      } else {
        //create database entry for new user
        //first generate a user_reference_code
        print("here1");
        userMap["user_reference_code"] = await generateReferenceCode();
        print("here2");
        String userId = res.user.uid;
        print("here3");
        userMap["userId"] = userId;
        print("here4");
        userMap['date_created'] = Timestamp.now();
        print("here5");
        TheraportalUser currentUser = TheraportalUser.fromMap(userMap);
        print("here6");
        databaseRouter.addUser(currentUser);
        print("here7");
        //send verification email
        await AuthRouter.login(userMap["email"], userMap["password"]);
        await AuthRouter.sendVerificationEmail();
        await AuthRouter.logout();
        //account has been successfully registered - let user know
        //that they need to verify their account
        alertFunction(
            context: context,
            isDismissable: false,
            title: "Verify Account",
            content:
                "Your account has been registered with TheraPortal. We have sent a verification email to your email address. Please verify your account before logging in.",
            onPressed: () {
              Navigator.of(context)
                ..popUntil((route) => !Navigator.of(context).canPop())
                ..push(MaterialPageRoute(
                    builder: (context) => SignInPage(
                          sentFromRegistrationPopup: true,
                        )));
            },
            btnText: "Sign in");
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}

class RegistrationPage extends StatelessWidget {
  static const Key pageKey = Key("Registration Page");

  final Map<String, dynamic> userMap;

  const RegistrationPage({
    Key? key,
    required this.userMap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(userMap: userMap),
    );
  }
}
