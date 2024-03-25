import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:test/search/domain/search_service.dart';
import 'package:test/search/screens/search_profile_screen.dart';
import 'package:test/user/data/user.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final SearchService _searchService = SearchService();
  List<User> _users = [];
  bool _isSearchPerformed = false;

  Future<void> _search() async {
    if (_controller.text.isEmpty) {
      setState(() {
        _users = [];
        _isSearchPerformed = false;
      });
      return;
    }

    final users = await _searchService.searchUsers(_controller.text);
    setState(() {
      _isSearchPerformed = true;
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Поиск',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchField(),
            const SizedBox(height: 20),
            _buildSearchButton(),
            const SizedBox(height: 20),
            _buildSearchResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: 'Поиск по компании',
        labelStyle: const TextStyle(
          fontFamily: 'CeraPro',
          color: Color.fromARGB(255, 22, 79, 148),
        ),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 22, 79, 148),
            width: 2.0,
          ),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Color.fromARGB(255, 22, 79, 148),
            width: 2.0,
          ),
        ),
        suffixIcon: IconButton(
          onPressed: () {
            _controller.clear();
            setState(() {
              _users = [];
              _isSearchPerformed = false;
            });
          },
          icon: const FaIcon(
            FontAwesomeIcons.circleXmark,
            color: Color.fromARGB(255, 22, 79, 148),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _search,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(255, 22, 79, 148),
      ),
      child: const Text(
        'Поиск',
        style: TextStyle(
            fontFamily: 'CeraPro', color: Color.fromARGB(255, 245, 245, 245)),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Expanded(
      child: !_isSearchPerformed
          ? Container()
          : _users.isEmpty
              ? const Center(
                  child: Text(
                    'Ничего не найдено',
                    style: TextStyle(
                      fontFamily: 'CeraPro',
                      fontSize: 18,
                      color: Color.fromARGB(255, 22, 79, 148),
                    ),
                  ),
                )
              : ListView.separated(
                  itemCount: _users.length,
                  separatorBuilder: (context, index) =>
                      Divider(color: Colors.blueGrey.shade100),
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return ListTile(
                      title: Text(
                        '${user.name} ${user.surname} ${user.patronymic ?? ""}',
                        style: const TextStyle(
                          fontFamily: 'CeraPro',
                          color: Color.fromARGB(255, 22, 79, 148),
                        ),
                      ),
                      leading: user.photo_link != null
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.photo_link!),
                            )
                          : const CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SearchProfileScreen(
                                userId: user.id ?? 'defaultUserId'),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}
