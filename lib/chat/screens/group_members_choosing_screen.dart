import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_list_service.dart';

import '../../search/domain/search_service.dart';
import '../../user/data/user.dart';
import '../data/chat.dart';
import 'group_creation_screen.dart';

class GroupMembersChoosingScreen extends StatefulWidget {
  const GroupMembersChoosingScreen({super.key});

  @override
  GroupMembersChoosingScreenState createState() =>
      GroupMembersChoosingScreenState();
}

class GroupMembersChoosingScreenState
    extends State<GroupMembersChoosingScreen> {
  final SearchService _searchService = SearchService();
  final ChatListService _chatListService = ChatListService();

  List<SuggestedUser> _chosenUsers = [];
  List<SuggestedUser> _suggestedUsers = [];
  List<SuggestedUser> _initialUsers = [];

  bool _isLoading = true;
  final TextEditingController _controller = TextEditingController();

  Future<void> _initSuggestedUsers() async {
    // TODO: добавить обработку групповых чатов, чтобы они тут не отображались
    var chatUsersRaw = await _chatListService.fetchChats();
    List<SuggestedUser> chatUsers = [];

    // for (final user in chatUsersRaw) {
    //   // TODO: исправить на нормальный юзер айди
    //   chatUsers.add(SuggestedUser(name: user.chatName, userId: user.chatId));
    // }

    if (_initialUsers.isEmpty) {
      _initialUsers = chatUsers;
    }

    setState(() {
      _isLoading = false;
      _suggestedUsers = chatUsers;
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

    var suggestedUsersRaw = await _searchService.suggestUsers(text);
    List<SuggestedUser> suggestedUsers = [];

    for (final userRaw in suggestedUsersRaw) {
      suggestedUsers
          .add(SuggestedUser(name: userRaw.name, userId: userRaw.id));
    }

    setState(() {
      _suggestedUsers = suggestedUsers;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initSuggestedUsers();
    _controller.addListener(() async {
      await _updateSuggestedUsers(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildChosenUserChip(SuggestedUser user) {
    return InkWell(
      child: Stack(children: [
        // Flexible(
        //   child:
          Container(
              width: 120,
              height: 40,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 122, 145, 184),
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: Row(children: [
                const SizedBox(
                  width: 40,
                ),
                Text(user.name,
                    style: const TextStyle(fontSize: 14, color: Colors.black)),
              ])),
        // ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade700,
          child: Text(
            user.name.substring(0, 1),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ]),
      onTap: () {
        setState(() {
          _chosenUsers.remove(user);
        });
      },
    );
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
          'Создать групповой чат',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            constraints: const BoxConstraints(
              maxHeight: 90.0,
            ),
            child: SingleChildScrollView(
                child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: _chosenUsers.map((item) {
                  return _buildChosenUserChip(item);
                }).toList(),
              ),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Кого бы Вы хотели пригласить?',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_chosenUsers.isEmpty) {
            _showNotEnoughUsersDialog();
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => GroupCreationScreen(users: _chosenUsers),
            ),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.arrow_forward, size: 30),
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
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade700,
            child: Text(
              user.name.substring(0, 1),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(user.name),
          subtitle: Text(user.name),
          trailing: Checkbox(
            value: _chosenUsers.contains(user), // Example selected item
            onChanged: (value) {
              if (value!) {
                setState(() {
                  _chosenUsers.add(user);
                });
              } else {
                setState(() {
                  _chosenUsers.remove(user);
                });
              }
            },
          ),
        );
      },
    );
  }

  Future<void> _showNotEnoughUsersDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выберите участника чата.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Закрыть'),
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
