import 'package:test/user/data/user.dart';
import 'package:test/user/data/user_action.dart';
import 'package:test/user/domain/user_preferences.dart';

class UserPreferencesWrapper {
  Future<void> saveToken(String token) async {
    await UserPreferences.saveToken(token);
  }

  Future<String?> getToken() async {
    return UserPreferences.getToken();
  }

  Future<void> saveRole(String role) async {
    await UserPreferences.saveRole(role);
  }

  Future<String?> getRole() async {
    return UserPreferences.getRole();
  }

  Future<void> logout() async {
    await UserPreferences.logout();
  }

  Future<User> fetchProfileInfo() async {
    return UserPreferences.fetchProfileInfo();
  }

  Future<User> fetchUserInfoById(String userId) async {
    return UserPreferences.fetchUserInfoById(userId);
  }

  Future<List<UserAction>> fetchUserActions(
      String from, String to, String? employeeId) async {
    return UserPreferences.fetchUserActions(from, to, employeeId);
  }
}
