import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/main.dart';
import 'package:test/start/screens/start_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends ConsumerState<AuthScreen> {
  late final TextEditingController loginController;
  late final TextEditingController passwordController;
  late final TextEditingController companyIdController;
  bool passwordVisible = false;

  @override
  void initState() {
    super.initState();
    loginController = TextEditingController();
    passwordController = TextEditingController();
    companyIdController = TextEditingController();
  }

  @override
  void dispose() {
    loginController.dispose();
    passwordController.dispose();
    companyIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const StartScreen()),
          ),
        ),
        centerTitle: true,
        title: const Text(
          'Вход',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'ВВЕДИТЕ ВАШ АДРЕС ЭЛЕКТРОННОЙ ПОЧТЫ',
              style: TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 16,
                  fontWeight: FontWeight.normal),
              textAlign: TextAlign.center,
            ),
            TextField(
              controller: loginController,
              decoration: const InputDecoration(
                hintText: 'Логин',
                hintStyle: TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 18,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 22, 79, 148)),
                ),
              ),
              onChanged: (value) {},
              cursorColor: const Color.fromARGB(255, 22, 79, 148),
            ),
            TextFormField(
              controller: passwordController,
              obscureText: !passwordVisible,
              decoration: InputDecoration(
                  hintText: 'Пароль',
                  hintStyle: const TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 18,
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 22, 79, 148)),
                  ),
                  suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => passwordVisible = !passwordVisible),
                      icon: Icon(
                        passwordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: const Color.fromARGB(255, 22, 79, 148),
                      ))),
              onChanged: (value) {},
              cursorColor: const Color.fromARGB(255, 22, 79, 148),
            ),
            TextField(
              controller: companyIdController,
              decoration: const InputDecoration(
                hintText: 'Компания',
                hintStyle: TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 18,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 22, 79, 148)),
                ),
              ),
              onChanged: (value) {},
              cursorColor: const Color.fromARGB(255, 22, 79, 148),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final success =
                    await ref.read(authManagerProvider).authenticate(
                          loginController.text,
                          passwordController.text,
                          companyIdController.text,
                          ref,
                        );
                if (success) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const MyApp(isAuthenticated: true),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ошибка аутентификации')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                  minimumSize: const Size(336, 40),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              child: const Text(
                'Вход',
                style: TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 18,
                    color: Color.fromARGB(255, 245, 245, 245)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
