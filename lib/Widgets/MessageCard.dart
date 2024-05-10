import 'package:flutter/material.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
// import 'package:intl/intl.dart';
import 'package:theraportal/Pages/CommunicationPage.dart'; // Import for date formatting

class MessagesCard extends StatefulWidget {
  final String firstName;
  final String lastName;
  final UserType userType;
  String? lastMessageContent;
  final bool sentByCurrentUser;
  final DateTime? messageTimestamp;
  final String withUserId;

  MessagesCard({
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
  State<MessagesCard> createState() => _MessagesCardState();
}

class _MessagesCardState extends State<MessagesCard> {
  @override
  Widget build(BuildContext context) {
    String cardTitle;
    Widget subtitle;

    if (widget.userType == UserType.Patient) {
      cardTitle = '${widget.firstName} ${widget.lastName}';
    } else {
      cardTitle = '${widget.firstName} ${widget.lastName[0]}.';
    }

    //determine subtitle based on last message content and sender
    if (widget.lastMessageContent != null) {
      if (widget.sentByCurrentUser) {
        subtitle = RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'You:',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // Bold style
                ),
              ),
              TextSpan(
                text: ' ${widget.lastMessageContent}',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ), // Rest of the text
            ],
          ),
        );
      } else {
        subtitle = RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${widget.firstName}:',
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold, // Bold style
                ),
              ), // Text before the colon
              TextSpan(
                text: ' ${widget.lastMessageContent}',
                style: const TextStyle(
                  color: Colors.black,
                ),
              ), // Rest of the text
            ],
          ),
        );
      }
    } else {
      subtitle = Text('Click here to message ${widget.firstName}');
    }

    //format message timestamp for display
    String formattedTimestamp = widget.messageTimestamp != null
        // ? DateFormat('EEEE \'at\' h:mm a (M/d/yy)').format(messageTimestamp!)
        ? formatTimestamp(widget.messageTimestamp!)
        : '';

    return Card(
      color: const Color.fromARGB(255, 248, 221, 169),
      child: ListTile(
        title: Text(
          cardTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: subtitle,
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.messageTimestamp != null)
              Text(
                formattedTimestamp,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
          ],
        ),
        onTap: () async {
          widget.lastMessageContent = await Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => CommunicationPage(
                      withUserId: widget.withUserId, name: cardTitle)));
          setState(() {});
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
