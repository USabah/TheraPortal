import 'package:flutter/material.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/ExerciseAssignment.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class ExerciseFullView extends StatefulWidget {
  final Exercise exercise;
  final String? instructions;
  final TheraportalUser therapist;
  final TheraportalUser patient;
  final void Function(
      {String? exerciseId,
      ExerciseAssignment? exerciseAssignment,
      required String patientId,
      required bool removeAssignment})? updateExerciseAssignments;
  final bool isCreationView;
  final bool isTherapist;

  const ExerciseFullView({
    super.key,
    required this.exercise,
    this.instructions,
    required this.therapist,
    required this.patient,
    required this.updateExerciseAssignments,
    required this.isCreationView,
    required this.isTherapist,
  });

  @override
  State<ExerciseFullView> createState() => _ExerciseFullViewState();
}

class _ExerciseFullViewState extends State<ExerciseFullView> {
  late bool isLoading;
  GoogleDriveRouter googleDriveRouter = GoogleDriveRouter();
  DatabaseRouter databaseRouter = DatabaseRouter();

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = widget.exercise.fileName != null &&
          widget.exercise.mediaContent == null;
    });

    if (isLoading) {
      _getMedia();
    }
  }

  void _getMedia() async {
    widget.exercise.mediaContent =
        await googleDriveRouter.getMediaContent(widget.exercise.fileName!);
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? secondaryMusclesText;
    if (widget.exercise.secondaryMuscles != null &&
        widget.exercise.secondaryMuscles!.isNotEmpty) {
      secondaryMusclesText = widget.exercise.secondaryMuscles!.join(', ');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Details'),
      ),
      body: (isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.exercise.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.exercise.mediaContent != null) ...[
                      _buildTopRoundedContainer(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.95,
                          color: const Color.fromARGB(255, 222, 220, 255),
                          padding: const EdgeInsets.all(8),
                          child: Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.80,
                              decoration: BoxDecoration(
                                color: Colors.white, // Color for the media box
                                border: Border.all(
                                    color: Colors.black), // Black border
                              ),
                              child: MediaPreviewWidget(
                                mediaContent: widget.exercise.mediaContent,
                                mediaPath: widget.exercise.fileName!,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 20,
                        color: const Color.fromARGB(255, 222, 220, 255),
                      )
                    ],
                    if (widget.instructions != null &&
                        widget.instructions!.trim() != "")
                      _buildDetail(
                        'Therapist\'s Instructions:',
                        widget.instructions!.trim(),
                        context,
                      ),
                    _buildDetail(
                      'Exercise Description:',
                      widget.exercise.exerciseDescription.trim(),
                      context,
                    ),
                    _buildBottomRoundedContainer(
                      child: ExerciseDetailsGrid(
                        exercise: widget.exercise,
                        secondaryMusclesText: secondaryMusclesText,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Go Back'),
                        ),
                        if (widget.isCreationView)
                          ElevatedButton(
                            onPressed: () async {
                              //show instruction dialog
                              Map<String, dynamic>? result =
                                  await showDialog<Map<String, dynamic>>(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const InstructionDialog(),
                              );

                              //if result is null or isCancelled is true, return
                              if (result == null || result["isCancelled"]) {
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });

                              String? instructions = result["instructions"];

                              //create ExerciseAssignment
                              ExerciseAssignment exerciseAssignment =
                                  ExerciseAssignment(
                                exercise: widget.exercise,
                                patient: widget.patient,
                                therapist: widget.therapist,
                                dateCreated: DateTime.now(),
                                instructions: instructions,
                              );

                              //add to DB
                              bool success = await databaseRouter
                                  .addExerciseAssignment(exerciseAssignment);

                              setState(() {
                                isLoading = false;
                              });

                              if (success) {
                                //use callback function to add it to list of exerciseAssignments for the user
                                widget.updateExerciseAssignments!(
                                    exerciseAssignment: exerciseAssignment,
                                    patientId: widget.patient.id,
                                    removeAssignment: false);

                                alertFunction(
                                    context: context,
                                    title: "Success",
                                    content:
                                        "Exercise Assignment successfully added to patient.",
                                    onPressed: () => Navigator.of(context)
                                      ..pop()
                                      ..pop()
                                      ..pop(),
                                    btnText: "Ok");
                              } else {
                                alertFunction(
                                    context: context,
                                    title: "Error",
                                    content:
                                        "Could not assign exercise to patient at this time. Please try again later",
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    btnText: "Ok");
                              }
                            },
                            child: const Text('Assign Exercise'),
                          )
                        else if (widget.isTherapist)
                          ElevatedButton(
                              onPressed: () async {
                                bool confirmRemove = await showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Remove Assignment'),
                                      content: Text(
                                        'Are you sure you want to remove ${widget.patient.fullNameDisplay(false)}\'s assigned exercise?',
                                        style: const TextStyle(
                                            color: Colors.black),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context,
                                                false); // Return false for cancel
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context,
                                                true); // Return true for remove
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmRemove) {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  bool success = await databaseRouter
                                      .removeExerciseAssignment(
                                          widget.exercise.id!,
                                          widget.patient.id,
                                          widget.therapist.id);
                                  // Call databaseRouter function to remove exercise assignment
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (success) {
                                    widget.updateExerciseAssignments!(
                                        exerciseId: widget.exercise.id,
                                        patientId: widget.patient.id,
                                        removeAssignment: true);

                                    alertFunction(
                                        context: context,
                                        title: "Success",
                                        content:
                                            "Assigned exercise successfully removed.",
                                        onPressed: () => Navigator.of(context)
                                          ..pop()
                                          ..pop()
                                          ..pop(),
                                        btnText: "Ok");
                                  } else {
                                    alertFunction(
                                        context: context,
                                        title: "Error",
                                        content:
                                            "Could not remove exercise assignment from patient at this time. Please try again later",
                                        onPressed: () =>
                                            Navigator.of(context).pop(),
                                        btnText: "Ok");
                                  }
                                }
                              },
                              style: const ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.red),
                                  textStyle: MaterialStatePropertyAll(
                                      TextStyle(fontWeight: FontWeight.bold))),
                              child: const Text("Remove Assignment"))
                      ],
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTopRoundedContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(8),
      ),
      child: child,
    );
  }

  Widget _buildBottomRoundedContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(8),
      ),
      child: child,
    );
  }
}

