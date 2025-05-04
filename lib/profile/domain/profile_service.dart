// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:image_picker/image_picker.dart';

class ProfileService {
  Future<User?> fetchUserProfile() async {
    return UserPreferences.fetchProfileInfo();
  }

  Future<String?> getUploadUrl() async {
    String? token = await UserPreferences.getToken();
    if (token == null) {
      print('Error: Authorization token is missing');
      return null;
    }
    var url =
        Uri.parse('https://working-day.su:8080/v1/profile/upload-photo');
    var headers = {'Authorization': 'Bearer $token'};
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['url'];
    } else {
      print('Error getting upload URL: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> uploadImage(String filePath) async {
    var uploadUrl = await getUploadUrl();
    if (uploadUrl == null) {
      print('Upload URL not obtained');
      return false;
    }

    var response = await http.put(Uri.parse(uploadUrl),
        body: await File(filePath).readAsBytes());
    if (response.statusCode == 200) {
      print('Photo uploaded successfully');
      return true;
    } else {
      print('Photo upload error: ${response.statusCode}');
      return false;
    }
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      return File(pickedFile.path);
    } else {
      print('No image selected');
      return null;
    }
  }
}
