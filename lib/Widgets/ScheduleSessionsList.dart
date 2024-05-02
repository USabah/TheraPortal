import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';

class ScheduledSessionsList extends StatelessWidget {
  final List<Session> sessions;
  final bool fullScheduleView;

  const ScheduledSessionsList(
      {super.key, required this.sessions, required this.fullScheduleView});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: ListTile(
            title: Text(
              'Date: ${DateFormat('MM/dd/yyyy').format(session.dateTime)}',
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time: ${session.dateTime.hour}:${session.dateTime.minute}',
                ),
                const SizedBox(height: 5),
                Text('Notes: ${session.additionalInfo}'),
                const SizedBox(height: 5),
                Text('Weekly Recurrence: ${session.isWeekly ? 'Yes' : 'No'}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
