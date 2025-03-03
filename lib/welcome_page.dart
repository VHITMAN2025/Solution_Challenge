import 'package:flutter/material.dart';
// Add the following import for the scanner functionality
import 'package:barcode_scan2/barcode_scan2.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  Future<void> _openScanner(BuildContext context) async {
    try {
      var result = await BarcodeScanner.scan();
      if (result.rawContent.isNotEmpty) {
        // Handle the scanned data
        print(result.rawContent);
      }
    } catch (e) {
      // Handle any errors
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to VoteShield!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'You have successfully logged in.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => _openScanner(context),
              child: const Text('Scan Code'),
            ),
          ],
        ),
      ),
    );
  }
}
