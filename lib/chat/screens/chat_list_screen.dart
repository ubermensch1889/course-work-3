import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:test/chat/domain/chat_list_service.dart';
import 'package:test/chat/screens/chat_search_screen.dart';
import 'package:test/services/domain/abscence_service.dart';

import '../data/chat.dart';
import 'group_creation_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  ChatListScreenState createState() => ChatListScreenState();
}

class ChatListScreenState extends State<ChatListScreen> {
  final ChatListService chatListService = ChatListService();
  late List<ChatItem> _chats = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
        centerTitle: true,
        title: const Text(
          'Мессенджер',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
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
            leading: CircleAvatar(
              backgroundImage: chat.imageUrl != null
                  ? NetworkImage(chat.imageUrl!)
                  : null,
              child: chat.imageUrl == null
                  ? Text(chat.name[0])
                  : null,
            ),
            title: Text(
              chat.name,
              style: const TextStyle(
                fontFamily: 'CeraPro',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              chat.lastMessageText ?? '',
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
                  chat.lastMessageDate ?? '',
                  style: const TextStyle(fontSize: 12),
                ),
                if (chat.messageStatus != null)
                  Icon(
                    Icons.check,
                    color: chat.messageStatus == MessageStatus.read
                        ? Colors.blue
                        : Colors.grey,
                    size: 16,
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreateGroupScreen(),
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
