import 'package:flutter/material.dart';
import 'package:test/chat/domain/chat_list_service.dart';

import '../../search/domain/search_service.dart';
import '../../user/data/user.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  CreateGroupScreenState createState() => CreateGroupScreenState();
}

class CreateGroupScreenState extends State<CreateGroupScreen> {
  final List<User> _chosen_users = [];
  final List<User> _suggested_users = List<User>.generate(15, (int index) {
    return User(
      id: index.toString(),
      name: 'Анна' + index.toString(),
      surname: 'Сидорова',
      patronymic: '',
      phones: [],
      email: '',
      birthday: '',
      photo_link: null,
      password: '',
      headId: '',
      telegram_id: '',
      vk_id: '',
      team: '',
    );
  });
  final SearchService _searchService = SearchService();
  final ChatListService _chatListService = ChatListService();

  Widget _buildChosenUserChip(User user) {
    return InkWell(
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 122, 145, 184),
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: user.photo_link != null
                  ? NetworkImage(user.photo_link!)
                  : null,
              radius: 15,
              child: user.photo_link == null
                  ? Text(user.name![0])
                  : null,
            ),
            const SizedBox(width: 5),
            Text(
              user.name!,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ],
        ),
      ),
      onTap: () {
        setState(() {
          _chosen_users.remove(user);
        });
      },
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Создать группу'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Handle back action
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 6),
            constraints: const BoxConstraints(
              maxHeight: 90.0,
            ),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: _chosen_users.map((item) {
                    return _buildChosenUserChip(item);
                  }).toList(),
                ),
              )
            ),
          ),

          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Кого бы Вы хотели пригласить?'
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _suggested_users.length,
              itemBuilder: (context, index) {
                var user = _suggested_users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    child: Text(
                      user.name!.substring(0, 1),
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(user.name!),
                  subtitle: Text(user.name!),
                  trailing: Checkbox(
                    value: _chosen_users.contains(user), // Example selected item
                    onChanged: (value) {
                      if (value!) {
                        setState(() {
                          _chosen_users.add(user);
                        });
                      }
                      else {
                        setState(() {
                          _chosen_users.remove(user);
                        });
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action
        },
        child: Icon(Icons.arrow_forward),
      ),
    );
  }
}

