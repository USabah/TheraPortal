import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
// import 'package:intl/intl.dart';
import 'package:theraportal/Pages/CommunicationPage.dart'; // Import for date formatting

class MessagesCard extends StatelessWidget {
  final String firstName;
  final String lastName;
  final UserType userType;
  final String? lastMessageContent;
  final bool sentByCurrentUser;
  final DateTime? messageTimestamp;
  final String withUserId;

  const MessagesCard({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.userType,
    required this.withUserId,
    this.lastMessageContent,
    this.sentByCurrentUser = false,
    this.messageTimestamp,
  });

  @override
  Widget build(BuildContext context) {
    String cardTitle;
    String subtitle;

    if (userType == UserType.Patient) {
      cardTitle = '$firstName $lastName';
    } else {
      cardTitle = '$firstName ${lastName[0]}.';
    }

    //determine subtitle based on last message content and sender
    if (lastMessageContent != null) {
      if (sentByCurrentUser) {
        subtitle = 'You: $lastMessageContent';
      } else {
        subtitle = '$firstName: $lastMessageContent';
      }
    } else {
      subtitle = 'Click here to message $firstName';
    }

    //format message timestamp for display
    String formattedTimestamp = messageTimestamp != null
        // ? DateFormat('EEEE \'at\' h:mm a (M/d/yy)').format(messageTimestamp!)
        ? formatTimestamp(messageTimestamp!)
        : '';

    return Card(
      child: ListTile(
        title: Text(cardTitle),
        subtitle: Text(subtitle),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (messageTimestamp != null)
              Text(
                formattedTimestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  CommunicationPage(withUserId: withUserId, name: cardTitle)));
        },
      ),
    );
  }

  String formatTimestamp(DateTime timestamp) {
    DateTime now = DateTime.now();
    Duration difference = now.difference(timestamp);

    if (difference.inDays < 7) {
      // If within the past week
      if (now.day == timestamp.day &&
          now.month == timestamp.month &&
          now.year == timestamp.year) {
        // If today
        return 'Today ${_formatTime(timestamp)}';
      } else {
        // Otherwise, show day of the week and time
        return '${_formatDay(timestamp)} at ${_formatTime(timestamp)}';
      }
    } else {
      // If more than a week ago, show full date and time
      return '${_formatDate(timestamp)} at ${_formatTime(timestamp)}';
    }
  }

  String _formatDay(DateTime timestamp) {
    const List<String> weekdays = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];
    return weekdays[timestamp.weekday - 1];
  }

  String _formatDate(DateTime timestamp) {
    return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
  }

  String _formatTime(DateTime timestamp) {
    String period = timestamp.hour >= 12 ? 'PM' : 'AM';
    int hour = timestamp.hour % 12 == 0 ? 12 : timestamp.hour % 12;
    String minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute$period';
  }
}
