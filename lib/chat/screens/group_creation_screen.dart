import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_list_service.dart';

import '../../search/domain/search_service.dart';
import '../../user/data/user.dart';
import '../data/chat.dart';
import '../domain/chat_creation_service.dart';

class GroupCreationScreen extends StatefulWidget {
  final List<User> users;

  const GroupCreationScreen({super.key, required this.users});

  @override
  GroupCreationScreenState createState() => GroupCreationScreenState();
}

class GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _controller = TextEditingController();
  final _groupCreationService = ChatCreationService();
  File? _groupAvatar;

  Future<void> _pickImage() async {
    _groupAvatar = await _groupCreationService.pickImage();
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Создать группу',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите название',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                getParticipantsNumberString(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.users.length,
              itemBuilder: (context, index) {
                var user = widget.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    backgroundImage: user.photo_link != null
                        ? NetworkImage(user.photo_link!)
                        : null,
                    child: user.photo_link == null
                        ? Text(
                            user.name[0].toUpperCase() +
                                user.surname[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          )
                        : null,
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.name),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_controller.text.isEmpty) {
            _showNameEmptyDialog();
            return;
          }

          _createChat();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        },
        child: const Icon(Icons.check_circle),
      ),
    );
  }

  Future<void> _createChat() async {
    var chatId = await _groupCreationService.createGroupChat(
        _controller.text, widget.users.map((user) => user.id).toList());

    if (chatId == null) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
                'К сожалению, создать чат не удалось. Попробуйте позднее'),
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

  String getParticipantsNumberString() {
    final length = widget.users.length + 1;
    final mod10 = length % 10;
    final mod100 = length % 100;
    if (mod10 == 1 && mod100 != 11) {
      return '$length участник';
    } else if (mod10 >= 2 && mod10 <= 4 && !(mod100 >= 12 && mod100 <= 14)) {
      return '$length участника';
    } else {
      return '$length участников';
    }
  }

  Future<void> _showNameEmptyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Введите название чата'),
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
