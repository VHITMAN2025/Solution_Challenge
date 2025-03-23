import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VotersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SearchList();
  }
}

class SearchList extends StatefulWidget {
  @override
  State<SearchList> createState() => _SearchListState();
}

class _SearchListState extends State<SearchList> {
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
        var name = clientSnapShot['name'].toString().toLowerCase();
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
              .collection('voters')
              .orderBy('name')
              .get();

      setState(() {
        _allResults = data.docs;
        searchResultList();
      });
    } catch (e) {
      print("Error fetching data: $e");
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
      body: SizedBox(
        height: 600.0,
        child: ListView.builder(
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                _resultList[index]['name'],
                style: TextStyle(fontSize: 18.0), // Increase name font size
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gender: ${_resultList[index]['gender']}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue, // Change gender font color
                    ),
                  ),
                  Text(
                    'Father: ${_resultList[index]['father_name:']}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue, // Change father's name font color
                    ),
                  ),
                  Text(
                    'Is_voted: ${_resultList[index]['is_voted']}',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.blue, // Change is_voted font color
                    ),
                  ),
                ],
              ),
              trailing: Text(
                _resultList[index]['epic_no'],
                style: TextStyle(
                  fontSize: 16.0,
                ), // Increase epic number font size
              ),
            );
          },
        ),
      ),
    );
  }
}
