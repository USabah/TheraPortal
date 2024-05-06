import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:theraportal/Objects/Exercise.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Utilities/GoogleDriveRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';
import 'package:video_player/video_player.dart';

class ExerciseCreatorForm extends StatefulWidget {
  final TheraportalUser user;
  final int numExercisesCreated;

  const ExerciseCreatorForm({
    super.key,
    required this.user,
    required this.numExercisesCreated,
  });

  @override
  _ExerciseCreatorFormState createState() => _ExerciseCreatorFormState();
}

class _ExerciseCreatorFormState extends State<ExerciseCreatorForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bodyPartController;
  late TextEditingController _exerciseDescriptionController;
  late TextEditingController _equipmentController;
  late TextEditingController _targetMuscleController;
  late TextEditingController _secondaryMusclesController;
  String? mediaErrorText;
  String? mediaPath;
  String? extension;
  Uint8List? mediaContent;
  bool fileSelector = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bodyPartController = TextEditingController();
    _exerciseDescriptionController = TextEditingController();
    _equipmentController = TextEditingController();
    _targetMuscleController = TextEditingController();
    _secondaryMusclesController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bodyPartController.dispose();
    _exerciseDescriptionController.dispose();
    _equipmentController.dispose();
    _targetMuscleController.dispose();
    _secondaryMusclesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    setState(() {
      isLoading = true;
    });
    if (_formKey.currentState!.validate()) {
      // Perform form submission
      String? filename = (mediaContent == null)
          ? null
          : '${widget.user.id}_${_nameController.text}_${widget.numExercisesCreated}.$extension'
              .replaceAll(' ', '');
      final newExercise = Exercise(
        name: _nameController.text,
        bodyPart: _bodyPartController.text,
        creator: widget.user,
        dateCreated: DateTime.now(),
        exerciseDescription: _exerciseDescriptionController.text,
        equipment: _equipmentController.text,
        fileName: filename,
        targetMuscle: _targetMuscleController.text,
        secondaryMuscles: _secondaryMusclesController.text.isNotEmpty
            ? _secondaryMusclesController.text.split(',')
            : null,
        mediaContent: mediaContent,
      );
      //store the new exercise in Firestore or handle it as required
      String? id = await DatabaseRouter().addExercise(newExercise);
      //upload media file if it exists
      if (mediaContent != null) {
        await GoogleDriveRouter().uploadExerciseFile(mediaContent!, filename!);
      }
      setState(() {
        isLoading = false;
      });
      if (id != null) {
        newExercise.id = id;
        alertFunction(
            context: context,
            title: "Success",
            content: "Successfully created exercise.",
            onPressed: () {
              Navigator.of(context).pop(newExercise);
            },
            btnText: "Ok",
            isDismissable: false);
      }
    }
  }

  bool FieldsAreValid() {
    return _nameController.text != "" &&
        _bodyPartController.text != "" &&
        _exerciseDescriptionController.text != "" &&
        _targetMuscleController.text != "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Exercise'),
      ),
      body: (isLoading)
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _nameController,
                            maxLength: 50,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              labelText: 'Exercise Name',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Styles.beige,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          FieldWidget(
                            label: 'Body Part',
                            value: (_bodyPartController.text != "")
                                ? _bodyPartController.text
                                : "Select Here",
                            onPressed: () {
                              _showOptionPopup(
                                  ExerciseConstants.uniqueBodyParts,
                                  _bodyPartController,
                                  "Body Part");
                            },
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            controller: _exerciseDescriptionController,
                            maxLength: 150,
                            onChanged: (_) {
                              setState(() {});
                            },
                            decoration: const InputDecoration(
                              labelText: 'Exercise Description',
                              labelStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Styles.beige,
                              ),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16.0),
                          FieldWidget(
                            label: 'Equipment',
                            value: (_equipmentController.text != "")
                                ? _equipmentController.text
                                : "Select Here (optional)",
                            onPressed: () {
                              _showOptionPopup(
                                  ExerciseConstants.uniqueEquipment,
                                  _equipmentController,
                                  "Exercise Equipment");
                            },
                          ),
                          const SizedBox(height: 16.0),
                          FieldWidget(
                            label: 'Target Muscle',
                            value: (_targetMuscleController.text != "")
                                ? _targetMuscleController.text
                                : "Select Here",
                            onPressed: () {
                              _showOptionPopup(
                                  ExerciseConstants.uniqueTargetMuscles,
                                  _targetMuscleController,
                                  "Target Muscle");
                            },
                          ),
                          const SizedBox(height: 16.0),
                          FieldWidget(
                            // select up to 3 secondary muscles
                            label: 'Secondary Muscles',
                            value: (_secondaryMusclesController.text != "")
                                ? _secondaryMusclesController.text
                                : "Select Here (optional)",
                            onPressed: _showSecondaryMusclesPopup,
                          ),
                          const SizedBox(height: 16.0),
                          if (fileSelector)
                            FieldWidget(
                                label: "Exercise Media",
                                value: (mediaContent == null)
                                    ? "Select Here (optional)"
                                    : "Reselect Media",
                                errorText: mediaErrorText,
                                onPressed: _pickFile)
                          else
                            FieldWidget(
                                label: "Exercise Media",
                                value: (mediaContent == null)
                                    ? "Select Here (optional)"
                                    : "Reselect Media",
                                errorText: mediaErrorText,
                                onPressed: () async {
                                  final picker = ImagePicker();
                                  final pickedFile = await picker.pickMedia();
                                  if (pickedFile != null) {
                                    // Handle the picked image file
                                    mediaContent =
                                        await pickedFile.readAsBytes();
                                    setState(() {
                                      mediaPath = pickedFile.path;
                                      extension = _getFileExtension(
                                          pickedFile.mimeType!);
                                    });
                                  }
                                }),

                          ///image selector
                          const SizedBox(
                            height: 16,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Select From Files:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Switch(
                                value: fileSelector,
                                onChanged: (value) {
                                  setState(() {
                                    fileSelector = value;
                                  });
                                },
                              ),
                              IconButton(
                                onPressed: _showMediaToggleInfoDialog,
                                icon: const Icon(Icons.help_outline),
                                color: Colors.grey,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          if (mediaContent != null)
                            ElevatedButton(
                              onPressed: _showMediaOptionsDialog,
                              child: const Text('View/Remove Media'),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    style: (FieldsAreValid())
                        ? const ButtonStyle()
                        : const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Colors.grey),
                            textStyle: MaterialStatePropertyAll(
                                TextStyle(fontWeight: FontWeight.w300)),
                          ),
                    onPressed: (FieldsAreValid()) ? _submitForm : null,
                    child: const Text('Submit'),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                )
              ],
            ),
    );
  }

  String _getFileExtension(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'video/mp4':
        return 'mp4';
      case 'video/quicktime':
        return 'mov';
      default:
        return ''; // Handle unsupported MIME types
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'gif', 'jpg', 'png']);
    if (result != null) {
      setState(() {
        mediaErrorText = null;
      });
      PlatformFile file = result.files.first;
      const int maxVideoDuration = 20;
      const int videoBitrateMbps = 8;

      //maximum file size in bytes
      const int maxFileSizeInBytes =
          maxVideoDuration * videoBitrateMbps * 1000000;

      //check file size
      if (file.size > maxFileSizeInBytes) {
        setState(() {
          mediaErrorText = 'Selected file exceeds the maximum allowed size.';
        });
        return;
      }
      //for videos, check the duration
      if (file.extension!.toLowerCase() == 'mp4' ||
          file.extension!.toLowerCase() == 'mov' ||
          file.extension!.toLowerCase() == 'avi' ||
          file.extension!.toLowerCase() == 'mkv') {
        // Get the video duration
        Duration? videoDuration = await _getVideoDuration(file.path!);
        if (videoDuration != null &&
            videoDuration.inSeconds > maxVideoDuration) {
          //video duration exceeds the maximum allowed
          setState(() {
            mediaErrorText =
                'Selected video exceeds the maximum allowed duration (20 seconds).';
          });
          return;
        }
      }
      // Read file contents
      Uint8List? bytes;
      try {
        File fileObject = File(file.path!);
        bytes = await fileObject.readAsBytes();
        setState(() {
          mediaContent = bytes;
          mediaPath = file.path!;
          extension = file.extension;
        });
      } catch (e) {
        print('Error reading file: $e');
      }
    } else {
      //user canceled the picker
    }
  }

  Future<Duration?> _getVideoDuration(String filePath) async {
    try {
      final videoPlayerController = VideoPlayerController.file(File(filePath));
      await videoPlayerController.initialize();
      //retrieve the duration of the video
      Duration duration = videoPlayerController.value.duration;
      await videoPlayerController.dispose();
      return duration;
    } catch (e) {
      print('Error getting video duration: $e');
      return null;
    }
  }

  void _showMediaOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Media')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                child: MediaPreviewWidget(
                  mediaContent: mediaContent,
                  mediaPath: mediaPath,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Go Back'),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      mediaContent = null;
                      mediaPath = null;
                      extension = null;
                    });
                    Navigator.of(context).pop();
                  },
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  child: const Text(
                    'Remove Media',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOptionPopup(
      List<String> options, TextEditingController controller, String label) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[800],
          ),
          child: AlertDialog(
            title: Text(
              'Select $label',
              style: const TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              width: MediaQuery.of(context).size.width * 0.8,
              child: ListView.builder(
                itemCount: options.length + 1, // Add one for "Other" option
                itemBuilder: (BuildContext context, int index) {
                  if (index == options.length) {
                    return GestureDetector(
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'other',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      onTap: () {
                        // Hide the popup and show TextFormField for "Other"
                        Navigator.of(context).pop();
                        _showOtherOptionPopup(options, controller, label);
                      },
                    );
                  } else {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          controller.text = options[index];
                        });
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          options[index],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showOtherOptionPopup(
      List<String> options, TextEditingController controller, String label) {
    String textValue = "";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey[800],
          ),
          child: AlertDialog(
            title: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
            content: TextFormField(
              maxLength: 40,
              onChanged: (value) {
                textValue = value;
              },
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Styles.beige,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showOptionPopup(options, controller, label);
                },
                child: const Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  controller.text = textValue;
                  Navigator.of(context).pop();
                  setState(() {});
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSecondaryMusclesPopup() {
    List<String> selectedOptions = _secondaryMusclesController.text.isNotEmpty
        ? _secondaryMusclesController.text.split(', ')
        : [];
    List<String> newSelectedOptions = List.from(selectedOptions);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter stateSetter) {
            return Theme(
              data: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.grey[800],
              ),
              child: AlertDialog(
                title: const Text(
                  'Select Secondary Muscles',
                  style: TextStyle(color: Colors.white),
                ),
                content: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.4,
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: ListView.builder(
                    itemCount: ExerciseConstants.uniqueSecondaryMuscles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final muscle =
                          ExerciseConstants.uniqueSecondaryMuscles[index];
                      final isChecked = newSelectedOptions.contains(muscle);

                      return CheckboxListTile(
                        title: Text(
                          muscle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        value: isChecked,
                        onChanged: (bool? value) {
                          stateSetter(() {
                            if (value!) {
                              if (newSelectedOptions.length < 3) {
                                newSelectedOptions.add(muscle);
                              } else {
                                // Notify user that only three selections are allowed
                              }
                            } else {
                              newSelectedOptions.remove(muscle);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                        activeColor: Colors.white,
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      stateSetter(() {
                        selectedOptions = List.from(newSelectedOptions);
                        _secondaryMusclesController.text =
                            selectedOptions.join(', ');
                      });
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Confirm',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMediaToggleInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade300,
          title: const Text('Media Type'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    "If toggled on, the media file that you input will be retrieved from your device's files. Otherwise, it will instead access the device's photos.",
                    style: TextStyle(
                      color: Colors.black,
                    ))
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
