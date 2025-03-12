import 'package:flutter/material.dart';
import 'document_scanner_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  File? _imagefile;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imagefile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan the Voter ID Card',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DocumentScannerPage(),
                  ),
                );

                if (result != null && result is String) {
                  setState(() {
                    _imagefile = File(result);
                  });
                  debugPrint('Received file path: ${_imagefile!.path}');
                  // TODO: Handle the scanned document file
                }
              },
              child: const Text('Scan Document'),
            ),
          ],
        ),
      ),
    );
  }
}
