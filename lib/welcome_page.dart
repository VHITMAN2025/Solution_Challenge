import 'dart:io';
import 'package:flutter/material.dart';
import 'document_scanner_page.dart';
import 'package:voteshield/details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool textScan = false;
  XFile? Imagefile;
  String scannedText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to VoteShield!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentScannerPage(),
                    ),
                  );
                },
                child: const Text('Scan Voter id'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DocumentScannerPage(),
                    ),
                  );
                },
                child: const Text('Go to Details'),
              ),
              const SizedBox(height: 20), // Added some spacing
              ElevatedButton(
                onPressed: () {
                  print("Hello HITMAN");
                },
                child: const Text('Pick Image from Camera'),
              ),
              const SizedBox(height: 20),
              if (Imagefile != null) // Display the image if it exists
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.file(File(Imagefile!.path), height: 150),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextFormField(
                  maxLines: 5,
                  readOnly: true,
                  decoration: const InputDecoration(
                    hintText: 'Scanned text will appear here',
                    border: OutlineInputBorder(),
                  ),
                  controller: TextEditingController(text: scannedText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void getImage() async {
  //   try {
  //     final pickedImage = await ImagePicker().pickImage(
  //       source: ImageSource.camera,
  //     );
  //     if (pickedImage != null) {
  //       textScan = true;
  //       Imagefile = pickedImage;
  //       setState(() {});
  //       getRecognisedText(pickedImage);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       textScan = false;
  //       Imagefile = null;
  //       scannedText = "Error occured while fetching";
  //     });
  //   }
  // }

  // void getRecognisedText(XFile image) async {
  //   final inputImage = InputImage.fromFilePath(image.path);
  //   final textrecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  //   final RecognizedText recognizedText = await textrecognizer.processImage(
  //     inputImage,
  //   );
  //   await textrecognizer.close();
  //   scannedText = "";
  //   for (TextBlock block in recognizedText.blocks) {
  //     for (TextLine line in block.lines) {
  //       scannedText = scannedText + line.text + "\n";
  //     }
  //   }
  //   textScan = false;
  //   setState(() {});
  // }
}
