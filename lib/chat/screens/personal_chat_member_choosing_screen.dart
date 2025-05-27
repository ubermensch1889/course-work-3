import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_creation_service.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../search/domain/search_service.dart';
import '../../user/data/user.dart';
import '../../user/domain/user_preferences.dart';
import 'chat_screen.dart';
import 'group_creation_screen.dart';

class PersonalChatMemberChoosingScreen extends StatefulWidget {
  final WebSocketChannel channel;

  const PersonalChatMemberChoosingScreen({super.key, required this.channel});

  @override
  PersonalChatMemberChoosingScreenState createState() =>
      PersonalChatMemberChoosingScreenState();
}

class PersonalChatMemberChoosingScreenState
    extends State<PersonalChatMemberChoosingScreen> {
  final SearchService _searchService = SearchService();
  final ChatCreationService _chatCreationService = ChatCreationService();
  late String _userId;
  late VoidCallback _searchListener;

  List<User> _suggestedUsers = [];
  List<User> _initialUsers = [];

  bool _isLoading = true;
  final TextEditingController _controller = TextEditingController();

  Future<void> _getUserId() async {
    _userId = await UserPreferences.getUserId();
  }

  Future<void> _initSuggestedUsers() async {
    _initialUsers = await _chatCreationService.getEmployees();

    setState(() {
      _isLoading = false;
      _suggestedUsers = _initialUsers;
    });
  }

  Future<void> _updateSuggestedUsers(String text) async {
    if (text == '') {
      setState(() {
        _suggestedUsers = _initialUsers;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var suggestedUsers = await _searchService.suggestUsers(text);

    setState(() {
      _suggestedUsers = suggestedUsers;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSuggestedUsers();
    _getUserId();
    _searchListener = () async {
      await _updateSuggestedUsers(_controller.text);
    };
    _controller.addListener(_searchListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_searchListener);
    _controller.dispose();
    super.dispose();
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
            )),
        centerTitle: true,
        title: const Text(
          'Написать сообщение',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Введите имя собеседника',
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(22, 79, 148, 1),
                    width: 3.0,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildSuggestedUsers()),
        ],
      ),
    );
  }

  Widget _buildSuggestedUsers() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_suggestedUsers.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text("Начните вводить имя в поиск"),
        ),
      );
    }

    return ListView.builder(
      itemCount: _suggestedUsers.length,
      itemBuilder: (context, index) {
        var user = _suggestedUsers[index];
        if (user.id == _userId) {
          return null;
        }

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade700,
            backgroundImage:
                user.photo_link != null ? NetworkImage(user.photo_link!) : null,
            child: user.photo_link == null
                ? Text(
                    user.name[0].toUpperCase() + user.surname[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  )
                : null,
          ),
          title: Text('${user.name} ${user.surname}'),
          onTap: () {
            setState(() {
              _isLoading = true;
            });
            _openChatScreen(user);
          },
        );
      },
    );
  }

  Future<void> _openChatScreen(User user) async {
    var chat = await _chatCreationService.getChatWithEmployee(user.id);
    if (chat != null) {
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChatScreen(
                chatId: chat.chatId,
                chatName: user.getFullName(),
                photoUrl: user.photo_link,
                anotherUserId: user.id,
                doublePop: true,
              ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // от правого края экрана
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    } else {
      Navigator.of(context, rootNavigator: true).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              ChatScreen(
                chatName: user.getFullName(),
                photoUrl: user.photo_link,
                anotherUserId: user.id,
                doublePop: true,
              ),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // от правого края экрана
            const end = Offset.zero;
            const curve = Curves.ease;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: curve));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      );
    }
  }
}
