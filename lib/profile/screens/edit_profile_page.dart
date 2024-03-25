import 'package:flutter/material.dart';
import 'package:test/profile/domain/profile_manager.dart';
import 'package:test/user/data/user_profile_update.dart';

class EditProfilePage extends StatefulWidget {
  final Function onUpdate;

  const EditProfilePage({Key? key, required this.onUpdate}) : super(key: key);

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final ProfileManager _profileManager = ProfileManager();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _telegramIdController = TextEditingController();
  final TextEditingController _vkIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileAndUpdateUI();
  }

  void fetchProfileAndUpdateUI() async {
    var user = await _profileManager.fetchUserProfile();
    if (user != null) {
      setState(() {
        _emailController.text = user.email ?? '';
        _birthdayController.text = user.birthday ?? '';
        _telegramIdController.text = user.telegram_id ?? '';
        _vkIdController.text = user.vk_id ?? '';
      });
    }
  }

  void saveProfile() async {
    UserProfileUpdate update = UserProfileUpdate(
      email: _emailController.text,
      birthday: _birthdayController.text,
      telegram_id: _telegramIdController.text,
      vk_id: _vkIdController.text,
    );

    bool success = await _profileManager.saveUserProfile(update);
    if (success) {
      widget.onUpdate();
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Уведомление'),
            content: const Text('Профиль успешно обновлен.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Не удалось обновить профиль.'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Редактировать профиль',
          style: TextStyle(
              fontFamily: 'CeraPro', fontSize: 26, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _birthdayController,
              decoration: const InputDecoration(labelText: 'День рождения'),
            ),
            TextField(
              controller: _telegramIdController,
              decoration: const InputDecoration(labelText: 'Telegram ID'),
            ),
            TextField(
              controller: _vkIdController,
              decoration: const InputDecoration(labelText: 'VK ID'),
            ),
            TextButton(
              onPressed: saveProfile,
              child: const Text(
                'Сохранить',
                style: TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 18,
                  color: Color.fromARGB(255, 22, 79, 148),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
