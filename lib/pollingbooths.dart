import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Pollingbooths extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Pollingbooths();
  }
}

class PollingBooths extends StatefulWidget {
  @override
  State<PollingBooths> createState() => _SearchListState();
}

class _SearchListState extends State<PollingBooths> {
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
        title: CupertinoSearchTextField(controller: _searchController),
      ),
      body: ListView.builder(
        itemCount: _resultList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_resultList[index]['officer_name']),
            subtitle: Text(_resultList[index]['address']),
            trailing: Text(_resultList[index]['booth_no']),
          );
        },
      ),
    );
  }
}
