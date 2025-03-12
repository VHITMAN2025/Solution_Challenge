import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_document_scanner/flutter_document_scanner.dart';
import 'package:path_provider/path_provider.dart';

class DocumentScannerPage extends StatefulWidget {
  const DocumentScannerPage({Key? key}) : super(key: key);

  @override
  State<DocumentScannerPage> createState() => _DocumentScannerPageState();
}

class _DocumentScannerPageState extends State<DocumentScannerPage> {
  final _documentScannerController = DocumentScannerController();

  @override
  void dispose() {
    _documentScannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Document Scanner')),
      body: DocumentScanner(
        controller: _documentScannerController,
        onSave: (Uint8List? value) async {
          if (value != null) {
            // Get the temporary directory
            final tempDir = await getTemporaryDirectory();
            // Create a temporary file
            final file = await File('${tempDir.path}/document.png').create();
            // Write the Uint8List to the temporary file
            await file.writeAsBytes(value);
            debugPrint('document saved success: ${file.path}');
            // TODO: Navigate to the page to display the scanned document using file.path
          } else {
            debugPrint('Document save failed.');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Document save failed.')),
            );
          }
        },
      ),
    );
  }
}