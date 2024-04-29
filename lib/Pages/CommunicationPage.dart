import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final String withUserId;
  const Body({super.key, required this.withUserId});
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        withUserId: withUserId,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final String withUserId;

  const LargeScreen({super.key, required this.withUserId});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  Uint8List? exerciseMedia; // Set an initial value
  GoogleDriveRouter router = GoogleDriveRouter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          ChatContainer(withUserId: super.widget.withUserId),
          BottomChatBar(
            withUserId: super.widget.withUserId,
          )
        ],
      ),
    );
  }
}

class ChatContainer extends StatelessWidget {
  String currentUserId = AuthRouter.getUserUID(); //user.uid;
  final String withUserId;
  DatabaseRouter databaseRouter = DatabaseRouter();
  String? lastMessage;

  ChatContainer({super.key, required this.withUserId}); //

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        Navigator.of(context).pop(lastMessage);
      },
      child: FutureBuilder<Stream<QuerySnapshot>>(
          future: databaseRouter.fetchMessageStream(currentUserId, withUserId),
          builder: (BuildContext context,
              AsyncSnapshot<Stream<QuerySnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return StreamBuilder(
                  stream: snapshot.data,
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('$snapshot.error'));
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasData) {
                      List<DocumentSnapshot> messages = snapshot.data!.docs;
                      if (messages.isEmpty) {
                        return const Center(
                            child: Text("No messages between users yet!"));
                      }
                      lastMessage = (messages.last.data()!
                          as Map<String, dynamic>)['message_content'] as String;
                      return Flexible(
                          child: GestureDetector(
                        onTap: () {
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            children:
                                snapshot.data!.docs.map((DocumentSnapshot doc) {
                              Map<String, dynamic> data =
                                  doc.data()! as Map<String, dynamic>;
                              //if sent by the current active user, render as sent message
                              if (currentUserId == data["sender_id"]) {
                                return SentMessage(data: data);
                              } else {
                                //otherwise, render as received message
                                return ReceivedMessage(data: data);
                              }
                            }).toList()),
                      ));
                      //no messages between users yet!
                    } else {
                      return const Text("NO data found");
                    }
                  });
            }
          }),
    );
  }
}

class CommunicationPage extends StatelessWidget {
  static const Key pageKey = Key("Communication Page");
  final String name;
  final String withUserId;
  const CommunicationPage(
      {super.key, required this.withUserId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Define your banner widget here
        title: Text(name),
      ),
      key: pageKey,
      body: Body(withUserId: withUserId),
    );
  }
}
