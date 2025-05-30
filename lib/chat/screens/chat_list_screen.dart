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
  late List<MessengerListedChatInfo> _filteredChats = [];
  late String _userId;
  String _chatState = 'active';
  bool _showPersonal = true;
  bool _showGroup = true;
  Set<String> _archivedChats = {};
  WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://$websocketAddress:$serverPort/chat'),
  );
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _checkWebSocketConnectionAndLoadChats();
    
    print('Начало прослушивания WebSocket для списка чатов');
    _channel.stream.listen(
      (message) {
        print('Получено обновление списка чатов');
        _updateChats();
      },
      onError: (error) {
        print('Ошибка WebSocket в списке чатов: $error');
        _reconnectWebSocket();
      }
    );
  }

  Future<void> _checkWebSocketConnectionAndLoadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _channel.ready;
      print('WebSocket подключен для списка чатов');
    } on SocketException catch (e) {
      print('Ошибка подключения к WebSocket для списка чатов: $e');
    } on WebSocketChannelException catch (e) {
      print('Ошибка WebSocket канала для списка чатов: $e');
    }

    _loadChatsAndSetUserId();
  }

  Future<void> _reconnectWebSocket() async {
    print('Попытка переподключения WebSocket для списка чатов');
    await _channel.sink.close();
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://$websocketAddress:$serverPort/chat'),
      );
    });
    _checkWebSocketConnectionAndLoadChats();
    
    _channel.stream.listen(
      (message) {
        print('Получено обновление после переподключения');
        _updateChats();
      },
      onError: (error) {
        print('Ошибка WebSocket после переподключения: $error');
        _reconnectWebSocket();
      }
    );
  }

  Future<void> _updateChats() async {
    try {
      await Future.wait([
        _loadArchivedChats(),
        () async {
          _chats = await chatListService.fetchAndAdjustChats();
        }(),
      ]);
      _applyFilters();
    } catch (e) {
      print('Ошибка при обновлении списка чатов: $e');
      setState(() {
        _isError = true;
      });
    }
  }

  Future<void> _loadArchivedChats() async {
    _archivedChats = await UserPreferences.getArchivedChats();
  }

  void _applyFilters() {
    setState(() {
      _filteredChats = _chats.where((chat) {
        // Проверяем статус архивации
        final isArchived = _archivedChats.contains(chat.chatId);
        if (_chatState == 'archived' && !isArchived) return false;
        if (_chatState == 'active' && isArchived) return false;

        // Фильтр по типу чата
        if (!_showPersonal && chat.isPersonal()) return false;
        if (!_showGroup && !chat.isPersonal()) return false;
        
        return true;
      }).toList();
    });
  }

  Future<void> _loadChatsAndSetUserId() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Future.wait([
        _loadArchivedChats(),
        () async {
          _chats = await chatListService.fetchAndAdjustChats();
          _userId = await UserPreferences.getUserId();
        }(),
      ]);
      _applyFilters();
    } catch (e) {
      print('Ошибка при загрузке чатов: $e');
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
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => StatefulBuilder(
                  builder: (context, setModalState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Состояние чатов",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          RadioListTile(
                            value: 'archived',
                            groupValue: _chatState,
                            onChanged: (value) {
                              setModalState(() => _chatState = value!);
                              _applyFilters();
                            },
                            title: Text('Архивированные чаты',
                                style: TextStyle(fontSize: 15)),
                          ),
                          RadioListTile(
                            value: 'active',
                            groupValue: _chatState,
                            onChanged: (value) {
                              setModalState(() => _chatState = value!);
                              _applyFilters();
                            },
                            title: Text('Активные чаты',
                                style: TextStyle(fontSize: 15)),
                          ),
                          const Divider(),
                          const Text(
                            "Типы чатов",
                            style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          CheckboxListTile(
                            value: _showPersonal,
                            onChanged: (value) {
                              setModalState(() => _showPersonal = value!);
                              _applyFilters();
                            },
                            title: Text("Личные чаты",
                                style: TextStyle(fontSize: 15)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                          CheckboxListTile(
                            value: _showGroup,
                            onChanged: (value) {
                              setModalState(() => _showGroup = value!);
                              _applyFilters();
                            },
                            title: Text("Групповые чаты",
                                style: TextStyle(fontSize: 15)),
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: getBody(),
      floatingActionButton: _chatState == 'active' ? FloatingActionButton(
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
              await Navigator.of(context, rootNavigator: true).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const GroupMembersChoosingScreen(),
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
              await _updateChats();
            } else if (chatType == 'personal') {
              final result = await Navigator.of(context, rootNavigator: true).push(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      PersonalChatMemberChoosingScreen(channel: _channel),
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
              await _updateChats();
            }
          }
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ) : null,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Ошибка загрузки чатов.'),
              TextButton(
                onPressed: _updateChats,
                child: const Text('Обновить')
              )
            ],
          ),
        ),
      );
    }

    if (_filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _chatState == 'archived' ? Icons.archive : Icons.chat_bubble_outline,
              size: 80,
              color: Color.fromRGBO(22, 79, 148, 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _chatState == 'archived' ? 'Нет архивированных чатов' : 'Нет активных чатов',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(22, 79, 148, 0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        final chat = _filteredChats[index];
        return ListTile(
          onTap: () async {
            final result = await Navigator.of(context, rootNavigator: true).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    ChatScreen(
                      chatId: chat.chatId,
                      chatName: chat.getPrettyChatName(),
                      photoUrl: chat.photoUrl,
                      anotherUserId: chat.isPersonal() ? chat.getSecondParticipantId(_userId) : null,
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
            
            // Обновляем список чатов при возвращении
            await _updateChats();
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
