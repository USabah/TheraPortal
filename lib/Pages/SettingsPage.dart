import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Settings Page"),
          ElevatedButton(
              onPressed: () => AuthRouter.logout(), child: Text("logout"))
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
