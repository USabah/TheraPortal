import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';

class GoogleDriveRouter {
  late final drive.DriveApi driveApi;
  bool initialized = false;

  Future<void> initializeDriveApi() async {
    if (!initialized) {
      // Load credentials from the JSON file
      final jsonString =
          await rootBundle.loadString('assets/GoogleDriveCredentials.json');
      final credentials =
          ServiceAccountCredentials.fromJson(json.decode(jsonString));

      // Authenticate with Google Drive API using the loaded credentials
      final client = await clientViaServiceAccount(
          credentials, [drive.DriveApi.driveScope]);
      driveApi = drive.DriveApi(client);
      initialized = true;
    }
  }

  Future<void> listFiles() async {
    await initializeDriveApi();
    try {
      // Retrieve a list of files from Google Drive
      final files = await driveApi.files.list();

      // Print information about each file
      for (var file in files.files!) {
        print('File Name: ${file.name}, File ID: ${file.id}');
      }
    } catch (e) {
      print('Error retrieving files: $e');
    }
  }

  Future<Uint8List?> getGifContent(String fileName) async {
    await initializeDriveApi();
    try {
      // Search for the file with the specified name
      final response = await driveApi.files.list(q: "name = '$fileName'");
      if (response.files != null && response.files!.isNotEmpty) {
        // Get the file ID of the first matching file
        final fileId = response.files!.first.id;
        // Fetch the content of the file
        final drive.Media fileMedia = await driveApi.files.get(
          fileId!,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        // Read the content of the file from the stream
        final List<int> contentBytes = [];
        await for (var chunk in fileMedia.stream) {
          contentBytes.addAll(chunk);
        }

        return Uint8List.fromList(contentBytes);
      } else {
        print('File not found: $fileName');
        return null;
      }
    } catch (e) {
      print('Error retrieving file content: $e');
      return null;
    }
  }
}
