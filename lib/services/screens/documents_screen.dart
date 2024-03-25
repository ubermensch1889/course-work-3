import 'package:flutter/material.dart';
import 'package:test/services/data/document.dart';
import 'package:test/services/domain/document_service.dart';

class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({Key? key}) : super(key: key);

  @override
  DocumentsListScreenState createState() => DocumentsListScreenState();
}

class DocumentsListScreenState extends State<DocumentsListScreen> {
  final DocumentsService documentService = DocumentsService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Список документов',
            style: TextStyle(
              fontFamily: 'CeraPro',
              fontSize: 22,
              fontWeight: FontWeight.bold,
            )),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<DocumentItem>>(
            future: documentService.fetchDocuments(),
            builder: (BuildContext context,
                AsyncSnapshot<List<DocumentItem>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Произошла ошибка'));
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    DocumentItem document = snapshot.data![index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        title: Text(document.name,
                            style: const TextStyle(
                              fontFamily: 'CeraPro',
                              fontSize: 18,
                            )),
                        subtitle: Text(document.description),
                        trailing: document.signRequired
                            ? const Icon(Icons.check_circle,
                                color: Color.fromARGB(255, 22, 79, 148))
                            : const Icon(Icons.check_circle_outline,
                                color: Colors.grey),
                        onTap: () {},
                      ),
                    );
                  },
                );
              } else {
                return const Center(
                    child: Text('Нет доступных документов',
                        style: TextStyle(
                          fontFamily: 'CeraPro',
                          fontSize: 18,
                        )));
              }
            },
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                minimumSize: const Size.fromHeight(50),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Заказать документ',
                style: TextStyle(
                    fontFamily: 'CeraPro',
                    fontSize: 18,
                    color: Color.fromARGB(255, 245, 245, 245)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
