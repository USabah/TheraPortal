import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/AuthRouter.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';

class RemoveAssignmentDialog extends StatefulWidget {
  final List<Map<String, dynamic>> mapData;
  final UserType currentUserType;

  const RemoveAssignmentDialog(
      {super.key, required this.mapData, required this.currentUserType});

  @override
  _RemoveAssignmentDialogState createState() => _RemoveAssignmentDialogState();
}

class _RemoveAssignmentDialogState extends State<RemoveAssignmentDialog> {
  String? selectedAssignmentId;
  String? fullNameField;
  bool canRemove = false;
  late String assignmentTypeString;
  late TheraportalUser assignment;

  @override
  void initState() {
    super.initState();
    assignmentTypeString = widget.currentUserType == UserType.Therapist
        ? UserType.Patient.toString()
        : UserType.Therapist.toString();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey.shade300,
      title: Text('Remove Assigned $assignmentTypeString'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
                labelText: 'Select $assignmentTypeString',
                labelStyle: const TextStyle(color: Colors.black)),
            value: selectedAssignmentId,
            items: widget.mapData.map((Map<String, dynamic> map) {
              assignment = map[assignmentTypeString.toLowerCase()];
              return DropdownMenuItem<String>(
                value: assignment.id,
                child: Text(assignment.fullNameDisplay(true)),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                selectedAssignmentId = value;
                fullNameField = null;
                canRemove = false;
              });
            },
          ),
          if (selectedAssignmentId != null)
            TextFormField(
              decoration: InputDecoration(
                  labelText:
                      'Type "${assignment.fullNameDisplay(false)}" to confirm.',
                  labelStyle: const TextStyle(color: Colors.red, fontSize: 16)),
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                bool currentCanRemoveVal = canRemove;
                fullNameField = value;
                canRemove = fullNameField == assignment.fullNameDisplay(false);
                if (currentCanRemoveVal != canRemove) {
                  setState(() {});
                }
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
            onPressed: canRemove ? () => removeAssignment(context) : null,
            style: ButtonStyle(
                backgroundColor: canRemove
                    ? MaterialStateProperty.all<Color>(Colors.red)
                    : MaterialStateProperty.all<Color>(Colors.grey.shade400)),
            child: Text(
              "Remove",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: canRemove ? FontWeight.w500 : FontWeight.w200),
            )),
      ],
    );
  }

  void removeAssignment(BuildContext context) {
    //Perform the action to remove assigned patient
    if (widget.currentUserType == UserType.Patient) {
      DatabaseRouter()
          .removeAssignment(AuthRouter.getUserUID(), selectedAssignmentId!);
    } else if (widget.currentUserType == UserType.Therapist) {
      DatabaseRouter()
          .removeAssignment(selectedAssignmentId!, AuthRouter.getUserUID());
    }

    widget.mapData.removeWhere((element) =>
        element[assignmentTypeString.toLowerCase()].id == selectedAssignmentId);
    Navigator.of(context).pop(widget.mapData);
  }
}
