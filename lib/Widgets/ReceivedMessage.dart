import 'package:flutter/material.dart';
import 'widgets.dart';

class ReceivedMessage extends StatelessWidget {
  const ReceivedMessage({
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            constraints: chatConstraints,
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 5.0,
              bottom: 5.0,
              right: 10.0,
            ),
            decoration: const BoxDecoration(
              gradient: received,
              borderRadius: round,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // CircleAvatar(
                //   radius: 20,
                //   backgroundImage: NetworkImage(
                //     data['imageUrl'],
                //   ),
                // ),
                const SizedBox(width: 10.0),
                Flexible(
                  child: Text(
                    data['message_content'],
                    textAlign: TextAlign.left,
                    style: chatText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(), // Dynamic width spacer
        ],
      ),
    );
  }
}
