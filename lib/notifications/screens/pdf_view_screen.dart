import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewPage extends StatelessWidget {
  final File file;

  const PDFViewPage({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Документ")),
      body: Column(
        children: [
          Expanded(
            child: PDFView(
              filePath: file.path,
              swipeHorizontal: true,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 79, 148),
                  minimumSize: const Size(336, 40),
                  padding: const EdgeInsets.all(15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  )),
              child: const Text(
                'Отправить в бухгалтерию',
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
