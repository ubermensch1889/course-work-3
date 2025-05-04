import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test/chat/domain/chat_list_service.dart';
import 'package:test/chat/screens/chat_screen.dart';
import 'package:test/chat/screens/chat_search_screen.dart';
import 'package:test/services/domain/abscence_service.dart';
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
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://84.201.179.46:8080/chat'),
  );
  late Stream<dynamic> _broadcastStream;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _checkWebSocketConnectionAndLoadChats();

    _broadcastStream = _channel.stream.asBroadcastStream();

    _broadcastStream.listen((message) {
      print(message);
      _loadChats();
    });
  }

  Future<void> _checkWebSocketConnectionAndLoadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _channel.ready;
      print('Websocket connected');
    } on SocketException catch (e) {
      print('SocketException occured: $e');
    } on WebSocketChannelException catch (e) {
      print('WebSocketChannelException occured: $e');
    }

    _loadChats();

  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _chats = await chatListService.fetchChats();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки чатов: $e')),
      );
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
        ],
      ),
      body: ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            onTap: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                  builder: (context) {
                    return ChatScreen(channel: _channel, chatId: chat.chatId, broadcastStream: _broadcastStream);
                  },
                ),
              );
            },
            leading: CircleAvatar(
                // backgroundImage: chat.imageUrl != null
                //     ? NetworkImage(chat.imageUrl!)
                //     : null,
                child: Text(chat.chatName[0]),
                ),
            title: Text(
              chat.chatName,
              style: const TextStyle(
                fontFamily: 'CeraPro',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              chat.lastMessage != null
                  ? chat.lastMessage!.content.content!
                  : '',
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
                Text(
                  chat.lastMessage!.getPrettyDatetime(),
                  style: const TextStyle(fontSize: 12),
                ),
                // if (chat.messageStatus != null)
                //   Icon(
                //     Icons.check,
                //     color: chat.messageStatus == MessageStatus.read
                //         ? Colors.blue
                //         : Colors.grey,
                //     size: 16,
                //   ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // print('hide navbar');
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) {
          //       print('ChatListScreen');
          //       return ChatScreen();
          //     },
          //   ),
          // );
          // print('unhide navbar');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const GroupMembersChoosingScreen(),
            ),
          );
        },
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
        elevation: 12,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
