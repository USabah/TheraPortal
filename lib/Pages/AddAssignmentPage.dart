import 'package:flutter/material.dart';
import 'package:theraportal/Objects/TheraportalUser.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;

  const Body({super.key, required this.currentUser, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(
        currentUser: currentUser,
        mapData: mapData,
      ),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;

  const LargeScreen(
      {super.key, required this.currentUser, required this.mapData});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late TheraportalUser currentUser;
  late String accountReferenceCode;
  late String referenceCodeInput = "";
  late UserType assignmentType;
  bool isLoading = false;
  String? errorText;
  DatabaseRouter databaseRouter = DatabaseRouter();
  TextEditingController referenceInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser;
    accountReferenceCode = currentUser.referenceCode;
    assignmentType = (currentUser.userType == UserType.Patient)
        ? UserType.Therapist
        : UserType.Patient;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add a $assignmentType"),
      ),
      body: Center(
        child: (isLoading)
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add a ${assignmentType.toString().toLowerCase()} by entering their account reference code or giving them your account reference code.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 50),
                  // Display the account reference code
                  const Text(
                    "YOUR ACCOUNT REFERENCE CODE",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      accountReferenceCode.length,
                      (index) => AccountReferenceCodeBlock(
                        character: accountReferenceCode[index],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Input field for entering the account reference code
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextFormField(
                      controller: referenceInputController,
                      maxLength: 6,
                      decoration: InputDecoration(
                          labelText: 'Enter account reference code',
                          border: const OutlineInputBorder(),
                          errorText: errorText),
                      onChanged: (_) {
                        setState(() {
                          errorText = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add patient/therapist button
                  ElevatedButton(
                    style: referenceInputController.text.length == 6
                        ? const ButtonStyle()
                        : const ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(Styles.lightGrey)),
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      referenceCodeInput =
                          referenceInputController.text.toUpperCase();
                      var result = await databaseRouter
                          .createAssignmentFromReferenceCode(currentUser.id,
                              referenceCodeInput, assignmentType);
                      if (result is String) {
                        setState(() {
                          errorText = result;
                          isLoading = false;
                        });
                      } else {
                        //successful
                        TheraportalUser assignedUser =
                            result as TheraportalUser;
                        referenceCodeInput = "";
                        referenceInputController.text = "";
                        //update mapData
                        widget.mapData.add(await databaseRouter
                            .getSingleUserCardInfo(assignedUser));
                        setState(() {
                          isLoading = false;
                        });
                        alertFunction(
                            context: context,
                            title: "Success",
                            content:
                                "Successfully assigned ${assignedUser.fullNameDisplay(true)} as a ${assignmentType.toString().toLowerCase()} to your account!",
                            onPressed: () => Navigator.of(context).pop(),
                            btnText: "Ok",
                            isDismissable: true);
                      }
                    },
                    child: Text(
                        'Add ${currentUser.userType == UserType.Patient ? 'Therapist' : 'Patient'}',
                        style: referenceInputController.text.length == 6
                            ? const TextStyle()
                            : const TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
      ),
    );
  }
}

class AddAssignmentPage extends StatelessWidget {
  static const Key pageKey = Key("Add Assignment Page");
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;

  const AddAssignmentPage(
      {super.key, required this.currentUser, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        currentUser: currentUser,
        mapData: mapData,
      ),
    );
  }
}
