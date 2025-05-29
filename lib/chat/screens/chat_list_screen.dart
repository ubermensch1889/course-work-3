import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:test/chat/domain/chat_list_service.dart';
import 'package:test/chat/screens/chat_screen.dart';
import 'package:test/chat/screens/chat_search_screen.dart';
import 'package:test/chat/screens/personal_chat_member_choosing_screen.dart';
import 'package:test/consts.dart';
import 'package:test/services/domain/abscence_service.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../main.dart';
import '../data/chat.dart';
import 'group_members_choosing_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  final ChatListService chatListService = ChatListService();
  late List<MessengerListedChatInfo> _chats = [];
  late String _userId;
  late WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://$websocketAddress:$serverPort/chat'),
  );
  bool _isLoading = true;
  bool _isError = false;

  Future<void> _updateChats() async {
    try {
      final chats = await chatListService.fetchAndAdjustChats();
      setState(() {
        _chats = chats;
      });
    } catch (e) {
      print('ошибка загрузки чатов $e');
      setState(() {
        _isError = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    await _checkWebSocketConnectionAndLoadChats();
    
    _channel.stream.listen(
      (message) {
        print('from list $message');
        _updateChats();
      },
      onError: (error) {
        print('WebSocket error: $error');
        // Try to reconnect on error
        _reconnectWebSocket();
      }
    );
  }

  Future<void> _reconnectWebSocket() async {
    await _channel.sink.close();
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$websocketAddress:$serverPort/chat'),
      );
    });
    _initializeWebSocket();
  }

  Future<void> _checkWebSocketConnectionAndLoadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _channel.ready;
      print('Websocket connected from chat list');
    } on SocketException catch (e) {
      print('SocketException occurred: $e');
      await Future.delayed(const Duration(seconds: 1));
      return _reconnectWebSocket();
    } on WebSocketChannelException catch (e) {
      print('WebSocketChannelException occurred: $e');
      await Future.delayed(const Duration(seconds: 1));
      return _reconnectWebSocket();
    }

    _loadChatsAndSetUserId();
  }

  Future<void> _loadChatsAndSetUserId() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _chats = await chatListService.fetchAndAdjustChats();
      _userId = await UserPreferences.getUserId();
    } catch (e) {
      print('ошибка загрузки чатов $e');
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            iconSize: 30,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        toolbarHeight: 90,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: const Color.fromRGBO(22, 79, 148, 1),
            )),
        centerTitle: true,
        title: const Text(
          'Мессенджер',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ChatSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            iconSize: 30,
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) {
                    // Локальное состояние для радио и чеков
                    String chatState = 'active'; // active или archived
                    bool isPersonal = true;
                    bool isGroup = true;

                    final optionTextStyle = TextStyle(fontSize: 15);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // --- Первая секция ---
                          Text("Состояние чатов",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          RadioListTile(
                            value: 'archived',
                            groupValue: chatState,
                            onChanged: (value) {
                              setModalState(() => chatState = value!);
                            },
                            title: Text('Архивированные чаты',
                                style: optionTextStyle),
                          ),
                          RadioListTile(
                            value: 'active',
                            groupValue: chatState,
                            onChanged: (value) {
                              setModalState(() => chatState = value!);
                            },
                            title:
                                Text('Активные чаты', style: optionTextStyle),
                          ),
                          Divider(),
                          // --- Вторая секция ---
                          Text("Типы чатов",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          CheckboxListTile(
                            value: isPersonal,
                            onChanged: (value) {
                              setModalState(() => isPersonal = value!);
                            },
                            title: Text("Личные чаты", style: optionTextStyle),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                          CheckboxListTile(
                            value: isGroup,
                            onChanged: (value) {
                              setModalState(() => isGroup = value!);
                            },
                            title:
                                Text("Групповые чаты", style: optionTextStyle),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ).then((selectedFilters) {
                if (selectedFilters != null) {
                  print(selectedFilters);
                  // Обработка фильтров
                  // Например: setState(() { ... });
                }
              });
            },
          ),
        ],
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final chatType = await showModalBottomSheet<String>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            builder: (context) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Выберите тип чата",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Групповой чат'),
                    onTap: () => Navigator.of(context).pop('group'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Личный чат'),
                    onTap: () => Navigator.of(context).pop('personal'),
                  ),
                ],
              ),
            ),
          );

          if (!mounted) return;
          if (chatType != null) {
            if (chatType == 'group') {
              Navigator.of(context, rootNavigator: true).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const GroupMembersChoosingScreen(),
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
            } else if (chatType == 'personal') {
              Navigator.of(context, rootNavigator: true).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PersonalChatMemberChoosingScreen(channel: _channel),
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
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget getBody() {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isError) {
      return Scaffold(
        body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('Ошибка загрузки чатов.'),
          TextButton(onPressed: () => {}, child: const Text('Обновить'))
        ])),
      );
    }

    return ListView.separated(
      itemCount: _chats.length,
      itemBuilder: (context, index) {
        final chat = _chats[index];
        return ListTile(
          onTap: () {
            Navigator.of(context, rootNavigator: true).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatScreen(
                  chatId: chat.chatId,
                  chatName: chat.getPrettyChatName(),
                  photoUrl: chat.photoUrl,
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
            backgroundImage:
                chat.photoUrl != null ? NetworkImage(chat.photoUrl!) : null,
            radius: 30,
            child: chat.photoUrl != null
                ? null
                : (chat.getPrettyChatName().split(' ').length == 1
                    ? Text(chat.getPrettyChatName()[0].toUpperCase())
                    : Text(chat.getPrettyChatName()[0].toUpperCase()[0].toUpperCase() +
                        chat.getPrettyChatName().split(' ')[1][0].toUpperCase())),
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
            chat.lastMessage != null
                ? chat.lastMessage!.content.content!
                : 'Чат создан',
            style: const TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(200, 0, 0, 0),
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (chat.lastMessage != null)
                Text(
                  chat.lastMessage!.getPrettyDatetime(),
                  style: const TextStyle(fontSize: 12),
                ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(
        color: Color.fromRGBO(256, 256, 256, 0.2),
        thickness: 1,
        height: 0,
        indent: 78,
      ),
    );
  }
}
