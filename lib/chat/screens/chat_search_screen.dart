import 'package:flutter/material.dart';

class ChatSearchScreen extends StatefulWidget {
  const ChatSearchScreen({super.key});

  @override
  ChatSearchScreenState createState() => ChatSearchScreenState();
}

class ChatSearchScreenState extends State<ChatSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Поиск',
            border: InputBorder.none,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: 'Личные чаты'),
            Tab(text: 'Групповые чаты'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPersonalChatsList(),
          _buildGroupChatsList(),
        ],
      ),
    );
  }

  Widget _buildPersonalChatsList() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return const ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text('Иван Иванов'),
          subtitle: Text('Был в сети в 8:54'),
        );
      },
    );
  }

  Widget _buildGroupChatsList() {
    return const Center(
      child: Text('У вас нет групповых чатов'),
    );
  }
}
