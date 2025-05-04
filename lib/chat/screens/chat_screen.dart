import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/chat/domain/messaging_service.dart';
import 'package:test/main.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/chat.dart';

class ChatScreen extends StatefulWidget {
  final WebSocketChannel channel;
  final String chatId;
  final Stream<dynamic> broadcastStream;

  const ChatScreen({super.key, required this.channel, required this.chatId, required this.broadcastStream});

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late List<MessengerMessage> _messages = [];
  final MessagingService _messagingService = MessagingService();
  // final userId = await UserPreferences.getUserId();
  bool _isLoading = true;

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _messages = await _messagingService.getRecentMessages(widget.chatId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки сообщений: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override void dispose() {
    super.dispose();
  }

  @override void initState() {
    super.initState();
    _loadMessages();

    widget.broadcastStream.listen((message) {
      print('asdasd $message');
      _loadMessages();
    });
    // widget.channel.stream.listen((message) {
    //   print(message);
    //   _loadMessages();
    // });
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
        title: const Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/images/avatar.jpg'),
            ),
            SizedBox(width: 10),
            const Text(
              'Эренцен Сангаджиев',
              style: TextStyle(
                fontFamily: 'CeraPro',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            iconSize: 40,
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO add 3 points screen
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color.fromRGBO(235, 236, 240, 1),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return
                    ChatBubble(
                      text: message.content.content,
                      time: message.getPrettyDatetime(),
                      isSentByMe: true,
                    );
                }
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            color: Colors.white,
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: const Icon(FontAwesomeIcons.paperclip, color: Color.fromRGBO(22, 79, 148, 1)),
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
                  icon: Icon(Icons.send, color: Color.fromRGBO(22, 79, 148, 1)),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      _messagingService.sendMessage(
                          widget.chatId, _messageController.text,
                          widget.channel);
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
  final String? imagePath;
  final String time;
  final bool isSentByMe;
  final bool isImageBubble;

  ChatBubble({
    this.text,
    this.imagePath,
    required this.time,
    required this.isSentByMe,
    this.isImageBubble = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 2 / 3,
            ),
            child: Bubble(
              alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
              radius: Radius.circular(18.0),
              margin: BubbleEdges.all(5),
              nipHeight: 14,
              nip: isSentByMe ? BubbleNip.rightBottom : BubbleNip.leftBottom,
              color: const Color.fromRGBO(22, 79, 148, 1),
              child: Column(
                children: [
                  if (imagePath != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Image.asset(imagePath!),
                    ),
                  if (text != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        text!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
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
