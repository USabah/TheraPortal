import 'package:theraportal/Objects/User.dart';
import 'package:theraportal/Utilities/DatabaseRouter.dart';

class FieldValidator {
  String? validateEmailField(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    RegExp emailRegex = RegExp(
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
    if (!emailRegex.hasMatch(value)) {
      return "Please enter a valid email";
    }
    return null;
  }

  //logic handled by firebase registration
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your first name';
    }
    return null;
  }

  Future<String?> organizationCode(String? value, UserType user_type) async {
    DatabaseRouter databaseRouter = DatabaseRouter();
    if (value == null || value.isEmpty) {
      return null;
    }

    //check if organization code exists
    String fieldToCheck;
    switch (user_type) {
      case UserType.Patient:
        fieldToCheck = 'patient_code';
        break;
      case UserType.Therapist:
        fieldToCheck = 'therapist_code';
        break;
      case UserType.Administrator:
        fieldToCheck = 'admin_code';
        break;
    }
    bool exists =
        await databaseRouter.fieldExists('Groups', fieldToCheck, value);
    if (!exists) {
      return "Could not find organization. Please re-enter or leave blank";
    } else {
      return null;
    }
  }
}
