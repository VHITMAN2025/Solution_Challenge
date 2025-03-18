import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'details.dart';
import 'dart:io'; // Import the dart:io library
import 'package:cloud_firestore/cloud_firestore.dart'; // Import firestore

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  File? imageFile;
  String? voterId;
  String? voterName;
  int? voterPart;
  String? voterAddress;

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    setState(() {
      if (pickedFile != null) {
        imageFile = File(pickedFile.path);
        processImage();
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> processImage() async {
    if (imageFile == null) {
      print('No image selected.');
      return;
    }

    final inputImage = InputImage.fromFilePath(imageFile!.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(
      inputImage,
    );
    List<String?> extractedMatches =
        RegExp(
          r'\b[A-Z]{3}[0-9]{7}\b',
        ).allMatches(recognizedText.text).map((e) => e.group(0)).toList();

    String extractedText = extractedMatches.join(', ');

    // Check if extractedText exists and is not empty before proceeding
    if (extractedText.isNotEmpty) {
      // Query Firestore to check if the voter ID exists
      FirebaseFirestore.instance
          .collection('electoral_roll')
          .where('voter_epic_no', isEqualTo: extractedText)
          .get()
          .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              // Voter ID exists in the database
              print('Voter ID found in database!');
              setState(() {
                voterId = extractedText;
                voterName = querySnapshot.docs.first.get('voter_name');
                voterPart = querySnapshot.docs.first.get('part_no');
                voterAddress = querySnapshot.docs.first.get('address');
              });

              // Navigate to the details page, passing voterId and voterName
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ProfilePage(
                        voterId: voterId,
                        voterName: voterName,
                        voterPart: voterPart,
                        voterAddress: voterAddress,
                      ),
                ),
              );
            } else {
              // Voter ID does not exist in the database
              print('Voter ID not found in database.');
              setState(() {
                voterId = 'Voter ID not found';
                voterName = null;
                voterPart = null;
                voterAddress = null;
              });
            }
          })
          .catchError((error) {
            print("Error querying Firestore: $error");
            setState(() {
              voterId = 'Error checking Voter ID';
              voterName = null;
              voterPart = null;
              voterAddress = null;
            });
          });
    } else {
      print('No valid Voter ID found in image.');
      setState(() {
        voterId = 'No Voter ID found';
        voterName = null;
        voterPart = null;
        voterAddress = null;
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
              'Welcome to VoteShield',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: const Text('Scan Voter ID'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: const Text('Go to Details'),
            ),
            if (voterId != null)
              Text('Voter ID: $voterId', style: TextStyle(fontSize: 18)),
            if (voterName != null)
              Text('Voter Name: $voterName', style: TextStyle(fontSize: 18)),
            if (voterPart != null)
              Text(
                'Part No: ${voterPart.toString()}',
                style: TextStyle(fontSize: 18),
              ),
            if (voterAddress != null)
              Text('Address: $voterAddress', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
