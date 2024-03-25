import 'package:flutter/material.dart';
import 'package:test/auth/screens/auth_screen.dart';

// ignore: use_key_in_widget_constructors
class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
      ),
      backgroundColor: const Color.fromARGB(255, 22, 79, 148),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(
              child: Align(
            alignment: Alignment.center,
            child: Text(
              'APP',
              style: TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 50,
                  color: Color.fromARGB(255, 245, 245, 245)),
            ),
          )),
          Container(
            width: double.infinity,
            alignment: Alignment.bottomCenter,
            child: Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 245, 245, 245),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35.0),
                  topRight: Radius.circular(35.0),
                ),
              ),
              width: 395,
              height: 300,
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Добро пожаловать!',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Начало работы с учетной записью',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AuthScreen()),
                      );
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
          )
        ],
      ),
    );
  }
}
