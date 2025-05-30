import 'dart:async';

import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_list_service.dart';
import 'package:test/chat/data/chat.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'chat_screen.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  ChatSearchScreenState createState() => ChatSearchScreenState();
}

class ChatSearchScreenState extends State<ChatSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ChatListService _chatListService = ChatListService();
  List<MessengerListedChatInfo> _searchResults = [];
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _getUserId();
    _searchController.addListener(_onSearchChanged);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        // Обновляем UI при смене вкладки тестовый чат 1
      });
    }
  }

  Future<void> _getUserId() async {
    _userId = await UserPreferences.getUserId();
  }

  void _onSearchChanged() {
    _performSearch(_searchController.text);
  }

  void _performSearch(String query) async {
    var results = await _chatListService.searchChats(query);
    setState(() {
      _searchResults = results;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110,
        centerTitle: false,
        leading: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        leadingWidth: 30,
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Поиск',
            hintStyle: TextStyle(color: Colors.grey),
            contentPadding: EdgeInsets.fromLTRB(8, 4, 4, 5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(
                color: Color.fromRGBO(22, 79, 148, 1),
                width: 3,
              ),
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Colors.black,
                indicatorColor: const Color.fromRGBO(22, 79, 148, 1),
                tabs: const [
                  Tab(text: 'Личные чаты', height: 40),
                  Tab(text: 'Групповые чаты', height: 40),
                ],
              ),
              Container(
                height: 1.0,
                color: const Color.fromRGBO(22, 79, 148, 1),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatList(isPersonal: true),
          _buildChatList(isPersonal: false),
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isPersonal}) {
    final filteredChats = _searchResults.where((chat) => 
      isPersonal ? chat.isPersonal() : !chat.isPersonal()
    ).toList();
    
    if (_searchController.text.isEmpty) {
      return const Center(
        child: Text('Введите текст для поиска'),
      );
    }

    if (filteredChats.isEmpty) {
      return Center(
        child: Text(
          isPersonal ? 'Личные чаты не найдены' : 'Групповые чаты не найдены'
        ),
      );
    }

    return ListView.separated(
      itemCount: filteredChats.length,
      separatorBuilder: (context, index) => const Divider(
        color: Color.fromRGBO(256, 256, 256, 0.2),
        thickness: 1,
        height: 0,
        indent: 78,
      ),
      itemBuilder: (context, index) {
        final chat = filteredChats[index];
        return ListTile(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatScreen(
                      chatId: chat.chatId,
                      chatName: chat.getPrettyChatName(),
                      photoUrl: chat.photoUrl,
                      anotherUserId: isPersonal ? chat.getSecondParticipantId(_userId) : null,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
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
          },
          leading: CircleAvatar(
            backgroundImage: chat.photoUrl != null ? NetworkImage(chat.photoUrl!) : null,
            radius: 30,
            child: chat.photoUrl != null
                ? null
                : Text(chat.getPrettyChatName()[0].toUpperCase()),
          ),
          title: Text(
            chat.getPrettyChatName(),
            style: const TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            chat.lastMessage?.content.content ?? 'Нет сообщений',
            style: const TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 14,
              color: Color.fromARGB(200, 0, 0, 0),
            ),
          ),
        );
      },
    );
  }
}
