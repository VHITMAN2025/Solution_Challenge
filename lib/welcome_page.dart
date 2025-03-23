import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voteshield/about_ui.dart';
import 'details.dart';
import 'dart:io'; // Import the dart:io library
import 'package:cloud_firestore/cloud_firestore.dart';
import 'document_scanner_page.dart'; // Import firestore
import 'pollingbooths.dart';
import 'voters_list.dart'; // Add this import

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  File? imageFile;
  String? voterId;
  String? voterName;
  int? voterPart;
  String? voterAddress;
  String? voterAadhar;
  String? voterPan;

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

    List<String?> extractedMatches;
    String extractedText = '';

    if (RegExp(r'\b[A-Z]{3}[0-9]{7}\b').hasMatch(recognizedText.text)) {
      extractedMatches =
          RegExp(
            r'\b[A-Z]{3}[0-9]{7}\b',
          ).allMatches(recognizedText.text).map((e) => e.group(0)).toList();
      extractedText = extractedMatches.join(', ');
    } else if (RegExp(r'\b[0-9]{12}\b').hasMatch(recognizedText.text)) {
      extractedMatches =
          RegExp(
            r'\b[0-9]{12}\b',
          ).allMatches(recognizedText.text).map((e) => e.group(0)).toList();
      extractedText = extractedMatches.join(', ');
    } else if (RegExp(
      r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b',
    ).hasMatch(recognizedText.text)) {
      extractedMatches =
          RegExp(
            r'\b[A-Z]{5}[0-9]{4}[A-Z]{1}\b',
          ).allMatches(recognizedText.text).map((e) => e.group(0)).toList();
      extractedText = extractedMatches.join(', ');
    } else if (RegExp(r'\b[A-Z]{2}[0-9]{13}\b').hasMatch(recognizedText.text)) {
      // Modified regex: removed '$'
      extractedMatches =
          RegExp(r'\b[A-Z]{2}[0-9]{13}\b') // Modified regex: removed '$'
          .allMatches(recognizedText.text).map((e) => e.group(0)).toList();
      extractedText = extractedMatches.join(', ');
    }

    // Check if extractedText exists and is not empty before proceeding
    if (extractedText.isNotEmpty) {
      // Query Firestore to check if the voter ID exists
      checkFirestore(extractedText, 'voter_epic_no');
    } else {
      print('No valid Voter ID found in image.');
      setState(() {
        voterId = null; // Set voterId to null when no ID is found
        voterName = null;
        voterPart = null;
        voterAddress = null;
        voterAadhar = null;
        voterPan = null;
      });
    }
  }

  Future<void> checkFirestore(String extractedText, String fieldName) async {
    FirebaseFirestore.instance
        .collection('electoral_roll')
        .where(fieldName, isEqualTo: extractedText)
        .get()
        .then((querySnapshot) {
          if (querySnapshot.docs.isNotEmpty) {
            // Voter ID exists in the database
            print('Voter ID found in database!');

            // Check if the voter has already voted
            bool isVoted = querySnapshot.docs.first.get('is_voted') ?? false;

            if (isVoted) {
              // Voter has already voted, show a message
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Already Voted"),
                    content: Text("This voter has already cast their vote."),
                    actions: [
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              // Set voterId to voter_epic_no from Firestore
              String voterEpicNo = querySnapshot.docs.first.get(
                'voter_epic_no',
              );
              setState(() {
                voterId = voterEpicNo;
                voterName = querySnapshot.docs.first.get('voter_name');
                voterPart = querySnapshot.docs.first.get('part_no');
                voterAddress = querySnapshot.docs.first.get('address');
                voterAadhar = querySnapshot.docs.first.get('aadhar_no');
                voterPan = querySnapshot.docs.first.get('pan_card');
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
                        voterAadhar: voterAadhar,
                        voterPan: voterPan,
                      ),
                ),
              );
            }
          } else {
            // Voter ID does not exist in the database, try other fields
            if (fieldName == 'voter_epic_no') {
              checkFirestore(extractedText, 'aadhar_no');
            } else if (fieldName == 'aadhar_no') {
              checkFirestore(extractedText, 'pan_card'); // Corrected field name
            } else if (fieldName == 'pan_card') {
              // Corrected field name
              checkFirestore(
                extractedText,
                'license_no',
              ); // Corrected field name
            } else {
              // All fields checked, voter ID not found
              print('Voter ID not found in database.');
              setState(() {
                voterId = 'Voter ID not found';
                voterName = null;
                voterPart = null;
                voterAddress = null;
              });
            }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VoteShield')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.search), //
              title: Text('Voter Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => VotersList()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.how_to_vote),
              title: Text('Polling Booths'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PollingBooths()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AboutUsUI()),
                );
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to VoteShield',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () {
                pickImage();
              },
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.camera_alt),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
              child: Text('Go to Details'),
            ),
          ],
        ),
      ),
    );
  }
}
