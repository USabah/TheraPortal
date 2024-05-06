import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:theraportal/Objects/Session.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Widgets/Styles.dart';

class SessionCard extends StatefulWidget {
  final Session session;
  final UserType userType;
  final Future<void> Function(BuildContext context, Session sessionToEdit)
      onUpdateSession;
  final Future<void> Function(Session sessionToRemove) onRemoveSession;

  const SessionCard({
    super.key,
    required this.session,
    required this.userType,
    required this.onUpdateSession,
    required this.onRemoveSession,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  @override
  Widget build(BuildContext context) {
    String title = widget.userType == UserType.Therapist
        ? widget.session.patient.fullNameDisplay(true)
        : widget.session.therapist.fullNameDisplay(true);

    String time =
        '${DateFormat('h:mma').format(widget.session.getSessionStartTime())} - ${DateFormat('h:mma').format(widget.session.getSessionEndTime())}';

    return Card(
      color: const Color.fromARGB(255, 225, 172, 101),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.userType == UserType.Patient)
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Therapist Type: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: widget.session.therapist.therapistType,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
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
            if (widget.session.additionalInfo != null)
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Notes: ',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    TextSpan(
                      text: widget.session.additionalInfo!,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ],
                ),
              ),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Rescheduled Weekly: ',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  TextSpan(
                    text: widget.session.isWeekly ? 'Yes' : 'No',
                    style: const TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: widget.userType == UserType.Therapist
            ? PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Styles.lightGrey,
                onSelected: (value) async {
                  // Implement edit or remove logic
                  if (value == 'edit') {
                    await widget.onUpdateSession(context, widget.session);
                    //if edited the session list page updates state
                  } else {
                    bool toRemove = await showDialog(
                      context: context,
                      barrierDismissible: true,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Remove Session?"),
                          backgroundColor: Colors.grey.shade400,
                          content: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Are you sure you would like to remove this session?",
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Close"),
                            ),
                            TextButton(
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.red)),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text(
                                "Remove",
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    if (toRemove) {
                      await widget.onRemoveSession(widget.session);
                    }
                    //if removed, the session list page updates state
                  }
                  // setState(() {});
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
