import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PollingBooths extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Polling Booths')),
      body: PollingBoothsStateful(), // Use the stateful widget here
    );
  }
}

class PollingBoothsStateful extends StatefulWidget {
  @override
  State<PollingBoothsStateful> createState() => _SearchListState();
}

class _SearchListState extends State<PollingBoothsStateful> {
  List _allResults = [];
  List _resultList = [];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    _getClientStream(); // Load data initially
    super.initState();
  }

  _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResults = [];
    if (_searchController.text != "") {
      for (var clientSnapShot in _allResults) {
        var name = clientSnapShot['booth_no'].toString().toLowerCase();
        if (name.contains(_searchController.text.toLowerCase())) {
          showResults.add(clientSnapShot);
        }
      }
    } else {
      showResults = List.from(_allResults);
    }

    setState(() {
      _resultList = showResults;
    });
  }

  _getClientStream() async {
    try {
      var data =
          await FirebaseFirestore.instance
              .collection('polling_booth_no')
              .orderBy('booth_no')
              .get();

      setState(() {
        _allResults = data.docs;
        searchResultList(); // Update the result list after fetching data
      });
    } catch (e) {
      print("Error fetching data: $e");
      // Handle error (e.g., show an error message)
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Remove back button
        title: CupertinoSearchTextField(controller: _searchController),
      ),
      body: ListView.builder(
        itemCount: _resultList.length,
        itemBuilder: (context, index) {
          // Add alternating background colors
          Color backgroundColor =
              index % 2 == 0
                  ? Colors.grey[200]! // Light grey for even indices
                  : Colors.white; // White for odd indices

          return Container(
            color: backgroundColor,
            child: ListTile(
              title: Text(_resultList[index]['officer_name']),
              subtitle: Text(_resultList[index]['address']),
              trailing: Text(_resultList[index]['booth_no']),
            ),
          );
        },
      ),
    );
  }
}
