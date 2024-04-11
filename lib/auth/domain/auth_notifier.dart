import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends StateNotifier<bool> {
  AuthNotifier() : super(false);

  void login() {
    state = true;
  }

  void logout() {
    state = false;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier();
});
