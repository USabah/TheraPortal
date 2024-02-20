import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: LayoutBuilder(
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Styles.white),
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16), // Add space between fields
                        TextFormField(
                          controller: _passwordController,
                          style: const TextStyle(color: Styles.white),
                          decoration:
                              const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16), // Add space between fields
                        if (_errorMessage != null)
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        SizedBox(height: 16), // Add space between fields
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // If the form is valid, attempt to sign in with email and password
                              User? user = await AuthRouter().login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                              if (user == null) {
                                setState(() {
                                  _errorMessage = 'Failed to sign in';
                                });
                              }
                            }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              Styles.orangeYellowish,
                            ),
                            foregroundColor: MaterialStateProperty.all<Color?>(
                              Styles.dark,
                            ),
                          ),
                          child: Text('Sign In'),
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
}
