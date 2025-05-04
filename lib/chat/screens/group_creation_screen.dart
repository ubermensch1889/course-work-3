import 'dart:io';

import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_list_service.dart';

import '../../search/domain/search_service.dart';
import '../../user/data/user.dart';
import '../data/chat.dart';
import '../domain/group_creation_service.dart';

class GroupCreationScreen extends StatefulWidget {
  final List<SuggestedUser> users;

  const GroupCreationScreen({super.key, required this.users});

  @override
  GroupCreationScreenState createState() => GroupCreationScreenState(users: users);
}

class GroupCreationScreenState extends State<GroupCreationScreen> {
  final List<SuggestedUser> users;
  final TextEditingController _controller = TextEditingController();
  final _groupCreationService = GroupCreationService();
  File? _groupAvatar;

  GroupCreationScreenState({required this.users});

  Future<void> _pickImage() async {
    _groupAvatar = await _groupCreationService.pickImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать группу'),
        leading: IconButton(
          iconSize: 30,
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          }
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '2 участника',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    radius: 25,
                    child: Text(
                      user.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
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
    var isSuccess = await _groupCreationService.tryCreateChat(_controller.text, users);

    if (!isSuccess) {
      return showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('К сожалению, создать чат не удалось. Попробуйте позднее'),
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