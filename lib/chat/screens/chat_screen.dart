import 'dart:convert';
import 'dart:io';


import 'package:bubble/bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:marquee/marquee.dart';
import 'package:test/chat/domain/chat_creation_service.dart';
import 'package:test/chat/domain/messaging_service.dart';
import 'package:test/chat/screens/user_profile_screen.dart';
import 'package:test/consts.dart';
import 'package:test/main.dart';
import 'package:test/search/screens/search_profile_screen.dart';
import 'package:test/user/domain/user_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../data/chat.dart';
import 'group_members_screen.dart';


class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String chatName;
  final String? photoUrl;
  final String? anotherUserId;
  final bool doublePop;

  const ChatScreen({
    super.key,
    this.chatId,
    required this.chatName,
    required this.photoUrl,
    this.anotherUserId,
    this.doublePop = false,
  });

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
  bool _isSending = false;
  bool _isArchived = false;
  List<PlatformFile> _selectedFiles = [];
  WebSocketChannel _channel = WebSocketChannel.connect(
    Uri.parse('ws://$websocketAddress:$serverPort/chat'),
  );

  late Future<List<PlatformFile>?> _filesToSendFuture;

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

  // Future<void> _updateMessages() async {
  //   try {
  //     final messages = await _messagingService.getRecentMessages(_chatId!);
  //     setState(() {
  //       _messages = messages;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _isError = true;
  //     });
  //   }
  // }

  Future<void> _getUserId() async {
    _userId = await UserPreferences.getUserId();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
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
    print('step 3');

    _checkWebSocketConnectionAndLoadChats();
    _loadArchiveStatus();

    print('step 4');

    _channel.stream.listen((message) {
      print('asdasd $message');
      setState(() {
        _messages.add(MessengerMessage.fromJson(json.decode(message.toString())));
      });
    });
  }

  Future<void> _loadArchiveStatus() async {
    if (_chatId != null) {
      final isArchived = await UserPreferences.isChatArchived(_chatId!);
      if (mounted) {
        setState(() {
          _isArchived = isArchived;
        });
      }
    }
  }

  Future<void> _toggleArchiveStatus() async {
    if (_chatId == null) return;

    try {
      if (_isArchived) {
        await UserPreferences.unarchiveChat(_chatId!);
      } else {
        await UserPreferences.archiveChat(_chatId!);
      }

      setState(() {
        _isArchived = !_isArchived;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isArchived ? 'Чат архивирован' : 'Чат разархивирован'),
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось изменить статус архивации'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleHeaderTap() {
    if (widget.anotherUserId != null) {
      // Это личный чат
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              UserProfileScreen(userId: widget.anotherUserId!),
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
    } else {
      // Это групповой чат
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              GroupMembersScreen(
                chatId: widget.chatId!,
                chatName: widget.chatName,
                userId: _userId,
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
    }
  }

  Future<void> _pickFiles() async {
    final files = await _messagingService.pickFiles(allowMultiple: true);
    if (files != null) {
      setState(() {
        _selectedFiles = files;
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  void _clearFiles() {
    setState(() {
      _selectedFiles = [];
    });
  }

  Future<void> _simulateFileUpload() async {
    setState(() {
      _isSending = true;
    });

    try {
      // Симулируем загрузку файла с задержкой в 1 секунду
      await Future.delayed(const Duration(seconds: 1));
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Widget _buildLoadingOverlay() {
    if (!_isSending) return const SizedBox.shrink();

    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(22, 79, 148, 1)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () { Navigator.of(context).pop();
              if (widget.doublePop) {
                Navigator.of(context).pop();
              }}
            ),
            toolbarHeight: 90,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1.0),
              child: Container(
                height: 1.0,
                color: const Color.fromRGBO(22, 79, 148, 1),
              ),
            ),
            centerTitle: true,
            title: GestureDetector(
              onTap: _handleHeaderTap,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final text = widget.chatName;
                  const style = TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  );

                  final textPainter = TextPainter(
                    text: TextSpan(text: text, style: style),
                    maxLines: 1,
                    textDirection: TextDirection.ltr,
                  )..layout(minWidth: 0, maxWidth: double.infinity);

                  final textWidth = textPainter.size.width;

                  return Row(
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
                          child: textWidth > constraints.maxWidth - 60
                              ? Marquee(
                                  text: text,
                                  style: style,
                                  scrollAxis: Axis.horizontal,
                                  blankSpace: 40.0,
                                  velocity: 30.0,
                                  pauseAfterRound: const Duration(milliseconds: 1200),
                                )
                              : Text(
                                  text,
                                  style: style,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            actions: [
              PopupMenuButton<String>(
                iconSize: 40,
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) async {
                  if (value == 'mute') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Уведомления отключены')),
                    );
                  } else if (value == 'archive') {
                    await _toggleArchiveStatus();
                  }
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
                  PopupMenuItem<String>(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          _isArchived ? Icons.unarchive : Icons.archive_rounded,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 12),
                        Text(_isArchived ? 'Разархивировать чат' : 'Архивировать чат'),
                      ],
                    ),
                  ),
                ],
              ),

            ],
          ),
          body: _getBody(),
        ),
        _buildLoadingOverlay(),
      ],
    );
  }

  Widget _getBody() {
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

    final chatItems = _buildChatItems().reversed.toList();
    return Column(
      children: [
        Expanded(
          child: Container(
            color: const Color.fromRGBO(235, 236, 240, 1),
            child: ListView.builder(
              reverse: true,
              itemCount: chatItems.length,
              itemBuilder: (context, index) {
                return chatItems[index];
              },
            ),
          ),
        ),
        _buildFilePreviewBar(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          color: Colors.white,
          child: Row(
            children: <Widget>[
              IconButton(
                icon: const Icon(FontAwesomeIcons.paperclip,
                    color: Color.fromRGBO(22, 79, 148, 1)),
                onPressed: _isSending ? null : _pickFiles,
              ),
              Expanded(
                child: TextField(
                  controller: _messageController,
                  enabled: !_isSending,
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
                onPressed: _isSending
                    ? null
                    : () async {
                        if (_messageController.text.isNotEmpty || _selectedFiles.isNotEmpty) {
                          print('try send message ${_messageController.text}');
                          if (_chatId == null) {
                            var chatId = await _chatCreationService.createPersonalChat(widget.anotherUserId!);
                            if (chatId != null) {
                              _chatId = chatId;
                            } else {
                              // TODO handle error
                              return;
                            }
                          }

                          if (_selectedFiles.isNotEmpty) {
                            await _simulateFileUpload();
                          }

                          // TODO: Upload files and get URLs before sending message
                          final List<Media> media = _selectedFiles.map((file) => 
                            Media('image', 'https://i.pinimg.com/originals/ae/9b/e1/ae9be178fac17c37c1ef47e1a0c06241.jpg')).toList();

                          await _messagingService.sendMessage(
                            _chatId!,
                            _messageController.text,
                            _channel,
                            media: media.isNotEmpty ? media : null,
                          );
                          
                          _messageController.text = '';
                          _clearFiles();
                        }
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreviewBar() {
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color.fromRGBO(22, 79, 148, 1), width: 1),
          bottom: BorderSide(color: Color.fromRGBO(22, 79, 148, 1), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Выбранные файлы',
                style: TextStyle(
                  color: Color.fromRGBO(22, 79, 148, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color.fromRGBO(22, 79, 148, 1),
                ),
                onPressed: _clearFiles,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedFiles.length,
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 16,
                        color: Color.fromRGBO(22, 79, 148, 1),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        file.name.length > 15
                            ? '${file.name.substring(0, 12)}...'
                            : file.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _removeFile(index),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChatItems() {
    List<Widget> result = [];
    if (_messages.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Color.fromRGBO(22, 79, 148, 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Начните общение',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(22, 79, 148, 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Отправьте сообщение или файл',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
    }
    String? lastDate;
    for (int i = 0; i < _messages.length; i++) {
      final msg = _messages[i];
      final msgDate = _formatDate(msg.timestamp);

      // Нужно добавить разделитель дня?
      if (lastDate != msgDate) {
        result.add(DateDivider(dateText: msgDate));
        lastDate = msgDate;
      }

      result.add(ChatBubble(
        text: msg.content.content,
        media: msg.content.media,
        time: msg.getTime(),
        isSentByMe: msg.senderId == _userId,
      ));
    }
    return result;
  }

  String _formatDate(DateTime dt) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (dt.year == today.year && dt.month == today.month && dt.day == today.day) {
      return 'Сегодня';
    }
    if (dt.year == yesterday.year && dt.month == yesterday.month && dt.day == yesterday.day) {
      return 'Вчера';
    }

    // Массив русских месяцев
    const monthsRu = [
      '',
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    String day = dt.day.toString();
    String month = monthsRu[dt.month];
    return '$day $month';
  }


}

class DateDivider extends StatelessWidget {
  final String dateText;
  const DateDivider({required this.dateText});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: Color(0xFFBBC7D3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            dateText,
            style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                fontWeight: FontWeight.w500
            ),
          ),
        ),
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
