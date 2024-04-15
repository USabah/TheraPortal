import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theraportal/Utilities/FieldValidator.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final bool verificationEmailSent;
  const Body({super.key, required this.verificationEmailSent});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        verificationEmailSent: verificationEmailSent,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final bool verificationEmailSent;
  const LargeScreen({super.key, required this.verificationEmailSent});

  @override
  _LargeScreenPageState createState() => _LargeScreenPageState();
}

class _LargeScreenPageState extends State<LargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  bool hidePassword = true;
  late bool verificationEmailSent;
  String? _emailError;
  String? _passwordError;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    verificationEmailSent = widget.verificationEmailSent;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (isLoading)
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: const Text('Sign In'),
            ),
            body: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Styles.white),
                                decoration: InputDecoration(
                                    labelText: 'Email', errorText: _emailError),
                                onChanged: (_) {
                                  setState(() {
                                    _emailError = null;
                                  });
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Styles.white),
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
                              const SizedBox(height: 16),
                              if (_errorMessage != null)
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: size.height * 0.04,
                                width: size.width * 0.8,
                                child: ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color?>(
                                        Styles.beige,
                                      ),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      foregroundColor:
                                          MaterialStateProperty.all<Color?>(
                                        Styles.dark,
                                      )),
                                  child: const Text('Sign In'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    _emailError = FieldValidator.validateEmailField(email);
    _passwordError = FieldValidator.validatePassword(password);

    //if the form is valid, attempt to sign in with email and password
    if (_emailError == null && _passwordError == null) {
      User? user = await AuthRouter.login(email, password);
      if (user == null) {
        _errorMessage = 'The Email/Password combination entered was not found';
      } else {
        //check if account is verified
        if (!(await AuthRouter.isVerified())) {
          //logout and present popup alert telling the user to verify themselves
          if (!verificationEmailSent) {
            await AuthRouter.sendVerificationEmail();
            verificationEmailSent = true;
          }
          await AuthRouter.logout();
          alertFunction(
              context: context,
              title: "Account Not Verified",
              content:
                  "Please verify your email address before logging in. We have sent another verification email to $email. Make sure to check your spam folder for the email.",
              onPressed: () {
                Navigator.of(context).pop();
              },
              btnText: "Close");
        } else {
          //future builder returns home screen
          Navigator.of(context).pop();
        }
      }
    }
    setState(() {
      isLoading = false;
    });
  }
}

class SignInPage extends StatelessWidget {
  static const Key pageKey = Key("Sign In Page");

  bool? sentFromRegistrationPopup;

  SignInPage({
    super.key,
    this.sentFromRegistrationPopup,
  });

  @override
  Widget build(BuildContext context) {
    bool verificationEmailSent =
        (sentFromRegistrationPopup == true) ? true : false;
    return Scaffold(
      key: pageKey,
      body: Body(verificationEmailSent: verificationEmailSent),
    );
  }
}
