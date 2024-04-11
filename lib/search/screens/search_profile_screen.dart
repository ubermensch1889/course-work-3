import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/search/domain/search_profile_service.dart';
import 'package:test/search/screens/search_calendar.dart';
import 'package:test/user/data/user.dart';

class SearchProfileScreen extends StatelessWidget {
  final String userId;
  final SearchProfileService _userService = SearchProfileService();

  SearchProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Профиль',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<User?>(
        future: _userService.fetchUserById(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || snapshot.data == null) {
            return Center(
                child: Text(
                    'Ошибка: ${snapshot.error ?? "Пользователь не найден"}'));
          }
          return buildUserProfile(snapshot.data!);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => UserCalendarPage(userId: userId),
        )),
        tooltip: 'Открыть календарь',
        child: const FaIcon(
          FontAwesomeIcons.calendar,
          color: Color.fromARGB(255, 245, 245, 245),
        ),
      ),
    );
  }

  Widget buildUserProfile(User user) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
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
            const SizedBox(height: 15),
            Text(
              '${user.name} ${user.surname} ${user.patronymic ?? ""}',
              style: const TextStyle(fontFamily: 'CeraPro', fontSize: 18),
            ),
            const SizedBox(height: 15),
            Text(
              user.email ?? "email не указан",
              style: const TextStyle(fontFamily: 'CeraPro', fontSize: 16),
            ),
            const SizedBox(height: 25),
            InfoSection(user: user),
          ],
        ),
      ),
    );
  }
}

class InfoSection extends StatelessWidget {
  final User user;

  const InfoSection({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (user.phones != null && user.phones!.isNotEmpty)
          ListTile(
            leading: const FaIcon(FontAwesomeIcons.phone),
            title: Text(user.phones!.join(", "),
                style: const TextStyle(fontFamily: 'CeraPro')),
          ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.cakeCandles),
          title: Text(user.birthday ?? "Дата рождения не указана",
              style: const TextStyle(fontFamily: 'CeraPro')),
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.person),
          title: Text(
              user.team != null
                  ? "Команда: ${user.team}"
                  : "Команда не указана",
              style: const TextStyle(fontFamily: 'CeraPro')),
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.telegram),
          title: Text(user.telegram_id ?? "Телеграм не указан",
              style: const TextStyle(fontFamily: 'CeraPro')),
        ),
        ListTile(
          leading: const FaIcon(FontAwesomeIcons.vk),
          title: Text(user.vk_id ?? "ВК не указан",
              style: const TextStyle(fontFamily: 'CeraPro')),
        ),
      ],
    );
  }
}
