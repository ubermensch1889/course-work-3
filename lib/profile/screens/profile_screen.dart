import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/auth/domain/auth_notifier.dart';
import 'package:test/auth/screens/auth_screen.dart';
import 'package:test/profile/domain/profile_service.dart';
import 'package:test/profile/screens/edit_profile_page.dart';
import 'package:test/user/data/user.dart';
import 'package:test/user/domain/user_preferences.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  ProfileContentState createState() => ProfileContentState();
}

class ProfileContentState extends State<ProfileContent> {
  final ProfileService _profileService = ProfileService();
  Future<User?>? _fetchUserFuture;

  @override
  void initState() {
    super.initState();
    _fetchUserFuture = _profileService.fetchUserProfile();
  }

  void updateUserProfile() {
    setState(() {
      _fetchUserFuture = _profileService.fetchUserProfile();
    });
  }

  Future<void> pickAndUploadImage() async {
    final file = await _profileService.pickImage();
    if (file != null) {
      final success = await _profileService.uploadImage(file.path);
      if (success) {
        setState(() {
          _fetchUserFuture = _profileService.fetchUserProfile();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 90,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: const Color.fromRGBO(22, 79, 148, 1),
          ),
        ),
        centerTitle: true,
        title: const Text('Профиль',
            style: TextStyle(
                fontFamily: 'CeraPro',
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              return PopupMenuButton<String>(
                color: Colors.white,
                onSelected: (value) async {
                  switch (value) {
                    case 'edit_profile':
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            EditProfilePage(onUpdate: updateUserProfile),
                      ));
                      break;
                    case 'logout':
                      await UserPreferences.logout();
                      ref.read(authStateProvider.notifier).state = false;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (context) => const AuthScreen()),
                        );
                      });
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'edit_profile',
                      child: Text('Редактировать профиль',
                          style:
                              TextStyle(fontFamily: 'CeraPro', fontSize: 16)),
                    ),
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Выйти',
                          style:
                              TextStyle(fontFamily: 'CeraPro', fontSize: 16)),
                    ),
                  ];
                },
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<User?>(
        future: _fetchUserFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text("Ошибка загрузки данных пользователя"));
          } else if (snapshot.hasData) {
            return buildUserProfile(snapshot.data!);
          } else {
            return const Center(child: Text("Пользователь не найден"));
          }
        },
      ),
    );
  }

  Widget buildUserProfile(User user) {
    double screenWidth = MediaQuery.of(context).size.width;
    double padding = 20.0 * 2;
    double cardWidth = screenWidth - padding;
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundImage: user.photo_link != null
                          ? NetworkImage(user.photo_link!)
                          : null,
                      child: user.photo_link == null
                          ? const Icon(Icons.person, size: 130)
                          : null,
                    ),
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: FloatingActionButton(
                        heroTag: null,
                        mini: true,
                        onPressed: pickAndUploadImage,
                        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Color.fromARGB(255, 245, 245, 245),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  '${user.surname} ${user.name}',
                  style: const TextStyle(fontFamily: 'CeraPro', fontSize: 18),
                ),
                const SizedBox(height: 15),
                Text(
                  '${user.email}',
                  style: const TextStyle(fontFamily: 'CeraPro', fontSize: 16),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildIconInfo(
                      context,
                      FontAwesomeIcons.telegram,
                      'Telegram: ${user.telegram_id}',
                    ),
                    _buildIconInfo(
                      context,
                      FontAwesomeIcons.phone,
                      'Phones: ${user.phones?.join(", ") ?? "Нет телефонов"}',
                    ),
                    _buildIconInfo(
                      context,
                      FontAwesomeIcons.vk,
                      'VK: ${user.vk_id}',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: cardWidth,
            child: Card(
              color: const Color.fromARGB(255, 245, 245, 245),
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'О себе',
                      style: TextStyle(
                        fontFamily: 'CeraPro',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 35),
                    Text(
                      'Команда: ${user.team}',
                      style: const TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 188, 186, 187),
                          decorationThickness: 1),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'День рождения: ${user.birthday}',
                      style: const TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: Color.fromARGB(255, 188, 186, 187),
                          decorationThickness: 2),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  GestureDetector _buildIconInfo(
      BuildContext context, IconData icon, String info) {
    return GestureDetector(
      onTap: () => _showInfo(context, info),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 22, 79, 148),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: FaIcon(
            icon,
            size: 35,
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
      ),
    );
  }

  void _showInfo(BuildContext context, String info) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Информация',
                  style: TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  info,
                  style: const TextStyle(fontFamily: 'CeraPro', fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
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
      },
    );
  }
}
