import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';

class SearchProfileService {
  Future<User?> fetchUserById(String userId) async {
    try {
      return await UserPreferences.fetchUserInfoById(userId);
    } catch (e) {
      // ignore: avoid_print
      print("Error fetching user: $e");
      return null;
    }
  }
}
