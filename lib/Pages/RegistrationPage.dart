import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _orgCodeController = TextEditingController();

  bool isLoading = false;
  String? _emailError;
  String? _emailConfirmationError;
  String? _passwordError;
  String? _passwordConfirmationError;
  String? _firstNameError;
  String? _lastNameError;
  String? _orgCodeError;
  AuthRouter authRouter = AuthRouter();
  DatabaseRouter databaseRouter = DatabaseRouter();

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
                        decoration: InputDecoration(
                          labelText: 'Re-enter Email',
                          errorText: _emailConfirmationError,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          errorText: _passwordError,
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Re-enter Password',
                          errorText: _passwordConfirmationError,
                        ),
                      ),
                      TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          errorText: _firstNameError,
                        ),
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          errorText: _lastNameError,
                        ),
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
                                onTap: _showOrgCodeInfoDialog,
                                child: const Icon(Icons
                                    .help_outline), // Change the icon as needed
                              ),
                            ),
                          ),
                          onTap: () {
                            _showOrgCodeInfoDialog();
                          },
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
                              Styles.orangeYellowish,
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

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    String? emailError =
        FieldValidator().validateEmailField(_emailController.text);
    String? passwordError =
        FieldValidator().validatePassword(_passwordController.text);
    String? firstNameError =
        FieldValidator().validateFirstName(_firstNameController.text);
    String? lastNameError =
        FieldValidator().validateLastName(_lastNameController.text);
    String? orgCodeError = await FieldValidator()
        .organizationCode(_orgCodeController.text, userMap["user_type"]);

    _emailError = emailError;
    _passwordError = passwordError;
    _firstNameError = firstNameError;
    _lastNameError = lastNameError;
    _orgCodeError = orgCodeError;

    //Check if form is valid
    if (emailError == null &&
        passwordError == null &&
        firstNameError == null &&
        lastNameError == null &&
        orgCodeError == null) {
      userMap["email"] = _emailController.text;
      userMap["password"] = _passwordController.text;
      userMap["first_name"] = _firstNameController.text;
      userMap["last_name"] = _lastNameController.text;
      userMap["org_reference_code"] = _orgCodeController.text;
      dynamic res =
          await authRouter.registerUser(userMap["email"], userMap["password"]);
      if (res is String) {
        if (res == 'weak-password') {
          passwordError = 'Error: The password provided is too weak';
        } else if (res == 'email-already-in-use') {
          emailError = 'Error: The account already exists for that email';
        }
      } else {
        //account has been successfully registered - let user know
        //that they need to verify their account

        //create database entry for new user
        String userId = res.user.uid;
        userMap["userId"] = userId;
        userMap['date_created'] = Timestamp.now();
        User currentUser = User.fromMap(userMap);
        databaseRouter.addUser(currentUser);

        //send verification email
        await authRouter.login(userMap["email"], userMap["password"]);
        await authRouter.sendVerificationEmail();
        await authRouter.logout();
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
