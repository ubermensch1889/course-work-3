import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/chat/domain/chat_creation_service.dart';
import 'package:test/search/domain/search_profile_service.dart';
import 'package:test/search/screens/search_calendar.dart';
import 'package:test/user/data/user.dart';

import '../../chat/screens/chat_screen.dart';

class SearchProfileScreen extends StatelessWidget {
  final String userId;
  final SearchProfileService _userService = SearchProfileService();
  final ChatCreationService _chatCreationService = ChatCreationService();

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
                'Ошибка: ${snapshot.error ?? "Пользователь не найден"}',
                style: const TextStyle(
                  fontFamily: 'CeraPro',
                  fontSize: 16,
                ),
              ));
            }
            return buildUserProfile(snapshot.data!);
          },
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: 'chat',
              backgroundColor: const Color.fromARGB(255, 22, 79, 148),
              onPressed: () => _openChatScreen(context),
              tooltip: 'Открыть чат',
              child: const FaIcon(
                FontAwesomeIcons.pen,
                color: Color.fromARGB(255, 245, 245, 245),
              ),
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: 'calendar',
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
          ],
        ));
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

  Future<void> _openChatScreen(BuildContext context) async {
    var user = await _userService.fetchUserById(userId);
    if (user == null) {
      throw Exception('Error while fetching userdata');
    }
    var chat = await _chatCreationService.getChatWithEmployee(user.id);
    if (chat != null) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              chatId: chat.chatId,
              chatName: user.getFullName(),
              photoUrl: user.photo_link,
              anotherUserId: user.id,
              doublePop: true,
            );
          },
        ),
      );
    } else {
      print('asdasdasdasdasdas');
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              chatName: user.getFullName(),
              photoUrl: user.photo_link,
              anotherUserId: user.id,
              doublePop: true,
            );
          },
        ),
      );
    }
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
          buildListTile(context, "Телефоны: ", user.phones!.join(", "),
              FontAwesomeIcons.phone),
        buildListTile(context, "Дата рождения: ", user.birthday ?? "Не указана",
            FontAwesomeIcons.cakeCandles),
        buildListTile(context, "Команда: ", user.team ?? "Не указана",
            FontAwesomeIcons.users),
        buildListTile(context, "Телеграм: ", user.telegram_id ?? "Не указан",
            FontAwesomeIcons.telegram),
        buildListTile(
            context, "ВК: ", user.vk_id ?? "Не указан", FontAwesomeIcons.vk),
      ],
    );
  }

  Widget buildListTile(
      BuildContext context, String leadingText, String text, IconData icon) {
    return ListTile(
      leading: FaIcon(icon, size: 20),
      title: Row(
        children: [
          Text(leadingText,
              style: const TextStyle(
                  fontFamily: 'CeraPro', fontWeight: FontWeight.bold)),
          Expanded(
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: text)).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$text скопирован в буфер обмена'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                });
              },
              child: Text(text, style: const TextStyle(fontFamily: 'CeraPro')),
            ),
          ),
        ],
      ),
    );
  }
}
