import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Widgets/Styles.dart';

//DONE

class SessionCard extends StatelessWidget {
  final Session session;
  final UserType userType;

  SessionCard({
    required this.session,
    required this.userType,
  });

  @override
  Widget build(BuildContext context) {
    String title = userType == UserType.Therapist
        ? session.patient.fullNameDisplay(true)
        : session.therapist.fullNameDisplay(true);

    String time =
        '${DateFormat('h:mma').format(session.getSessionStartTime())} - ${DateFormat('h:mma').format(session.getSessionEndTime())}';

    return Card(
      color: Color.fromARGB(255, 225, 172, 101),
      child: ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Time: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: time,
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            if (session.additionalInfo != null) ...[
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Notes: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: session.additionalInfo!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            ],
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Rescheduled Weekly: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: session.isWeekly ? 'Yes' : 'No',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: userType == UserType.Therapist
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Styles.lightGrey,
                onSelected: (value) {
                  // Implement edit or remove logic
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit Session'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'remove',
                    child: Text('Remove Session'),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
