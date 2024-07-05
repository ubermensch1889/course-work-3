import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:test/services/data/document.dart';
import 'package:test/services/domain/document_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class DocumentsListScreen extends StatefulWidget {
  const DocumentsListScreen({Key? key}) : super(key: key);

  @override
  DocumentsListScreenState createState() => DocumentsListScreenState();
}

class DocumentsListScreenState extends State<DocumentsListScreen> {
  final DocumentsService documentService = DocumentsService();
  late List<DocumentItem> _documents = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _documents = await documentService.fetchDocuments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки документов: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signDocument(String documentId, int index) async {
    try {
      await documentService.signDocument(documentId);
      var updatedDocument = _documents[index].copyWith(isSigned: true);
      setState(() {
        _documents[index] = updatedDocument;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Документ подписан')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка подписания документа: $e')),
      );
    }
  }

  Future<File> _downloadFile(String url) async {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var bytes = response.bodyBytes;
      if (bytes.isEmpty) {
        throw Exception('Received empty file');
      }
      var dir = await getApplicationDocumentsDirectory();
      File file =
          File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } else {
      throw Exception('Failed to download file: ${response.statusCode}');
    }
  }

  void openPDF(File file) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => DocumentViewPage(file: file)),
    );
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
        centerTitle: true,
        title: const Text(
          'Список документов',
          style: TextStyle(
            fontFamily: 'CeraPro',
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _documents.length,
              itemBuilder: (context, index) {
                final document = _documents[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      document.name,
                      style: const TextStyle(
                        fontFamily: 'CeraPro',
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(document.description),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (document.signRequired)
                          IconButton(
                            icon: Icon(
                              Icons.edit,
                              color: document.isSigned
                                  ? Colors.green
                                  : const Color.fromARGB(255, 22, 79, 148),
                            ),
                            onPressed: document.isSigned
                                ? null
                                : () => _signDocument(document.id, index),
                          ),
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            try {
                              String downloadUrl = await documentService
                                  .downloadDocument(document.id);
                              File pdfFile = await _downloadFile(downloadUrl);
                              openPDF(pdfFile);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Ошибка скачивания документа: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  color: Color.fromARGB(255, 245, 245, 245),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentViewPage extends StatefulWidget {
  final File file;

  const DocumentViewPage({Key? key, required this.file}) : super(key: key);

  @override
  DocumentViewPageState createState() => DocumentViewPageState();
}

class DocumentViewPageState extends State<DocumentViewPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Document"),
      ),
      body: Stack(
        children: <Widget>[
          PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            onRender: (_pages) {
              setState(() {
                _isLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _isLoading = false;
              });
              print("Error rendering PDF: $error");
            },
            onPageError: (page, error) {
              print("Error on page $page: $error");
            },
            onViewCreated: (PDFViewController pdfViewController) {},
            onPageChanged: (int? page, int? total) {},
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
