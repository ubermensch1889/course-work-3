import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:test/chat/domain/chat_creation_service.dart';
import 'package:test/chat/domain/messaging_service.dart';
import 'package:test/consts.dart';
import 'package:test/main.dart';
import 'package:test/search/screens/search_profile_screen.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/chat.dart';

class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String chatName;
  final String? photoUrl;
  final String? anotherUserId;
  final bool doublePop;

  const ChatScreen(
      {super.key,
      this.chatId,
      required this.chatName,
      required this.photoUrl,
      this.anotherUserId,
      this.doublePop = false});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<MessengerMessage> _messages = [];
  final MessagingService _messagingService = MessagingService();
  final ChatCreationService _chatCreationService = ChatCreationService();
  late String _userId;
  String? _chatId;
  bool _isLoading = false;
  bool _isError = false;
  final _channel = WebSocketChannel.connect(
    Uri.parse('ws://$websocketAddress:$serverPort/chat'),
  );

  Future<void> _loadMessages() async {
    if (_chatId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      _messages = await _messagingService.getRecentMessages(_chatId!);
    } catch (e) {
      setState(() {
        _isError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateMessages() async {
    try {
      final messages = await _messagingService.getRecentMessages(_chatId!);
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      setState(() {
        _isError = true;
      });
    }
  }

  Future<void> _getUserId() async {
    _userId = await UserPreferences.getUserId();
  }

  @override
  void dispose() {
    super.dispose();
    _channel.sink.close();
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

    _loadMessages();
  }

  @override
  void initState() {
    super.initState();
    _chatId = widget.chatId;
    print('step 1');
    _getUserId();
    print('step 2');

    _loadMessages();
    print('step 3');

    _checkWebSocketConnectionAndLoadChats();

    print('step 4');

    _channel.stream.listen((message) {
      print('asdasd $message');
      _updateMessages();
    });
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

    if (_isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка загрузки сообщений(')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            iconSize: 30,
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Navigator.of(context).popUntil(ModalRoute.withName('/chat_list'));
              Navigator.of(context).pop();
              // Navigator.of(context).pop();
            }),
        toolbarHeight: 90,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1.0),
            child: Container(
              height: 1.0,
              color: const Color.fromRGBO(22, 79, 148, 1),
            )),
        centerTitle: true,
        title: GestureDetector(
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: widget.photoUrl != null
                    ? NetworkImage(widget.photoUrl!)
                    : null,
                child: widget.photoUrl != null ? null : Text(widget.chatName[0]),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 28,
                  child: Marquee(
                    text: widget.chatName,
                    style: const TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    scrollAxis: Axis.horizontal,
                    blankSpace: 40.0,
                    velocity: 30.0,
                    pauseAfterRound: Duration(milliseconds: 1200),
                    // другие параметры по желанию
                  ),
                ),
              ),
            ],
          ),
          // ...
        ),
        actions: [
          PopupMenuButton<String>(
            iconSize: 40,
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'mute') {
                // Логика отключения уведомлений
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Уведомления отключены')),
                );
              }
              // Место для другой логики
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'mute',
                child: Row(
                  children: [
                    Icon(Icons.notifications_off, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Отключить уведомления'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'archive',
                child: Row(
                  children: [
                    Icon(Icons.archive_rounded, color: Colors.grey),
                    SizedBox(width: 12),
                    Text('Архивировать чат'),
                  ],
                ),
              ),
              // Добавьте другие PopupMenuItem при необходимости
            ],
          ),

        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromRGBO(235, 236, 240, 1),
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return ChatBubble(
                    text: message.content.content,
                    media: message.content.media, // <--- добавлено
                    time: message.getPrettyDatetime(),
                    isSentByMe: message.senderId == _userId,
                  );
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(FontAwesomeIcons.paperclip,
                      color: Color.fromRGBO(22, 79, 148, 1)),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Написать сообщение...',
                      hintStyle: TextStyle(color: Colors.grey),
                      contentPadding: EdgeInsets.fromLTRB(8, 4, 4, 5),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                              color: Color.fromRGBO(22, 79, 148, 1), width: 3)),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromRGBO(22, 79, 148, 1)),
                  onPressed: () async {
                    if (_messageController.text.isNotEmpty) {
                      print('try send message ${_messageController.text}');
                      if (_chatId == null) {
                        var chatId = await _chatCreationService.createPersonalChat(widget.anotherUserId!);
                        if (chatId != null) {
                          _chatId = chatId;
                        } else {
                          // TODO handle error
                        }
                      }
                      _messagingService.sendMessage(
                          _chatId!, _messageController.text, _channel);
                      _messageController.text = '';
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String? text;
  final List<Media>? media;
  final String time;
  final bool isSentByMe;

  ChatBubble({
    this.text,
    this.media,
    required this.time,
    required this.isSentByMe,
  });

  @override
  Widget build(BuildContext context) {
    // Проверим, есть ли картинка (первой)
    Media? imageMedia;
    try {
      imageMedia = media?.firstWhere((m) => m.type == 'image');
    } catch (_) {
      imageMedia = null;
    }

    // Проверим, есть ли файл
    Media? fileMedia;
    try {
      fileMedia = media?.firstWhere((m) => m.type == 'file');
    } catch (_) {
      fileMedia = null;
    }

    Widget photoWidget = SizedBox.shrink();
    if (imageMedia != null) {
      photoWidget = ClipRRect(
        borderRadius: BorderRadius.circular(14.0),
        child: Image.network(
          imageMedia.url,
          fit: BoxFit.cover,
          width: 220,
          // Можно еще ограничить высоту:
          // height: 200,
          errorBuilder: (c, e, st) =>
              Container(color: Colors.black12, height: 120, width: 220, child: Icon(Icons.broken_image, color: Colors.white54)),
        ),
      );
    }

    Widget fileWidget = SizedBox.shrink();
    if (fileMedia != null) {
      fileWidget = Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, // Яркий выделенный фон
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        child: Row(
          children: [
            Icon(Icons.insert_drive_file, color: Color(0xFF164F94), size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Файл', style: TextStyle(color: Color(0xFF164F94), fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(
                    fileMedia.url.split('/').last,
                    style: TextStyle(
                        color: Color(0xFF164F94),
                        decoration: TextDecoration.underline,
                        fontSize: 13,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Сбор содержимого бабла
    List<Widget> bubbleContent = [];
    if (photoWidget is! SizedBox) bubbleContent.add(photoWidget);
    if (fileWidget is! SizedBox) bubbleContent.add(fileWidget);
    if (text != null && text!.trim().isNotEmpty) {
      bubbleContent.add(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            text!,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    // Размер bubble зависит от наличия/размера фото
    double maxWidth = MediaQuery.of(context).size.width * 2 / 3;
    if (photoWidget is! SizedBox) {
      maxWidth = 240; // чуть больше ширины фото
    }

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: Bubble(
              alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
              radius: Radius.circular(18.0),
              margin: BubbleEdges.all(5),
              nipHeight: 14,
              nip: isSentByMe ? BubbleNip.rightBottom : BubbleNip.leftBottom,
              color: const Color.fromRGBO(22, 79, 148, 1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: bubbleContent,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 10, left: 10),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
