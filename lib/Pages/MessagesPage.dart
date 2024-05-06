import 'package:flutter/material.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
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
  late TheraportalUser currentUser;
  DatabaseRouter databaseRouter = DatabaseRouter();
  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: databaseRouter.geUserMessagesInfo(
            currentUser.id, currentUser.userType),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading messages.'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            String assignmentType = (currentUser.userType == UserType.Patient)
                ? "therapist"
                : "patient";
            return Center(
              child: Text(
                'There are no users currently associated with your account. Go to your settings page to add a $assignmentType to your account.',
                style: const TextStyle(color: Styles.lightGrey),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            //build the scrollable list of MessagesCard widgets
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final messageInfo = snapshot.data![index];
                return MessagesCard(
                  firstName: messageInfo['firstName'],
                  lastName: messageInfo['lastName'],
                  userType: messageInfo['userType'],
                  lastMessageContent: messageInfo['messageContent'],
                  sentByCurrentUser: messageInfo['sentByCurrentUser'],
                  withUserId: messageInfo['withUserId'],
                  messageTimestamp: messageInfo['messageTimestamp'],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class MessagesPage extends StatelessWidget {
  static const Key pageKey = Key("Messages Page");
  final TheraportalUser currentUser;

  const MessagesPage({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: pageKey,
      body: Body(
        currentUser: currentUser,
      ),
    );
  }
}
