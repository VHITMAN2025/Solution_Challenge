import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class ProfilePage extends StatelessWidget {
  final String? voterId;
  final String? voterName;
  final int? voterPart;
  final String? voterAddress;
  final String? voterAadhar;
  final String? voterPan;

  const ProfilePage({
    super.key,
    this.voterId,
    this.voterName,
    this.voterPart,
    this.voterAddress,
    this.voterAadhar,
    this.voterPan,
  });

  Widget detailRow({required String title, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          Text(
            value ?? 'N/A', // Display 'N/A' if value is null
            style: TextStyle(fontSize: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff555555),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navigate back to the previous page
          },
        ),
        title: const Text(
          "Voter Details",
          style: TextStyle(
            fontSize: 24,
            letterSpacing: 1.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 450,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    detailRow(title: 'Voter ID', value: voterId),
                    detailRow(title: 'Voter Name', value: voterName),
                    detailRow(
                      title: 'Part number',
                      value: voterPart?.toString(),
                    ),
                    detailRow(title: 'Address', value: voterAddress),
                    detailRow(title: 'Aadhar no', value: voterAadhar),
                    detailRow(title: 'Pan card', value: voterPan),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      if (voterId != null && voterId!.isNotEmpty) {
                        print(
                          'Attempting to update is_voted for epic_no: $voterId',
                        );

                        // Query the collection for a matching epic_no
                        QuerySnapshot querySnapshot =
                            await FirebaseFirestore.instance
                                .collection('electoral_roll')
                                .where('voter_epic_no', isEqualTo: voterId)
                                .get();

                        if (querySnapshot.docs.isNotEmpty) {
                          // Get the document ID of the matching document
                          String docId = querySnapshot.docs.first.id;

                          // Update the is_voted field in Firestore
                          await FirebaseFirestore.instance
                              .collection('electoral_roll')
                              .doc(docId)
                              .update({'is_voted': true});

                          print(
                            'Voted status updated in Firestore for epic_no: $voterId, docId: $docId',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Voter status updated successfully!',
                              ),
                            ),
                          );
                        } else {
                          print('Document not found for epic_no: $voterId');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Document not found for this Voter ID!',
                              ),
                            ),
                          );
                        }
                      } else {
                        print(
                          'Voter ID (epic_no) is null or empty. Cannot update voted status.',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voter ID is invalid!')),
                        );
                      }
                    } catch (e) {
                      print('Error updating voted status in Firestore: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating voter status: $e'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text(
                    'Issue Ballot',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HeaderCurvedContainer extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xff555555);
    Path path =
        Path()
          ..relativeLineTo(0, 150)
          ..quadraticBezierTo(size.width / 2, 225, size.width, 150)
          ..relativeLineTo(0, -150)
          ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
