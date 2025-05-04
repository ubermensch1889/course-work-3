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
          toolbarHeight: 110,
          centerTitle: false,
          leading: IconButton(
              iconSize: 30,
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pop();
              }
          ),
          leadingWidth: 30,
          title: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Поиск',
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: EdgeInsets.fromLTRB(8, 4, 4, 5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                borderSide: BorderSide(color: Color.fromRGBO(22, 79, 148, 1), width: 3)
              ),
            ),
          ),
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Column(children: [
                TabBar(
                  controller: _tabController,
                  labelColor: Colors.black,
                  tabs: const [
                    Tab(text: 'Личные чаты', height: 30,),
                    Tab(text: 'Групповые чаты', height: 30,),
                  ],
                ),
                Container(
                  height: 0.0,
                  color: const Color.fromRGBO(22, 79, 148, 1),
                )
              ]))),
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
