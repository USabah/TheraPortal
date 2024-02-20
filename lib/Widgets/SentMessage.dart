import 'package:flutter/material.dart';
import 'widgets.dart';

class SentMessage extends StatelessWidget {
  const SentMessage({
    Key? key,
    required this.data,
  }) : super(key: key);

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(), // Dynamic width spacer
          Container(
            constraints: chatConstraints,
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 5.0,
              bottom: 5.0,
              right: 5.0,
            ),
            decoration: const BoxDecoration(
              gradient: sent,
              borderRadius: round,
            ),
            child: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      data['message_content'],
                      textAlign: TextAlign.right,
                      style: chatText,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  // CircleAvatar(
                  //   radius: 20,
                  //   backgroundImage: NetworkImage(
                  //     data['imageUrl'],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