class ExerciseDetailsGrid extends StatelessWidget {
  final Exercise exercise;
  final String? secondaryMusclesText;

  const ExerciseDetailsGrid({
    super.key,
    required this.exercise,
    required this.secondaryMusclesText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDetail('Body Part:', exercise.bodyPart, context),
          _buildDetail('Target Muscle:', exercise.targetMuscle, context),
          if (secondaryMusclesText != null)
            _buildDetail('Secondary Muscles:', secondaryMusclesText!, context),
          if (exercise.equipment != null)
            _buildDetail('Equipment:', exercise.equipment!, context)
        ],
      ),
    );
  }
}

Widget _buildDetail(String label, String value, BuildContext context) {
  return Container(
    color: const Color.fromARGB(255, 222, 220, 255),
    padding: const EdgeInsets.all(8),
    child: RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
              color: Colors.black,
            ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              decoration: TextDecoration.none, // Remove underline
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.normal,
              decoration: TextDecoration.none, // Remove underline
            ),
          ),
        ],
      ),
    ),
  );
}

class InstructionDialog extends StatefulWidget {
  const InstructionDialog({super.key});

  @override
  _InstructionDialogState createState() => _InstructionDialogState();
}

class _InstructionDialogState extends State<InstructionDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Instructions (optional)'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(hintText: 'Instructions'),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Return empty string and true to indicate cancellation
            Navigator.of(context)
                .pop({"instructions": "", "isCancelled": true});
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Return instructions entered and false to indicate not cancelled
            Navigator.of(context)
                .pop({"instructions": _controller.text, "isCancelled": false});
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
