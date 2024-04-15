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
    return const Scaffold(
      body: Center(
        child: Text("Messages Page"),
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  static const Key pageKey = Key("Messages Page");

  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: pageKey,
      body: Body(),
    );
  }
}
