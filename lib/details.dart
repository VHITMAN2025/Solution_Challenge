import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatelessWidget {
  final String? voterId;
  final String? voterName;
  final int? voterPart;
  final String? voterAddress;

  const ProfilePage({
    super.key,
    this.voterId,
    this.voterName,
    this.voterPart,
    this.voterAddress,
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
            style: TextStyle(
              fontSize: 18,
              color: Colors.black87,
            ),
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
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
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
                    detailRow(title: 'Part number', value: voterPart?.toString()),
                    detailRow(title: 'Address', value: voterAddress),
                  ],
                ),
              ),
            ],
          ),
          CustomPaint(
            painter: HeaderCurvedContainer(),
            // ignore: sized_box_for_whitespace
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Voter Details",
                  style: TextStyle(
                    fontSize: 35,
                    letterSpacing: 1.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('electoral_roll')
                    .where('voter_epic_no', isEqualTo: voterId)
                    .get()
                    .then((querySnapshot) {
                  if (querySnapshot.docs.isNotEmpty) {
                    // Get the document reference
                    DocumentReference documentRef =
                        querySnapshot.docs.first.reference;

                    // Update the is_voted field to true
                    documentRef.update({'is_voted': true}).then((_) {
                      print('Successfully updated is_voted to true');
                      // Show a success message to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Ballot issued successfully!'),
                        ),
                      );
                    }).catchError((error) {
                      print('Error updating is_voted: $error');
                      // Show an error message to the user
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to issue ballot.'),
                        ),
                      );
                    });
                  } else {
                    print('Voter ID not found in database.');
                    // Show an error message to the user
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Voter ID not found.'),
                      ),
                    );
                  }
                }).catchError((error) {
                  print("Error querying Firestore: $error");
                  // Show an error message to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error issuing ballot.'),
                    ),
                  );
                });
              },
              child: const Text('Issue Ballot'),
            ),
          ],
        ),
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
