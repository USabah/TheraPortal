import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';
import 'package:flutter/material.dart';

class BottomChatBar extends StatefulWidget {
  final String withUserId;
  const BottomChatBar({super.key, required this.withUserId});

  @override
  _BottomChatBarState createState() => _BottomChatBarState();
}

class _BottomChatBarState extends State<BottomChatBar> {
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  String currentUserId = AuthRouter.getUserUID();
  late String otherUserId;
  late CollectionReference chatsRef;
  static DatabaseRouter databaseRouter = DatabaseRouter();

  @override
  void initState() {
    super.initState();
    otherUserId = super.widget.withUserId;
    init();
  }

  void init() async {
    chatsRef =
        await databaseRouter.getMessagesReference(currentUserId, otherUserId);
  }

  Future sendMessage() async {
    if (textController.text.isNotEmpty) {
      if (textController.text.length < 80) {
        try {
          return chatsRef.doc().set(
            {
              "message_content": textController.text,
              "sender_id": currentUserId,
              // "imageUrl": user?.photoURL,
              "timestamp": FieldValue.serverTimestamp(),
            },
          ).then(
            (value) => {
              textController.clear(),
            },
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$e'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Must be 80 characters or less'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Message can't be empty"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.5),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width * 0.95,
        decoration: BoxDecoration(
            color: const Color(0xff161616),
            boxShadow: const [boxShadow],
            borderRadius: BorderRadius.circular(10.0)),
        child: Align(
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  constraints: const BoxConstraints(
                    maxWidth: 275,
                  ),
                  child: TextField(
                    cursorColor: Colors.lightBlue,
                    controller: textController,
                    textAlign: TextAlign.left,
                    textAlignVertical: TextAlignVertical.center,
                    style: inputText,
                    keyboardType: TextInputType.text,
                    onEditingComplete: sendMessage,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0xff212121),
                      border: outlineBorder,
                      enabledBorder: roundedBorder,
                      labelStyle: placeholder,
                      labelText: 'Enter message',
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      contentPadding: EdgeInsets.only(
                        left: 20.0,
                        right: 10.0,
                        top: 0.0,
                        bottom: 0.0,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0, bottom: 3.0),
                child: SizedBox(
                  height: 45,
                  width: 50,
                  child: FloatingActionButton(
                    onPressed: sendMessage,
                    elevation: 8.0,
                    backgroundColor: Colors.lightBlue,
                    child: const Center(
                      child: Icon(
                        Icons.send,
                        size: 30.0,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
