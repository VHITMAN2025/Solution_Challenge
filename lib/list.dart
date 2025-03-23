import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(listUI());
}

class listUI extends StatefulWidget {
  @override
  State<listUI> createState() => _MyAppState();
}

class _MyAppState extends State<listUI> {
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
      var data = await FirebaseFirestore.instance
          .collection('voters')
          .orderBy('name')
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
    return MaterialApp(
      title: 'Authentication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: CupertinoSearchTextField(
            controller: _searchController,
          ),
        ),
        body: ListView.builder(
          itemCount: _resultList.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_resultList[index]['name']),
              subtitle: Text(_resultList[index]['gender']),
              trailing: Text(_resultList[index]['epic_no']),
            );
          },
        ),
      ),
    );
  }
}