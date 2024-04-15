import 'package:flutter/material.dart';
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
      body: Column(
        children: [
          Center(
            child: Text("Home Page"),
          ),
          PatientProfileCard(
              firstName: "Bob",
              lastName: "The Builder",
              dateOfBirth: "11-01-02"),
          TherapistProfileCard(
              firstName: "Danny",
              lastName: "Phantom",
              therapistType: "Physical Therapist")
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  static const Key pageKey = Key("Home Page");

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
