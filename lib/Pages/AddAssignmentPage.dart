import 'package:flutter/material.dart';
import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Widgets/Widgets.dart';

class Body extends StatelessWidget {
  final TheraportalUser currentUser;
  final List<Map<String, dynamic>> mapData;

  const Body({super.key, required this.currentUser, required this.mapData});

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      largeScreen: LargeScreen(currentUser: currentUser),
    );
  }
}

class LargeScreen extends StatefulWidget {
  final TheraportalUser currentUser;

  const LargeScreen({super.key, required this.currentUser});

  @override
  State<LargeScreen> createState() => _LargeScreenState();
}

class _LargeScreenState extends State<LargeScreen> {
  late TheraportalUser currentUser;
  late String accountReferenceCode;
  late String referenceCodeInput = "";
  late UserType assignmentType;

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Add a ${assignmentType.toString().toLowerCase()} by entering their account reference code or giving them your account reference code.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Display the account reference code
            const Text(
              "YOUR ACCOUNT REFERENCE CODE",
              style: TextStyle(fontWeight: FontWeight.w500),
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
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Enter account reference code',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Update the account reference code when input changes
                  setState(() {
                    referenceCodeInput = value.toUpperCase();
                  });
                },
              ),
            ),
            const SizedBox(height: 20),
            // Add patient/therapist button
            ElevatedButton(
              style: referenceCodeInput.length == 6
                  ? const ButtonStyle()
                  : const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(Styles.lightGrey)),
              onPressed: () {
                ///CODE.toUpperCase();
                ///Get the user id of the patient/therapist using their reference code
                ///as long as their type == the expected user type
                // Perform action to add patient/therapist
                // Implement the functionality here
                ///if successful
                //referenceCodeInput = ""
              },
              child: Text(
                  'Add ${currentUser.userType == UserType.Patient ? 'Therapist' : 'Patient'}',
                  style: referenceCodeInput.length == 6
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
