import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/FirestoreRouter.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/BottomChatBar.dart';
import '../Widgets/Widgets.dart';

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(),
    );
  }
}

class LargeScreen extends StatefulWidget {
  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  Uint8List? exerciseMedia; // Set an initial value
  GoogleDriveRouter router = GoogleDriveRouter();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [ChatContainer(), const BottomChatBar()],
      ),
    );
  }
}

class CommunicationPage extends StatelessWidget {
  static const Key pageKey = Key("Communication Page");

  @override
  Widget build(BuildContext context) {
    const name = "NAME HERE";
    return Scaffold(
      appBar: AppBar(
        // Define your banner widget here
        title: const Text('Chat with $name'),
      ),
      key: pageKey,
      body: Body(),
    );
  }
}

class ChatContainer extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;
  static const currentUserId = "1"; //user.uid;
  static const otherUserId = "2"; //

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Stream<QuerySnapshot>>(
        future:
            FirestoreRouter().fetchMessageStream(currentUserId, otherUserId),
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
                    return Text("NO data found");
                  }
                });
          }
        });
  }
}
